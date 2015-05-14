#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         gunoodaddy

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Local $INVENTORY_TAB1_BUTTON_POS[2] = [448, 85]
Local $INVENTORY_TAB2_BUTTON_POS[2] = [548, 85]
Local $INVENTORY_TAB3_BUTTON_POS[2] = [648, 85]
Local $ITEM_INFO_REGION[4] = [392, 102, 721, 300]
Local $ITEM_INFO_CLOSE_BUTTON_REGION[4] = [693, 60, 729, 99]

Func waitBlacksmithScreen()
   SetLog("Waiting for Blacksmith Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\blacksmith_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

         ; Re-click blacksmith button on MainScreen
		 closeAllPopupOnMainScreen(False, False)
		 clickBlackSmithButton()
		 If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("Blacksmith Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next

   SetLog("Blacksmith Screen Timeout", $COLOR_RED)
   Return False
EndFunc


Func getItemLevel()
   Local $x, $y

   _CaptureRegion()

   Local $color[6] = [0x888888, 0x3FAC4A, 0x2B587A, 0x9B4092, 0xD63929, 0xE6AF00]

   For $i = 0 To 5
	  Local $pos = _PixelSearch(430, 260, 465, 275, Hex($color[$i], 6), 20)
	  If IsArray($pos) Then
		 _log("Item level : " & ($i + 1) )
		 Return $i + 1
	  EndIf
   Next

    _log("Item level not found" )
EndFunc


Func sellItems(ByRef $newBadgeCount)
   SetLog("Started selling items..", $COLOR_ORANGE)

   Local $x, $y

   $newBadgeCount = 0

   For $i = 1 To 3
	  Local $tabPos[2]
	  Switch $i
	  Case 1
		 $tabPos = $INVENTORY_TAB1_BUTTON_POS
	  Case 2
		 $tabPos = $INVENTORY_TAB2_BUTTON_POS
	  Case 3
		 $tabPos = $INVENTORY_TAB3_BUTTON_POS
	  EndSwitch

	  ClickPos($tabPos, 1000)

	  ; Check if new badge exist
	  _Sleep(1000)
	  _CaptureRegion()
	  If _ImageSearchArea(@ScriptDir & "\images\new_badge_small.bmp", 0, 387, 107, 728, 428, $x, $y, $DefaultTolerance + 10) = False Then
		 SetLog("New badge not found : " & $i, $COLOR_DARKGREY)

		 ;$hGraphic = _GDIPlus_GraphicsCreateFromHWND($mainView)
		 ;_GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)
		 ContinueLoop
	  EndIf

	  $newBadgeCount = $newBadgeCount + 1
	  ;_changeListSort()

	  ; Sell items
	  Local $itemSlotNumber = 1
	  While $itemSlotNumber <= 6
		 If _checkNewBadge($itemSlotNumber) = False Then
			_console("New badge not found in Item : " & $itemSlotNumber)
			$itemSlotNumber = $itemSlotNumber + 1
			ContinueLoop
		 EndIf

		 If clickItem($itemSlotNumber) = False Then
			_log("Failed to click item : " & $itemSlotNumber)
			ExitLoop
		 EndIf

		 _WaitItemDetailScreen($itemSlotNumber)

		 Local $itemLevel = getItemLevel()

		 If $itemLevel >= $setting_loot_capture_level Then
			_log("@@@@@@@ Loot Item @@@@@@@ : " & $itemLevel)
			 _CaptureRegionArea($ITEM_INFO_REGION)
			SaveImageToFile("loot_" & $itemLevel, $dirLoots, "jpg");
		 EndIf

		 If $itemLevel <= $setting_item_sell_maximum_level Then
			_log("$$$$$$$ Item sold $$$$$$$ : " & $itemLevel & $setting_item_sell_maximum_level )

			If _sellThisItem() = False Then
			   $itemSlotNumber = $itemSlotNumber + 1
			   If clickItemInfoCloseButton() = False Then Return False
			EndIf
		 Else
			$itemSlotNumber = $itemSlotNumber + 1
			If clickItemInfoCloseButton() = False Then Return False
		 EndIf

		 _Sleep(1200)
	  WEnd

   Next

   Return True
EndFunc


Func _WaitItemDetailScreen($itemSlotNumber)

   Local $image = @ScriptDir & "\images\button_x.bmp"
   Local $bound = [690, 57, 734, 97]

   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y

	  If _ImageSearchArea($image, 0, $bound[0], $bound[1], $bound[2], $bound[3], $x, $y, $DefaultTolerance + 20) Then
		 ; Success
		 Return True
	  Else
		 clickItem($itemSlotNumber)

		 If checkDuplicatedConnection() = False Then
			If ClickButtonImage(@ScriptDir & "\images\button_ok.bmp") Then
			   SetLog("Unexpected sell button detected..", @COLOR_RED)
			EndIf
		 EndIf

		 If _Sleep($SleepWaitMSec) Then Return False
	  EndIf
   Next

   Return False

EndFunc	;==>_WaitItemDetailScreen


Func _changeListSort()
   _Sleep(500)
   Click(683, 438)
   _Sleep(1000)
   Click(683, 408)

   _Sleep(1000)
   Click(683, 438)
   _Sleep(1000)
   Click(683, 408)
EndFunc


Func _sellThisItem()
   _Sleep(700)
   _CaptureRegion()
   If ClickButtonImage(@ScriptDir & "\images\button_sell.bmp") Then
	  _Sleep(300)
	  _CaptureRegion()
	  $itemSoldCount = $itemSoldCount + 1
	  updateStats()

	  If checkDuplicatedConnection() = False Then
		 If ClickButtonImage(@ScriptDir & "\images\button_ok.bmp") Then Return True
	  EndIf
   EndIf

   Return False
EndFunc


Func itemSlotBound($itemSlotNumber)
   Local $posX, $posY
   Local $itemW = 94
   Local $itemH = 107

   Switch $itemSlotNumber
	  Case 1
		 $posX = 402
		 $posY = 116
	  Case 2
		 $posX = 506
		 $posY = 116
	  Case 3
		 $posX = 610
		 $posY = 116
	  Case 4
		 $posX = 402
		 $posY = 289
	  Case 5
		 $posX = 506
		 $posY = 289
	  Case 6
		 $posX = 610
		 $posY = 289
   EndSwitch

   Local $bound[4]
   $bound[0] = $posX
   $bound[1] = $posY
   $bound[2] = $posX + $itemW
   $bound[3] = $posY + $itemH
   return $bound
EndFunc

Func _checkNewBadge($itemSlotNumber)
   Local $x, $y

   Local $bound = itemSlotBound($itemSlotNumber)

   If ImageSearchArea(@ScriptDir & "\images\new_badge_small.bmp", 0, $bound, $x, $y, $DefaultTolerance + 10) Then
	  Return True
   EndIf

   Return False
EndFunc

Func clickItem($itemSlotNumber)

   Local $x, $y

   For $i = 0 To $RetryWaitCount

	  _CaptureRegion()
	  If ImageSearchArea(@ScriptDir & "\images\button_x.bmp", 0, $ITEM_INFO_CLOSE_BUTTON_REGION, $x, $y, $DefaultTolerance) Then
		 Return True
	  EndIf

	  Switch $itemSlotNumber
		 Case 1
			Click(453, 197)
		 Case 2
			Click(553, 197)
		 Case 3
			Click(653, 197)
		 Case 4
			Click(453, 353)
		 Case 5
			Click(553, 353)
		 Case 6
			Click(653, 353)
	  EndSwitch

	  If _Sleep(1000) Then Return False
   Next

   Return True
EndFunc


Func clickItemInfoCloseButton()
   _Sleep(700)
    _CaptureRegion()
   If ClickButtonImage(@ScriptDir & "\images\button_x.bmp") = False Then
	  SetLog("Unexpected case : x button not found", $COLOR_RED)
	  Return False;
   EndIf
   Return True
EndFunc
