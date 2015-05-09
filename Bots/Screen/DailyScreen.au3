
Func waitDailyScreen()
   SetLog("Waiting for Daily Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\daily_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Re-click adventure button on MainScreen
		 clickDailyButton()
		 If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("Daily Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next
   SetLog("Daily Screen Timeout", $COLOR_RED)
   Return False
EndFunc	;==>waitDailyScreen


Func checkActiveDailyAdventureStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 160, 95, 175, 109, $x, $y, $DefaultTolerance) Then
	  SetLog("Active Daily Adventure ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveDailyAdventureStatus


Func checkActiveDailyTempleStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 484, 95, 499, 109, $x, $y, $DefaultTolerance) Then
	  SetLog("Active Daily Adventure ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveDailyTempleStatus


Func waitDailyAdventureScreen()
   SetLog("Waiting for Daily Adventure Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\daily_adventure_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Re-click daily adventure enter button
		 Click(201, 405);
		 If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("Daily Adventure Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next
   SetLog("Daily Adventure Screen Timeout", $COLOR_RED)
   Return False
EndFunc	;==>waitDailyAdventureScreen


Func waitDailyTempleScreen()
   SetLog("Waiting for Daily Temple Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCountShort
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\daily_temple_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Re-click daily adventure enter button
		 Click(548, 405);

		 If _Sleep(2500) Then ExitLoop
	  Else
		 SetLog("Daily Temple Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next
   SetLog("Daily Temple Screen Timeout", $COLOR_RED)
   Return False
EndFunc	;==>waitDailyAdventureScreen


Func selectDailyAdventureLevel()
   _Sleep(2000)

   SetLog("Selecting daily adventure level : " & $setting_daily_level, $COLOR_PINK)

   Switch $setting_daily_level
	  Case 0	; Easy
		 Click(439, 263)
	  Case 1	; Normal
		 Click(550, 263)
	  Case 2	; Hard
		 Click(658, 263)
   EndSwitch

EndFunc


Func startDailyAdventureBattle()
   SetLog("Waiting for Daily Battle Ready Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount

	  If waitBattleReadyScreen(True) Then
		 SetLog("Daily Battle Ready Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf

	  Click(550, 425)	;  Battle Ready Button

	  If _Sleep($SleepWaitMSec) Then Return False
   Next
   Return False
EndFunc	;==>startDailyAdventureBattle



Func doTempleBattle()
   If waitBattleScreen() = False Then
	  SetLog("Failed to wait for Battle screen", $COLOR_RED)
	  SaveImageToFile("battle_error_screen");
	  Return False
   EndIf

   SetLog("Started battle!", $COLOR_RED)

   ClickPos($BATTLE_DODGE_BUTTON_POS, 800, 2)

   Local $limitTime = 150000

   Local $hTimer = TimerInit()
   While 1
	  If Int(TimerDiff($hTimer)) > $limitTime Then	; 11 min for raid
		 SetLog("Unexpected battle detected...", $COLOR_RED)
		 SaveImageToFile("battle_error_timeout");
		 $RunState = True
		 Return False
	  EndIf

	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_retry.bmp"), $POPUP_BUTTON_REGION) Then
		 SetLog("Retry Button Detected.", $COLOR_RED)
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

	  ClickPos($BATTLE_ATTACK_BUTTON_POS, 200, 8)

	  ; Battle Action!!
	  ClickPos($BATTLE_SKILL1_BUTTON_POS, 200, 4)
	  ClickPos($BATTLE_SKILL2_BUTTON_POS, 200, 2)
	  ClickPos($BATTLE_SKILL3_BUTTON_POS, 200, 2)
	  ClickPos($BATTLE_SKILL4_BUTTON_POS, 200, 2)
	  ClickPos($BATTLE_DODGE_BUTTON_POS, 200, 2)
   WEnd

   ; Click Main Button
   If ClickButtonImageArea(String(@ScriptDir & "\images\button_main_screen.bmp"), $RESULT_MAIN_SCREEN_BUTTON_REGION) Then
	  Return True
   EndIf
   Return False
EndFunc	;==>doTempleBattle

