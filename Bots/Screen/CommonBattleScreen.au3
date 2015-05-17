
; Battle Window Spot Color
Local Const $BATTLE_COLOR[2][4] = [[721, 37, 0xA5A5A5, 10], [730, 34, 0xADADAD, 10]]

; Buttons
Local Const $BATTLE_AUTO_BUTTON_POS[2] = [397, 436]
Local Const $RESULT_MAIN_SCREEN_BUTTON_REGION[4] = [29, 418, 593, 473]

Local Const $POTION_EAT_DELAY_MSEC = 6000

Func waitBattleScreen($checkMode = False)
   SetLog("Waiting for Battle Screen", $COLOR_ORANGE)

   Local $x, $y

   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  If WaitScreenPixel($BATTLE_COLOR, True) = False Then

		 If $checkMode Then Return False

		 clickBattleStartButton(False)

		 ; For stamina lack popup
		 _CaptureRegion()

		 If _ImageSearchArea(String(@ScriptDir & "\images\stamina_lack_text.bmp"), 0, 276, 174, 400, 221, $x, $y, $DefaultTolerance) Then
			ClickButtonImageArea(String(@ScriptDir & "\images\button_close.bmp"), $POPUP_BUTTON_REGION)
			SetLog("Stamina lack popup detected.", $COLOR_PINK)
			_Sleep(1000)
			Return False
		 EndIf

		 ; For lack of baggage popup. just go
		 If ClickButtonImageArea(String(@ScriptDir & "\images\button_battle_start_small.bmp"), $POPUP_BUTTON_REGION) Then
			SetLog("[Battle Start] button clicked.", $COLOR_PINK)
		 EndIf

		 ;If _Sleep($SleepWaitMSec) Then Return False	; already sleep in clickBattleStartButton method
	  Else
		 If $checkMode Then Return True
		 SetLog("Battle Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next

   Return False
EndFunc	;==>waitBattleScreen


Func doBattle($battleId)

   If waitBattleScreen() = False Then
	  SetLog("Failed to wait for Battle screen", $COLOR_RED)
	  SaveImageToFile("battle_error_screen");
	  Return False
   EndIf

   SetLog("Started battle!", $COLOR_RED)

   Local $limitTime = 300000

   Switch $battleId
	  Case $Id_Raid
		 $limitTime = 660000
   EndSwitch

   _Sleep(2000)

   Local $firstLoop = True
   Local $hTimerBattle = TimerInit()
   Local $hTimerEatPotion = TimerInit()
   Local $eatPotionFlag = False
   While 1
	  If _selectAutoBattle() Then
		 ; Wait for reaching to Enemy
		 If $firstLoop Then
			If _Sleep(5500) Then Return False
		 EndIf
		 $firstLoop	= False
	  EndIf

	  If Int(TimerDiff($hTimerBattle)) > $limitTime Then	; 11 min for raid
		 SetLog("Unexpected battle detected...", $COLOR_RED)
		 SaveImageToFile("battle_error_timeout");
		 $RunState = True
		 Return False
	  EndIf

	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_retry.bmp"), $POPUP_BUTTON_REGION) Then
		 SetLog("Retry Button detected.", $COLOR_RED)
		 ExitLoop
	  EndIf

	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_cancel_red.bmp"), $POPUP_BUTTON_REGION) Then

		 ; Update statistics
		 $adventureFailedCount = $adventureFailedCount + 1
		 updateStats()

		 SetLog("Battle Failure detected.", $COLOR_RED)
		 ExitLoop
	  EndIf

	  If clickOkButton() <> 0 Then
		 ExitLoop
	  EndIf

	  Local $battleEnd = WaitScreenImage(String(@ScriptDir & "\images\button_main_screen.bmp"), $RESULT_MAIN_SCREEN_BUTTON_REGION, True);
	  If $battleEnd Then
		 SetLog("Finished battle!", $COLOR_RED)
		 ExitLoop
	  EndIf

	  If _Sleep(2000) Then Return False

	  ; Health Check
	  If $setting_eat_potion[$battleId] Then

		 If Int(TimerDiff($hTimerEatPotion)) > $POTION_EAT_DELAY_MSEC Then
			$eatPotionFlag = False
		 EndIf

		 If $eatPotionFlag = False Then
			If _checkHealthAndEatPotion($battleId) Then
			   $eatPotionFlag = True
			   $hTimerEatPotion = TimerInit()
			EndIf
		 Else
			_console("Already eat potion.. wait sec for " &
		 EndIf
	  EndIf

	  ; Battle Action!!
	  If $setting_use_buff_items[$battleId][3] = False Then	; Checking auto skill buff
		  ClickPos($BATTLE_SKILL1_BUTTON_POS, 200, 4)
		  ClickPos($BATTLE_SKILL2_BUTTON_POS, 200, 4)
		  ClickPos($BATTLE_SKILL3_BUTTON_POS, 200, 4)
		  ClickPos($BATTLE_SKILL4_BUTTON_POS, 200, 4)
	  EndIf
	  ClickPos($BATTLE_DODGE_BUTTON_POS, 500, 2)
   WEnd

   ; Click Main Button
   If ClickButtonImageArea(String(@ScriptDir & "\images\button_main_screen.bmp"), $RESULT_MAIN_SCREEN_BUTTON_REGION) Then
	  Return True
   EndIf
   Return False
EndFunc	;==>doBattleScreen()


Func _selectAutoBattle()
   Local $bmpPath = @ScriptDir & "\images\battle_auto_mark.bmp"
   Local $x, $y
   _CaptureRegion()

   If _ImageSearchArea($bmpPath, 0, 376, 412, 419, 460, $x, $y, $DefaultTolerance) Then
	  ClickPos($BATTLE_AUTO_BUTTON_POS)
	  SetLog("Auto Battle Clicked", $COLOR_DARKGREY)
	  Return False
   Else
	  Return True
   EndIf

EndFunc	;==>_selectAutoBattle


Func _checkHealthAndEatPotion($battleId)
   Local $healthWidth = 150
   Local $healthStartPosX = 80
   Local $healthCheckPosY = 18

   Local $percent = healthConditionPercent($battleId)

   Local $checkX = Int($healthStartPosX + ($healthWidth * ($percent) / 100))
   _console("Health checking : " & $checkX & ":" & $percent)

   If _ColorCheck(_GetPixelColor($checkX, $healthCheckPosY), Hex(0x000000, 6), 3) Then
	  SetLog("Eat Potion", $COLOR_RED)
	  ClickPos($BATTLE_POTION_BUTTON_POS)
	  Return True
   EndIf
   Return False
EndFunc	;==> _checkHealthAndEatPotion
