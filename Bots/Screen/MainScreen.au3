
Local Const $ADVENTURE_BUTTON_POS[2] = [680, 148]
Local Const $BLACKSMITH_BUTTON_POS[2] = [331, 278]
Local Const $INVENTORY_BUTTON_POS[2] = [60, 435]
Local Const $PVP_BUTTON_POS[2] = [594, 365]
Local Const $RAID_BUTTON_POS[2] = [435, 125]
Local COnst $GUILD_BUTTON_POS[2] = [680, 324]
Local COnst $DAILY_BUTTON_POS[2] = [293, 164]
Local Const $STAMINA_POTION_BUTTON_POS[2] = [189, 116]
Local Const $STAMINA_POTION_USE_OK_BUTTON_POS[2] = [474, 366]
Local Const $MAIN_QUEST_COSE_BUTTON_POS[2] = [720, 442]

Local Const $MAIN_SCREEN_CHECK_REGION = [404, 380, 532, 468]
Local Const $RAID_POPUP_CLOSE_BUTTON_REGION = [209, 206, 572, 376]
Local Const $ARCHIEVEMENT_POPUP_CLOSE_BUTTON_REGION = [631, 378, 761, 474]

Func waitMainScreen() ;Waits for main screen to popup
   SetLog("Waiting for Main Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\screen_main.bmp"

	  _CaptureRegion()

	  If ImageSearchArea($bmpPath, 0, $MAIN_SCREEN_CHECK_REGION, $x, $y, 30) Then
		 SetLog("Main Screen Located", $COLOR_BLUE)
		 Return True
	  Else
		 closeAllPopupOnMainScreen()
 		 If _Sleep($SleepWaitMSec) Then Return False
	  EndIf

   Next

   ; Now, not used...
   If 0 Then
	  SetLog("Unable to load Raven, Restarting...", $COLOR_RED)
	  Local $RestartApp = StringReplace(_WinAPI_GetProcessFileName(WinGetProcess($Title)), "Frontend", "Restart")
	  Run($RestartApp & " Android")
	  If _Sleep(10000) Then Return False

	  Do
		 If _Sleep(5000) Then Return False
	  Until ControlGetHandle($Title, "", "BlueStacksApp1") <> 0
   EndIf

   Return False

EndFunc   ;==>waitMainScreen

Func checkStamina()
   Local $x, $y
   Local $needStamina = getStaminaCount($setting_stage_major)
   Local $lack = False
   Local $checkingLongTime = False
   While $RunState
	  If _Sleep(100) Then Return

	  _CaptureRegion()

	  $lack = False

	  For $i = $needStamina - 1 To 0 Step -1
		 Local $bmpPath = @ScriptDir & "\images\stamina_lack_text_" & $i & ".bmp"
		 _console("Stamina lack checking : " & $bmpPath )

		 If _ImageSearchArea($bmpPath, 0, 68, 10, 155, 34, $x, $y, $DefaultTolerance) Then
			If $checkingLongTime = False Then
			   SetLog("Lack of stamina detected", $COLOR_RED)
			EndIf

			; Use stamia potion
			;Click($x, $y)
			Click(112, 24)
			_Sleep(1500)

			_CaptureRegion()

			If ClickButtonImage(@ScriptDir & "\images\stamina_use_text.bmp") Then
			   If clickOkButton() == 2 Then ExitLoop
			EndIf

			If $checkingLongTime = False Then
			   SetLog("Waiting for enough stamina..", $COLOR_ORANGE)
			EndIf
			$checkingLongTime = True
			$lack = True
			ExitLoop
		 EndIf
	  Next

	  If $lack = False Then
		 If $checkingLongTime Then
			SetLog("Enough stamina now", $COLOR_BLUE)
		 EndIf
		 ExitLoop
	  EndIf

   WEnd
EndFunc	;==>checkStamina


Func checkActiveAdventureStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 651, 163, 665, 179, $x, $y, $DefaultTolerance) Then
	  SetLog("Active Adventure ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveAdventureStatus


Func checkActivePvpStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 561, 414, 576, 429, $x, $y, $DefaultTolerance) Then
	  SetLog("Active PvP ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveRaidStatus


Func checkActiveRaidStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 394, 152, 416, 172, $x, $y, $DefaultTolerance) Then
	  SetLog("Active Raid ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveRaidStatus


Func checkActiveGuildStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 656, 344, 674, 358, $x, $y, $DefaultTolerance) Then
	  SetLog("Active Guild ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveRaidStatus


Func checkActiveDailyStatus()

   Local $bmpPath = @ScriptDir & "\images\todo_on_icon.bmp"

   If _ImageSearchArea($bmpPath, 0, 255, 184, 271, 200, $x, $y, $DefaultTolerance) Then
	  SetLog("Active Daily ON", $COLOR_RED)
	  Return True
   EndIf
   Return False
EndFunc	;==>checkActiveDailyStatus


Func clickAdventureButton()
   ClickPos($ADVENTURE_BUTTON_POS, 100, 2)	; twice click for some mistakes of mouse event
EndFunc	;==>clickAdventureButton


Func clickInventoryButton()
   ClickPos($INVENTORY_BUTTON_POS, 100, 2)	; twice click for some mistakes of mouse event
EndFunc	;==>clickAdventureButton


Func clickBlackSmithButton()
   ClickPos($BLACKSMITH_BUTTON_POS, 100, 2)	; twice click for some mistakes of mouse event
EndFunc	;==>clickAdventureButton


Func clickPvpButton()
   ClickPos($PVP_BUTTON_POS, 100, 1)
EndFunc	;==>clickAdventureButton


Func clickRaidButton()
   ClickPos($RAID_BUTTON_POS, 100, 1)
EndFunc	;==>clickRaidButton


Func clickGuildButton()
   ClickPos($GUILD_BUTTON_POS, 100, 1)
EndFunc	;==>clickGuildButton


Func clickDailyButton()
   ClickPos($DAILY_BUTTON_POS, 100, 1)
EndFunc	;==>clickDailyButton


Func checkDuplicatedConnection($forceMode = False)
   Local $x, $y
    _CaptureRegion()

   If _ImageSearchArea(String(@ScriptDir & "\images\duplicated_connect_text.bmp"), 0, 296, 166, 379, 195, $x, $y, $DefaultTolerance) Then
	  SetLog("Duplcated connection detected.", $COLOR_BLUE)

	  If $forceMode = False Then
		 Local $timeout = currentReconnectTimeout()
		 SetLog("Waiting for reconnect : " & ($timeout / 60 / 1000) & "min", $COLOR_ORANGE)

		 Local $timerReconnect = TimerInit()

		 While True
			If _Sleep(1000) Then ExitLoop
			$diff = Int(TimerDiff($timerReconnect))
			If $diff > $timeout Then
			   ExitLoop
			EndIf
			updateRemainingReconnectStatus($timeout - $diff)
			GUICtrlSetState($labelRemainingReconnectTime, $GUI_SHOW)
		 WEnd
		 GUICtrlSetState($labelRemainingReconnectTime, $GUI_HIDE)

		 If $RunState = False Then Return False
	  EndIf

	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $POPUP_CENTER_OK_BUTTON_REGION) Then
		 SetLog("Try to reconnect.", $COLOR_BLUE)
	  EndIf

	  Return True
   EndIf
   Return False
