
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
   Local $currentSlotIndex = 0
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


; Working....
Func checkRaidTrainData()
   Local Const $PaddingLeft = 45
   Local Const $LevelTextY = 250
   Local Const $RaidCardWidth = 247
   Local Const $OffsetX = 38
   Local Const $Gap = 19

   For $i = 0 To 2
	  Local $startX = $PaddingLeft + ($i * ($RaidCardWidth + $Gap) + $OffsetX
	  Local $dataRegion[4] = [$startX, $LevelTextY, $startX + 55, $LevelTextY + 22]
	  _CaptureRegionArea($dataRegion)
	  SaveImageToFile("train_" & $setting_traindata_index, $dirTrain, "bmp", False);
   Next
EndFunc


; Working....
Func readRaidLevel($currentSlotIndex)
   Local Const $PaddingLeft = 45
   Local Const $LevelTextY = 250
   Local Const $RaidCardWidth = 247
   Local Const $OffsetX = 38
   Local Const $Gap = 19
   Local Const $FontColor = Hex(0xD28D13, 6)
   Local Const $FontHeight = 22
   Local Const $MaxFontOffset = 4

   Local Const $DigitCount = 2
   Local Const $FontWidth[10] = [12, 13, 12, 13, 13, 13, 13, 13, 13, 13]	; 0, 2, 3

   Local $startX = $PaddingLeft + ($currentSlotIndex * ($RaidCardWidth + $Gap) + $OffsetX

   Local $res = 0

   Local $found = False
   Local $fontOffset = 0
   For $fontOffset = 0 To $MaxFontOffset
	  For $y = 0 To $FontHeight - 1
		 If _ColorCheck(_GetPixelColor($startX + $fontOffset + 1, $LevelTextY + $y), $FontColor, $DefaultTolerance) Then
			$found = True
			ExitLoop
		 EndIf
	  Next
	  If $found Then ExitLoop
   Next

   If $found = False Then Return -1

   $startX = $startX + $fontOffset

   For $i = $DigitCount - 1 To 0 Step -1

	  Local $digit = -1

	  ; Digit 0
	  If $digit < 0 Then
		 If _ColorCheck(_GetPixelColor($startX + 3, $LevelTextY + 8), $FontColor, $DefaultTolerance) Then
			If _ColorCheck(_GetPixelColor($startX + 3, $LevelTextY + 11), $FontColor, $DefaultTolerance) Then
			   If _ColorCheck(_GetPixelColor($startX + 3, $LevelTextY + 13), $FontColor, $DefaultTolerance) Then
				  $digit = 0
			   EndIf
			EndIf
		 EndIf
	  EndIf

	  ; Digit 3
	  If $digit < 0 Then
		 If _ColorCheck(_GetPixelColor($startX + 3, $LevelTextY + 7), $FontColor, $DefaultTolerance) Then
			If _ColorCheck(_GetPixelColor($startX + 3, $LevelTextY + 17), $FontColor, $DefaultTolerance) Then
			   If _ColorCheck(_GetPixelColor($startX + 3, $LevelTextY + 11), $FontColor, $DefaultTolerance) = False Then
				  $digit = 3
			   EndIf
			EndIf
		 EndIf
	  EndIf

	  If $digit < 0 Then Return -1

	  $res = $res + $digit * (10 ^ $i)
	  $startX += $FontWidth[$digit]
   Next

   Return $res
EndFunc

