#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         gunoodaddy

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Local $BLACKSMITH_TAB_REGION[4] = [39, 80, 360, 122]
Local $INVENTORY_TAB1_BUTTON_POS[2] = [424, 85]
Local $INVENTORY_TAB2_BUTTON_POS[2] = [514, 85]
Local $INVENTORY_TAB3_BUTTON_POS[2] = [596, 85]
Local $INVENTORY_TAB4_BUTTON_POS[2] = [682, 85]
Local $ITEM_INFO_REGION[4] = [392, 102, 721, 300]
Local $ITEM_OPTION_REGION[4] = [498, 176, 718, 339]
Local $ITEM_INFO_CLOSE_BUTTON_REGION[4] = [693, 60, 729, 99]
Local $ITEM_INFO_LEVEL_CIRCLE_REGION[4] = [400, 112, 429, 142]
Local $LEVELUP_BUTTON_REGION[4] = [292, 393, 341, 428]

Local Const $ITEM_SORT_BUTTON_REGION[4] = [632, 414, 718, 451]
Local Const $MENU_ITEM_GRADE_BUTTON_REGION[4] = [652, 390, 718, 419]
Local Const $LEVELUP_SLOT_REGION[4] = [160, 185, 247, 225]
Local Const $LEVELUP_COMPLETE_OK_BUTTON_REGION[4] = [385, 382, 530, 420]
Local Const $MAX_LEVEL_COLOR = 0x6F4600
Local Const $ITEM_SELECTED_COLOR = 0xAE480D

Local Const $ItemLevelCircleWidth = 36
Local Const $ItemLevelCircleHeight = 53


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


Func cleanUpItems()
   SetLog("Started clean up items..", $COLOR_ORANGE)

   For $i = 1 To 4
	  Local $tabPos[2]
	  Switch $i
	  Case 1
		 $tabPos = $INVENTORY_TAB1_BUTTON_POS
	  Case 2
		 $tabPos = $INVENTORY_TAB2_BUTTON_POS
	  Case 3
		 $tabPos = $INVENTORY_TAB3_BUTTON_POS
	  Case 4
		 $tabPos = $INVENTORY_TAB4_BUTTON_POS
	  EndSwitch

	  ClickPos($tabPos, $SleepWaitMSecShort)

	  Local $currDragCount = 0

	  While True
		 SetLog("Item level-up loop started : dragging = " & $currDragCount, $COLOR_GREEN)
		 If _Sleep($SleepWaitMSecShort) Then Return False

		 If _removeLevelUpItemSlot() = False Then Return False

		 If sortItemGradeUp() = False Then Return False

		 _doDragItemList($currDragCount)

		 Local $stopFlag = False
		 If _doLevelUpProcess($stopFlag, $currDragCount) = False Then
			SetLog("Completed clean-up items : $stopFlag = " & $stopFlag, $COLOR_BLUE)

			If $stopFlag = False Then
			   WinActivate($Title)

			   $currDragCount = $currDragCount + 1
			   If $currDragCount > $setting_cleanup_drag_count Then ExitLoop
			   ContinueLoop
			EndIf
			ExitLoop
		 EndIf
	  WEnd

   Next

   Return True
EndFunc


Func _doDragItemList($count)

   If $count <= 0 Then Return

   For $i = 1 To $count
	  WinActivate($Title)
	  WinMove($Title, "", 0, 0)
	  _Sleep(50)
	  MouseClickDrag("left", 556, 409, 556, 24, 50)
	  _Sleep(500)
   Next
EndFunc


Func _removeLevelUpItemSlot()
   For $i = 0 To $RetryWaitCountShort
	  Click(161, 102)
	  If _Sleep(400) Then Return False
  	  Click(74, 102)
	  If _Sleep($SleepWaitMSecVeryFast) Then Return False

	  If ClickButtonImageArea(String(@ScriptDir & "\images\blacksmith\button_tab_levelup.bmp"), $BLACKSMITH_TAB_REGION, False) = False Then
		 ContinueLoop
	  EndIf

	  If _isEmptyLevelUpItemSlot() Then
		 Return True
	  EndIf
   Next

   Return False
