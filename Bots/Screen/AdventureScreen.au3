
; Buttons
Local Const $ADVENTURE_LEFT_BUTTON_POS[2] = [54, 237]
Local Const $ADVENTURE_RIGHT_BUTTON_POS[2] = [710, 237]
Local Const $ADVENTURE_PORTAL_BUTTON_POS[2] = [688, 432]

; you should use the left-top side point for the button to prevent from pressing actual start button in next screen.
Local Const $ADVENTURE_READY_BUTTON_POS[2] = [412, 398]


Func waitAdventureScreen($checkMode = False)
   SetLog("Waiting for Adventure Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\adventure_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then

		 If $checkMode Then Return False

		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Checking RAID
		 If ClickButtonImage(String(@ScriptDir & "\images\button_raid_close.bmp")) Then
			SetLog("Raid Detected.", $COLOR_PINK)
		 EndIf

		 ; Close strange adventure confirm popup
		 If ClickButtonImageArea(String(@ScriptDir & "\images\button_popup_close.bmp"), $NORMAL_CLOSE_BUTTON_REGION) Then
			SetLog("Strange adventure confirm Detected.", $COLOR_PINK)
		 EndIf

		 ; Re-click adventure button on MainScreen
		 clickAdventureButton()
		 If _Sleep($SleepWaitMSec) Then ExitLoop

	  Else
		 If $checkMode Then Return True

		 SetLog("Adventure Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf

	  If $checkMode Then Return False	; Only one loop
   Next

   SetLog("Adventure Screen Timeout", $COLOR_RED)
   Return False

EndFunc	;==>waitAdventureScreen


Func selectAdventureStage()
   Local $found = -1
   Local $i

   Local $bmpPath = ""

   Local $beginStage = 1
   Local $endStage = 1
   Local $clickX = 532
   Local $clickY = 425

   If Int($setting_stage_major) <= 15 Then
	  $beginStage = 1
	  $endStage = 15
	  $bmpPath = @ScriptDir & "\images\stage_portal_matera.bmp"
   ElseIf Int($setting_stage_major) <= 18 Then
	  $beginStage = 16
	  $endStage = 18
	  $clickX = 615
	  $bmpPath = @ScriptDir & "\images\stage_portal_beachcliff.bmp"
   Else
	  $beginStage = 19
	  $endStage = 21
	  $clickX = 690
	  $bmpPath = @ScriptDir & "\images\stage_portal_beachvalley.bmp"
   EndIf

   ; Check current adventure land
   _Sleep(1200)

   For $i = 0 To $RetryWaitCountShort
	  _CaptureRegion()

	  If _ImageSearchArea($bmpPath, 0, 487, 388, 720, 450, $x, $y, $DefaultTolerance) Then
		 ExitLoop
	  EndIf

	  SetLog("Switch the adventure land " & $bmpPath, $COLOR_PINK)
	  Click($clickX, $clickY)

	  If _Sleep(2000) Then Return False
   Next

   ; Detect stage
   For $i = $beginStage To $endStage
	  Local $x, $y
	  $bmpPath = @ScriptDir & "\images\stage_" & $i & ".bmp"
	  _log("Finding Stage.. : " & $bmpPath )

	  _CaptureRegion()

	  If _ImageSearchArea($bmpPath, 0, 0, 325, 130, 385, $x, $y, 8) Then
		 SetLog($i & " Stage found. setting = " & $setting_stage_major, $COLOR_PINK)
		 $found = $i
		 ExitLoop
	  EndIf

   Next

   If waitAdventureScreen(True) = False Then Return False

   If $found = -1 Then
	  SetLog($i & " Stage not found. setting = " & $setting_stage_major, $COLOR_RED)
   Else
	  If Int($setting_stage_major) <> $i Then
		 Local $moveCount = $i - Int($setting_stage_major)
		 _log("Move Stage : " & $i & " => " & $setting_stage_major & ", Move count = " & $moveCount )

		 If $moveCount > 0 Then
			For $i = 1 To $moveCount
			   If waitAdventureScreen(True) = False Then Return False
			   ClickPos($ADVENTURE_LEFT_BUTTON_POS)
			   If _Sleep($SleepWaitMSecShort) Then Return False
			Next
		 Else
			$moveCount = $moveCount * -1
			For $i = 1 To $moveCount
			   If waitAdventureScreen(True) = False Then Return False
			   ClickPos($ADVENTURE_RIGHT_BUTTON_POS)
			   If _Sleep($SleepWaitMSecShort) Then Return False
			Next
		 EndIf
	  EndIf
   EndIf

   _Sleep(1000)
   _log("Click stage button" )
   ClickPos(getPixelStage($setting_stage_major, $setting_stage_minor), 1000)

  _clickReadyButton()

   Return True
EndFunc	;==>checkAdventureStage


Func _clickReadyButton()

   _log("Click Ready button" )
   ClickPos($ADVENTURE_READY_BUTTON_POS, 1000)

EndFunc	;==>_clickReadyButton


