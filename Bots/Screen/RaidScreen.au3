
; RAID Ready Window Spot Image Region
Local Const $RAID_CHECK_REGION[4] = [449, 64, 667, 98]

; Regions
Local Const $RAID_DETECT_REGION[4] = [361, 257, 689, 366]

; Buttons
Local Const $RAID_START_BUTTON_POS[2] = [561, 451]
Local Const $RAID_BATTLE_BUTTON_POS[2] = [165, 408]
Local Const $RAID_REAL_START_BUTTON_REGION[4] = [54, 381, 725, 433]


Func waitRaidScreen()
   SetLog("Waiting for Raid Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\raid_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Checking RAID
		 If ClickButtonImage(String(@ScriptDir & "\images\button_raid_close.bmp")) Then
			SetLog("Raid Detected.", $COLOR_PINK)
		 EndIf

		 ; Re-click raid button on MainScreen
		 clickRaidButton()
		 If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("Raid Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next
   SetLog("Raid Screen Timeout", $COLOR_RED)
EndFunc	;==>waitRaidScreen



Func startRaidBattle()
   SetLog("Waiting for Raid Battle Ready Screen", $COLOR_ORANGE)
   Local $foundRaidAttackButton = False
   For $i = 0 To $RetryWaitCount

	  If ClickButtonImageArea(String(@ScriptDir & "\images\button_raid_start.bmp"), $RAID_REAL_START_BUTTON_REGION) = False Then
		 If $foundRaidAttackButton = False Then
			ClickPos($RAID_START_BUTTON_POS)
			_Sleep(500)
		 EndIf
	  Else
		 $foundRaidAttackButton = True
	  EndIf

	  If waitBattleReadyScreen(True) Then
		 SetLog("Raid Battle Ready Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf

	  If _Sleep($SleepWaitMSec) Then Return False
   Next
   Return False
EndFunc	;==>startRaidBattle