EndFunc

Func _doLevelUpProcess(ByRef $stopFlag, $currDragCount)

   SetLog("Started clean-up items", $COLOR_ORANGE)

   If _isEmptyLevelUpItemSlot() = False Then
	   SetLog("Item already registered..", $COLOR_RED)
	   $stopFlag = True
	   Return False
	EndIf

   Local $preferredItemSlotIndex = 0
   Local $availableItemSlots = _findOneLevelUpItem($preferredItemSlotIndex, $stopFlag)

   If IsArray($availableItemSlots) = False Then
	  ; Complete all task... stop..
	  Return False
   EndIf

   If $preferredItemSlotIndex < 0 OR $preferredItemSlotIndex >= 6 Then
	  Return False
   EndIf

   $availableItemSlots[$preferredItemSlotIndex] = False

   ; Shift array
   For $ii = $preferredItemSlotIndex + 1 To 5
	  If $ii > 0 Then
		 $availableItemSlots[$ii - 1] = $availableItemSlots[$ii]
	  EndIf
	  $availableItemSlots[$ii] = False
   Next

   ; Click the item to register for level-up
   SetLog("Register item : slot = " & ($preferredItemSlotIndex + 1), $COLOR_DARKGREY)
   clickItem($preferredItemSlotIndex + 1)

   ; Register to level up
   _CaptureRegion()
   If ClickButtonImage(@ScriptDir & "\images\blacksmith\button_register_levelup.bmp") = False Then
	  _log("console : failed to click register button : " & ($preferredItemSlotIndex + 1))
	  $stopFlag = True
	  Return False	; unexpected case...
   EndIf

   If _Sleep(1000) Then
	  $stopFlag = True
	  Return False
   EndIf

   _CaptureRegion()

   If ImageSearchArea(@ScriptDir & "\images\blacksmith\already_max_level_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
	  If _Sleep(500) Then Return False
	  ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $POPUP_BUTTON_REGION)
	  SetLog("Bad clicked. Max item selected.", $COLOR_RED)
	  $stopFlag = True
	  Return False
   EndIf

   ; For logging
   Local $resStr = ""
   For $i = 0 To 5
	  If $availableItemSlots[$i] Then
		 $resStr = $resStr & ($i+1) & " : "
	  EndIf
   Next

   _doDragItemList($currDragCount)

   ; Select items to eat
   _log("Select level-up items : " & $resStr & " after dragging " & $currDragCount & " count")
   If _selectLevelUpAllItems($availableItemSlots) = False Then Return False

   _CaptureRegion()
   If ImageSearchArea(@ScriptDir & "\images\blacksmith\no_selected_levelup_items.BMP", 0, $LEVELUP_BUTTON_REGION, $x, $y, $DefaultTolerance) Then
	  SetLog("No selected level-up items..", $COLOR_RED)
	  Return False
   EndIf

   ; Do Level up
   _log("do level up...")
   For $i = 0 To $RetryWaitCountShort
	  _CaptureRegion()

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\greater_than_level_warning_text.BMP", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep(500) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_close.bmp"), $POPUP_BUTTON_REGION)
		 SetLog("Level-up canceled..", $COLOR_RED)
		 $stopFlag = True
		 Return False
	  EndIf

	  If ClickButtonImage(@ScriptDir & "\images\blacksmith\button_levelup.bmp") Then
		 ContinueLoop
	  EndIf

	  If ClickButtonImageArea(String(@ScriptDir & "\images\blacksmith\button_levelup_ready.bmp"), $BOTTOM_OK_BUTTON_REGION) Then
		 ContinueLoop
	  EndIf

	  If ClickButtonImageArea(String(@ScriptDir & "\images\blacksmith\button_levelup_ok.bmp"), $LEVELUP_COMPLETE_OK_BUTTON_REGION) Then
		 SetLog("Level-up ok.", $COLOR_GREEN)
		 Return True
	  EndIf

	  If _Sleep($SleepWaitMSecShort) Then Return False
   Next

   $stopFlag = True
   Return False
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

		 Local $itemLevel = getItemLevel()

		 If $itemLevel >= $setting_loot_capture_level Then
			_log("@@@@@@@ Loot Item @@@@@@@ : " & $itemLevel)
			 _CaptureRegionArea($ITEM_INFO_REGION)
			SaveImageToFile("loot_" & $itemLevel, $dirLoots, "bmp");
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

   For $i = 0 To $RetryWaitCountShort

	  _CaptureRegion()
	  If ImageSearchArea(@ScriptDir & "\images\button_x.bmp", 0, $ITEM_INFO_CLOSE_BUTTON_REGION, $x, $y, $DefaultTolerance) Then
		 Return True
	  EndIf

	  If checkDuplicatedConnection() = False Then
		 If ClickButtonImage(@ScriptDir & "\images\button_ok.bmp") Then
			SetLog("Unexpected sell button detected..", $COLOR_RED)
		 EndIf
	  EndIf

	  Local $posX, $posY
	  Switch $itemSlotNumber
		 Case 1
			$posX = 453
			$posY = 197
		 Case 2
			$posX = 553
			$posY = 197
		 Case 3
			$posX = 653
			$posY = 197
		 Case 4
			$posX = 453
			$posY = 353
		 Case 5
			$posX = 553
			$posY = 353
		 Case 6
			$posX = 653
			$posY = 353
	  EndSwitch

	  Switch Mod($i, 3)
		 Case 1
			$posY = $posY + 10
		 Case 2
			$posY = $posY - 10
	  EndSwitch

	  Click($posX, $posY)

	  If _Sleep($SleepWaitMSecVeryFast) Then Return False
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


