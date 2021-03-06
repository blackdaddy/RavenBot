
Local Const $PVP_READY_BUTTON_POS[2] = [555, 421]

Local Const $PVP_BATTLE_PAUSE_REGION[4] = [684, 22, 750, 84]
Local Const $RESULT_PVP_BUTTON_REGION[4] = [520, 385, 702, 467]
Local Const $PVP_THREE_VICTORY_REGION[4] = [161, 377, 268, 408]

Local Const $MAX_RETRY_CLICK_COUNT = 5

Local Const $PVP_POTION_EAT_DELAY_MSEC = 6000


Func waitPvpScreen()
   SetLog("Waiting for PvP Screen", $COLOR_ORANGE)
   Local $retryCount = 0
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\pvp_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Checking RAID
		 If ClickButtonImage(String(@ScriptDir & "\images\button_raid_close.bmp")) Then
			SetLog("Raid Detected.", $COLOR_PINK)
		 EndIf

		 If _checkRetry($retryCount) = False Then
			SetLog("Retry count limited.", $COLOR_RED)
			Return False
		 EndIf

		 ; Re-click adventure button on MainScreen
		 clickPvpButton()
		 If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("PvP Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next
   SetLog("PvP Screen Timeout", $COLOR_RED)
   Return False
EndFunc	;==>waitPvpScreen


Func _checkRetry(ByRef $retryCount)
   ; In this Pvp screen, this server disconnected popup can show up often. So just close the popup and try reconnect
   Local $x, $y
   Local $bmpPath = @ScriptDir & "\images\button_retry.bmp"
   If ImageSearchArea($bmpPath, 0, $POPUP_BUTTON_REGION, $x, $y, $DefaultTolerance) Then
	  SetLog("Retry button detected.", $COLOR_PINK)
	  If $retryCount < $MAX_RETRY_CLICK_COUNT Then
		 Click($x, $y)
		 $retryCount = $retryCount + 1
	  Else
		 Return False
	  EndIf
   EndIf
   Return True
EndFunc


Func checkPvpStamina()

   Local $bmpPath = @ScriptDir & "\images\pvp_lack_text_0.bmp"
   _log("PVP Stamina lack checking : " & $bmpPath )

   If _ImageSearchArea($bmpPath, 0, 264, 12, 312, 39, $x, $y, $DefaultTolerance) Then
	  SetLog("Lack of PvP stamina detected", $COLOR_RED)
	  Return False
   EndIf
   Return True
EndFunc


Func clickPvpReadyButton()
   ClickPos($PVP_READY_BUTTON_POS)
    SetLog("PvP ready button clicked.", $COLOR_ORANGE)
EndFunc	;==>clickPvpReadyButton


Func startPvpBattle()
   SetLog("Waiting for PvP Battle Ready Screen", $COLOR_ORANGE)
   Local $retryCount = 0
   For $i = 0 To $RetryWaitCountShort

	  If waitBattleReadyScreen(True) Then
		 SetLog("PvP Battle Ready Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf

	  If _checkRetry($retryCount) = False Then
		 SetLog("Retry count limited.", $COLOR_RED)
		 Return False
	  EndIf

	  ; For checking if battle already started by some reason (miss click, or double click..)
	  If _waitPvpBattleScreen(True) Then
		 SetLog("Skipped PvP Battle Ready Screen", $COLOR_BLUE)
		 Return True
	  EndIf

	  clickPvpReadyButton()

	  If _Sleep(2500) Then Return False
   Next
   Return False
EndFunc	;==>startPvpBattle


Func doPvpBattleScreen()

   If _waitPvpBattleScreen() = False Then
	  Return
   EndIf

   _selectAutoPvpBattle()

   Local $hTimer = TimerInit()
   Local $hTimerEatPotion = TimerInit()
   Local $hTimerDodge = TimerInit()
   Local $eatPotionFlag = False
   Local $index = 0

   While 1
	  $index = $index + 1
	  If Int(TimerDiff($hTimer)) > 300000 Then
		 SetLog("Unexpected battle detected...", $COLOR_RED)
		 SaveImageToFile("pvp_error");
		 $RunState = True
		 Return
	  EndIf

	  Local $battleEnd = WaitScreenImage(String(@ScriptDir & "\images\button_big_ok.bmp"), $RESULT_PVP_BUTTON_REGION, True);

	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $POPUP_BUTTON_REGION) Then
		 SetLog("Disconnect Detected.", $COLOR_BLUE)
		 ExitLoop
	  EndIf

	  If $battleEnd Then
		 SetLog("Finished PvP Battle!", $COLOR_RED)
		 ExitLoop
	  EndIf

	  ; To remove 3 continuous reward text
	  Click(186, 352)

	  ; Check Dodge skill interval
	  Local $intervalDodge = _GUICtrlComboBox_GetCurSel($comboBattleDodgeInterval[$Id_Pvp]);

	  If $intervalDodge > 0 Then
		 If Int(TimerDiff($hTimerDodge)) > $intervalDodge Then
			ClickPos($BATTLE_DODGE_BUTTON_POS, 100, 2)
			$hTimerDodge = TimerInit()
		 EndIf
	  EndIf

	  ; Only first time, cast Skill 4 for oneshot onekill
	  If $index = 1 Then
		 _console("### Cast powerfull skill 4");
		 If _Sleep(1300) Then Return
		 ClickPos($BATTLE_DODGE_BUTTON_POS, 400, 2)
		 If _Sleep(1300) Then Return
		 ClickPos($BATTLE_DODGE_BUTTON_POS, 400, 2)
		 ClickPos($BATTLE_SKILL4_BUTTON_POS, 200, 4)
	  EndIf

	  If $setting_eat_potion[$Id_Pvp] Then
		 If Int(TimerDiff($hTimerEatPotion)) > $PVP_POTION_EAT_DELAY_MSEC Then
			$eatPotionFlag = False
		 EndIf

		 If $eatPotionFlag = False Then
			If _checkHealthAndEatPotionForPvP() Then
			   $eatPotionFlag = True
			   $hTimerEatPotion = TimerInit()
			EndIf
		 EndIf
	  EndIf
   WEnd

   ; Click OK Button
   ClickButtonImageArea(String(@ScriptDir & "\images\button_big_ok.bmp"), $RESULT_PVP_BUTTON_REGION)

EndFunc	;==>doPvpBattleScreen


Func _waitPvpBattleScreen($checkMode = False)
   SetLog("Waiting for PvP Battle Screen", $COLOR_ORANGE)

   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\battle_mark.bmp"
	  If ImageSearchArea($bmpPath, 0, $PVP_BATTLE_PAUSE_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 Click(400, 200)	; Click anywhere to start
		 _Sleep(1500)
	  Else
		 SetLog("PvP Battle Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf

	  If $checkMode Then Return False

   Next

   SetLog("PvP Battle Screen Timeout", $COLOR_RED)
   Return False
EndFunc	;==>_waitPvpBattleScreen


Func _selectAutoPvpBattle()
   Local $bmpPath = @ScriptDir & "\images\battle_auto_mark.bmp"
   Local $x, $y
   _CaptureRegion()

   If _ImageSearchArea($bmpPath, 0, 318, 398, 405, 474, $x, $y, $DefaultTolerance) Then
	  ClickPos($BATTLE_AUTO_BUTTON_POS)
	  SetLog("Auto Battle Clicked", $COLOR_DARKGREY)
   EndIf

EndFunc	;==>_selectAutoBattle


Func _checkHealthAndEatPotionForPvP()
   Local $healthWidth = 216
   Local $healthStartPosX = 97
   Local $healthCheckPosY = 53

   Local $percent = healthConditionPercent($Id_Pvp)

   Local $checkX = Int($healthStartPosX + ($healthWidth * (100 - $percent) / 100))
   _console("Health checking : " & $checkX & ":" & $percent)

   If _ColorCheck(_GetPixelColor($checkX, $healthCheckPosY), Hex(0x111111, 6), 3) Then
	  SetLog("Eat Potion", $COLOR_RED)
	  ClickPos($BATTLE_POTION_BUTTON_POS)
	  Return True
   EndIf
   Return False
EndFunc	;==> _checkHealthAndEatPotionForPvP


Func ClickPvPThreeVictoryArea()
   Return ClickButtonImageArea(String(@ScriptDir & "\images\pvp_three_victory.bmp"), $PVP_THREE_VICTORY_REGION)
EndFunc