EndFunc


Func clickOkButton()
   If checkDuplicatedConnection() = False Then
	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $POPUP_BUTTON_REGION) Then
		 Return 1	; unknown ok button in any popup clicked
	  EndIf
   Else
	  Return 2	; duplicated popup ok clicked
   EndIf
   Return 0
EndFunc

Func closeAllPopupOnMainScreen($forceMode = False)

   Local $color = $COLOR_PINK
   Local $x, $y

   ; Checking duplicated connection
   If checkDuplicatedConnection($forceMode) = True Then
	  Return True
   EndIf

    _CaptureRegion()

   If ClickButtonImage(String(@ScriptDir & "\images\raven_icon.bmp")) Then
	  SetLog("Raven Icon clicked.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_back.bmp"), $BACK_BUTTON_REGION) Then
	  SetLog("Back button clicked.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\screen_start.bmp"), $GAME_START_REGION) Then
	  SetLog("Game Start detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\screen_attendance.bmp"), $SCREEN_NAME_REGION) Then
	  SetLog("Attendance book detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_ad_close.bmp"), $AD_POPUP_CLOSE_BUTTON_REGION) Then
	  SetLog("AD detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_notice_close.bmp"), $NOTICE_POPUP_CLOSE_BUTTON_REGION) Then
	  SetLog("Notice detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_raid_close.bmp"), $RAID_POPUP_CLOSE_BUTTON_REGION) Then
	  SetLog("Raid detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_achievement_close.bmp"), $ARCHIEVEMENT_POPUP_CLOSE_BUTTON_REGION) Then
	  SetLog("Achievement detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_popup_close.bmp"), $NORMAL_CLOSE_BUTTON_REGION) Then
	  SetLog("Popup detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_main_screen.bmp"), $BOTTOM_MAINSCREEN_BUTTON_REGION) Then
	  SetLog("Main button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_retry.bmp"), $POPUP_BUTTON_REGION) Then
	  SetLog("Retry button detected.", $color)
	  Return True
   EndIf

   ; Ok button checking.. without [cancel] [ok]
   If ClickButtonImageArea(String(@ScriptDir & "\images\button_cancel_red.bmp"), $POPUP_BUTTON_REGION) Then
	  SetLog("Cancel Button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_close.bmp"), $POPUP_BUTTON_REGION) Then
	  SetLog("Close Button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_big_ok.bmp"), $RESULT_PVP_BUTTON_REGION) Then
	  SetLog("PVP Ok button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_yellow_ok.bmp"), $POPUP_CENTER_OK_BUTTON_REGION) Then
	  SetLog("Yellow Ok button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $BOTTOM_OK_BUTTON_REGION) Then
	  SetLog("Bottom ok button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $POPUP_CENTER_OK_BUTTON_REGION) Then
	  SetLog("Center ok button detected.", $color)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_package_close.bmp"), $NOTICE_POPUP_CLOSE_BUTTON_REGION) Then
	  SetLog("Package Product detected.", $color)

	  _Sleep(2000)
	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $POPUP_BUTTON_REGION) Then
		 SetLog("Package Product canceled.", $color)
	  EndIf
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\button_popup_close.bmp"), $SMALL_CLOSE_BUTTON_REGION) Then
	  SetLog("Small Popup detected.", $color)
	  Return True
   EndIf

    If ClickButtonImageArea(String(@ScriptDir & "\images\button_web_close.bmp"), $NOTICE_POPUP_CLOSE_BUTTON_REGION) Then
	  SetLog("Web Popup detected.", $color)
	  Return True
   EndIf

   Return False
EndFunc	;==>closeAllPopupOnMainScreen