Func closeAllUIForLunchBox()
   _CaptureRegion()

   If ImageSearchArea(@ScriptDir & "\images\blacksmith\greater_than_level_warning_text.BMP", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
	  ClickButtonImageArea(String(@ScriptDir & "\images\button_close.bmp"), $POPUP_BUTTON_REGION)
	  SetLog("Level-up Close button detected.", $COLOR_PINK)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\blacksmith\button_menu_item_grade.BMP"), $MENU_ITEM_GRADE_BUTTON_REGION) Then
	  SetLog("Menu button detected.", $COLOR_PINK)
	  Return True
   EndIf

   If ClickButtonImageArea(String(@ScriptDir & "\images\blacksmith\button_levelup_ok.bmp"), $LEVELUP_COMPLETE_OK_BUTTON_REGION) Then
	  SetLog("Level-up ok button detected.", $COLOR_PINK)
	  Return True
   EndIf

   Return False
EndFunc


Func _findOneLevelUpItem(ByRef $preferredIndex, ByRef $stopFlag)
   Local $x, $y

   $preferredIndex = -1

   Local $availableItemSlots[6] = [False, False, False, False, False, False]
   Local $itemSlotNumber = 1
   While $itemSlotNumber <= 6
	  Local $bound = itemSlotBound($itemSlotNumber)

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\empty_slot.BMP", 0, $bound, $x, $y, $DefaultTolerance/2) Then
		 SetLog("Checking item " & $itemSlotNumber & ": empty", $COLOR_DARKGREY)
		 $stopFlag = True
		 ExitLoop
	  EndIf

	  Local $pos = _PixelSearch($bound[0], $bound[1], $bound[0] + $ItemLevelCircleWidth, $bound[1] + $ItemLevelCircleHeight, Hex($MAX_LEVEL_COLOR, 6), 10)

	  If IsArray($pos) = False Then

		 If clickItem($itemSlotNumber) = False Then Return 0

 		 Local $itemLevel = getItemLevel()
		 _console("console : item level = " & $itemSlotNumber & ", level = " & $itemLevel)

		 If _checkThisItemOptions() = False Then
			SetLog("Checking item " & $itemSlotNumber & ": important", $COLOR_BLUE)
			$itemSlotNumber = $itemSlotNumber + 1
			ContinueLoop
		 EndIf

		 If $itemLevel <= $setting_item_sell_maximum_level OR $itemLevel < $setting_item_lunch_maximum_level Then
			_log("$$$$$$$ Item sold $$$$$$$ : " & $itemLevel & ":" & $setting_item_sell_maximum_level & ":" & $setting_item_lunch_maximum_level)

			; Item sold to level up
			If _sellThisItem() = False Then
			   clickItemInfoCloseButton()
			   Return 0	; failed.. unexpected screen status
			EndIf

			SetLog("Checking item " & $itemSlotNumber & ": sold", $COLOR_DARKGREY)

			ContinueLoop
		 Else

			If $itemLevel > $setting_item_lunch_maximum_level Then
			   _console("console : failed item level = " & $itemLevel)
   			   SetLog("Checking item " & $itemSlotNumber & ": level limited", $COLOR_PINK)

			   $itemSlotNumber = $itemSlotNumber + 1
			   If clickItemInfoCloseButton() = False Then Return 0

			   ; Loop Stop... we don't have to do any more...
			   $stopFlag = True
			   ExitLoop
			Else
			   _log("####### Item level-up register ####### : " & $itemSlotNumber & " = " & $itemLevel & " <> " & $setting_item_sell_maximum_level )
			   SetLog("Checking item " & $itemSlotNumber & ": food", $COLOR_GREEN)

			   If _isThisLevelOneItem() = False Then
				  If $preferredIndex < 0 Then $preferredIndex = $itemSlotNumber - 1
			   EndIf

			   $availableItemSlots[$itemSlotNumber - 1] = True
			   $itemSlotNumber = $itemSlotNumber + 1

			   If clickItemInfoCloseButton() = False Then Return 0
			EndIf
		 EndIf
	  Else
		 SetLog("Checking item " & $itemSlotNumber & ": max", $COLOR_PURPLE)

		 _console("console : already max level item : " & $itemSlotNumber)
		 $itemSlotNumber = $itemSlotNumber + 1
	  EndIf
   WEnd

   Local $count = 0
   Local $resStr = ""
   For $i = 0 To 5
	  If $availableItemSlots[$i] Then

		 If $count == 0 AND $preferredIndex < 0 Then
			$preferredIndex = $i
		 EndIf

		 $resStr = $resStr & ($i+1) & " : "
		 $count = $count + 1
	  EndIf
   Next

   _log("Item check result : " & $resStr)

   If StringLen($resStr) > 0 AND $count > 1 Then Return $availableItemSlots

   Return 0
EndFunc


Func _isThisLevelOneItem()
   Local $x, $y
   _CaptureRegion()
   If ImageSearchArea(@ScriptDir & "\images\blacksmith\level_1_text.bmp", 0, $ITEM_INFO_LEVEL_CIRCLE_REGION, $x, $y, $DefaultTolerance) Then
	  Return True
   EndIf
   Return False
EndFunc


Func _selectOneLevelUpItem($itemSlot, ByRef $stopFlag)
   Local $x, $y
   Local $pos
   Local $i = 1
   Local Const $ItemSelectedMarkRegion[4] = [0, 0, 20, 20]

   $stopFlag = False

   For $i = 0 To $RetryWaitCountShort
	  If _Sleep($SleepWaitMSecVeryFast) Then Return False
	  _CaptureRegion()

	  Local $bound = itemSlotBound($itemSlot)

 	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\max_selected_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep($SleepWaitMSecVeryFast) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.BMP"), $POPUP_BUTTON_REGION)
		 $stopFlag = True
		 Return True
	  EndIf

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\reached_max_level_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep($SleepWaitMSecVeryFast) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.BMP"), $POPUP_BUTTON_REGION)
		 $stopFlag = True
		 Return True
	  EndIf

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\beyond_level_warning_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep($SleepWaitMSecVeryFast) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.BMP"), $POPUP_BUTTON_REGION)
		 $stopFlag = True
		 Return True
	  EndIf

	  $pos = _PixelSearch($bound[0] + $ItemSelectedMarkRegion[0], $bound[1] + $ItemSelectedMarkRegion[1], $bound[0] + $ItemSelectedMarkRegion[2], $bound[1] + $ItemSelectedMarkRegion[3], Hex($ITEM_SELECTED_COLOR, 6), 10)
	  If IsArray($pos) Then
		 _console("console : item selected : slot = " & $i)
		 Return True
	  EndIf

	  $pos = _PixelSearch($bound[0], $bound[1], $bound[0] + $ItemLevelCircleWidth, $bound[1] + $ItemLevelCircleHeight, Hex($MAX_LEVEL_COLOR, 6), 20)
	  If IsArray($pos) = False Then
		 Click($bound[0] + 40, $bound[1] + 40)
		 If _Sleep($SleepWaitMSecShort) Then Return False
		 ContinueLoop
	  Else
		 _console("console : max level : slot = " & $i)
		 Return True	; unexpected case. failed to study this item. but we just skip this item. so return true!
	  EndIf
   Next

   Return False
EndFunc


Func _selectLevelUpAllItems($availableItemSlots)
   Local $i = 0
   For $i = 0 To 5
	  If $availableItemSlots[$i] = False Then ContinueLoop

	  _console("selecting item.. : " & ($i + 1))

	  Local $stopFlag = False
	  If _selectOneLevelUpItem($i + 1, $stopFlag) = False Then
		 _console("Error select item.. : " & ($i + 1))
		 Return False
	  EndIf

	  If $stopFlag Then Return True

	  If _Sleep($SleepWaitMSecVeryFast) Then Return False
   Next

   Return True
EndFunc


Func _isEmptyLevelUpItemSlot()
   Local $x, $y
   _CaptureRegion()
   If ImageSearchArea(@ScriptDir & "\images\blacksmith\register_levelup_item.bmp", 0, $LEVELUP_SLOT_REGION, $x, $y, $DefaultTolerance) Then
	  Return True
   EndIf
   Return False
EndFunc


Func sortItemGradeUp()
   Local $x, $y

   SetLog("Sorting item grade by ASC...", $COLOR_ORANGE)

   For $i = 0 To $RetryWaitCount
	   _CaptureRegion()

	  If ClickButtonImageArea(String(@ScriptDir & "\images\blacksmith\button_menu_item_grade.BMP"), $MENU_ITEM_GRADE_BUTTON_REGION) Then
		 If _Sleep($SleepWaitMSecVeryFast) Then Return False
		 ContinueLoop
	  EndIf

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\item_grade_up.BMP", 0, $ITEM_SORT_BUTTON_REGION, $x, $y, $DefaultTolerance) = False Then
		 If ImageSearchArea(@ScriptDir & "\images\blacksmith\button_sort.bmp", 0, $ITEM_SORT_BUTTON_REGION, $x, $y, $DefaultTolerance) Then
			Click(685, 438)
			If _Sleep($SleepWaitMSecVeryFast) Then Return False
			ContinueLoop
		 Else
			SetLog("Could not click the sort button..", $COLOR_RED)
			Return False
		 EndIf
	  Else
		 SetLog("Sorted item grade", $COLOR_BLUE)
		 If _Sleep($SleepWaitMSecVeryFast) Then Return False
		 Return True
	  EndIf
   Next

   SetLog("Sorting item grade Timeout", $COLOR_RED)
   Return False
EndFunc


Func _checkThisItemOptions()
   Local $x, $y
   _CaptureRegion()
   For $i = 0 To $SETTING_IMPORTANT_ITEM_OPTION_COUNT - 1
	  Local $fileName = @ScriptDir & "\images\blacksmith\options\" & $SETTING_IMPORTANT_ITEM_OPTION_NAME[$i] & ".bmp"

	  If ImageSearchArea($fileName, 0, $ITEM_OPTION_REGION, $x, $y, $DefaultTolerance) Then
		 Return False
	  EndIf
   Next

   Return True
EndFunc