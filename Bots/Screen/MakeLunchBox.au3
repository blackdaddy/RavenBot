
Local Const $ITEM_SORT_BUTTON_REGION[4] = [644, 420, 718, 451]
Local Const $MENU_ITEM_GRADE_BUTTON_REGION[4] = [652, 390, 718, 419]
Local Const $LEVELUP_SLOT_REGION[4] = [160, 185, 247, 225]
Local Const $LEVELUP_COMPLETE_OK_BUTTON_REGION[4] = [385, 382, 530, 420]
Local Const $MAX_LEVEL_COLOR = 0x6F4600
Local Const $ITEM_SELECTED_COLOR = 0xAE480D

Func makeLunchBox()
   SetLog("Making lunch box...", $COLOR_ORANGE)

   While True
	  _console("begin lunch box")
	  If _Sleep(500) Then Return False

	  sortItemGradeUp()

	  If _doLevelUpProcess() = False Then
		 SetLog("Completed to make lunchbox", $COLOR_BLUE)
		 ExitLoop
	  EndIf

	  _console("end lunch box")
   WEnd

   Return True
EndFunc


Func _doLevelUpProcess()
   If _isEmptyLevelUpItemSlot() Then
	  SetLog("Register level-up item", $COLOR_GREEN)

	  If _registerOneLevelUpItem() = False Then
		 SetLog("Failed to register level-up item.", $COLOR_RED)
		 Return False
	  EndIf
   EndIf

   _log("Select level-up items...")
   Local $stopFlag = False
   If _selectOneLevelUpItems($stopFlag) = False Then Return False

   _log("do level up : stop flag = " & $stopFlag)

   ; Do Level up
   For $i = 0 To $RetryWaitCountShort
	  _CaptureRegion()

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\greater_than_level_warning_text.BMP", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep(500) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_close.bmp"), $POPUP_BUTTON_REGION)
		 SetLog("Level-up canceled..", $COLOR_RED)
		 Return True
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

   If $stopFlag Then Return False

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


Func _registerOneLevelUpItem()
   Local $x, $y
   Local Const $ItemLevelCircleSize = 36
   For $i = 1 To 6
	  Local $bound = itemSlotBound($i)

	  Local $pos = _PixelSearch($bound[0], $bound[1], $bound[0] + $ItemLevelCircleSize, $bound[1] + $ItemLevelCircleSize, Hex($MAX_LEVEL_COLOR, 6), 20)
	  If IsArray($pos) = False Then

		 SetLog("Found level-up item : " & $i, $COLOR_DARKGREY)

		 If clickItem($i) = False Then Return False

 		 Local $itemLevel = getItemLevel()
		 _console("console : item level = " & $itemLevel)

		 If $itemLevel > $setting_item_lunch_maximum_level Then
			_console("console : failed item level = " & $itemLevel)
			clickItemInfoCloseButton()
			Return False
		 EndIf

		 _CaptureRegion()
		 If ClickButtonImage(@ScriptDir & "\images\blacksmith\button_register_levelup.bmp") = False Then
			_console("console : failed to click register button")
			Return False
		 EndIf

		 Return True
	  Else
		 _console("console : already max level item : " & $i)
	  EndIf
   Next

   Return False
EndFunc


Func _selectOneLevelUpItems(ByRef $stopFlag)
   Local $x, $y
   Local $pos
   Local $i = 1
   Local Const $ItemLevelCircleSize = 36
   Local Const $ItemSelectedMarkRegion[4] = [0, 0, 20, 20]
   Local $itemSelect[6] = [False, False, False, False, False, False]

   $stopFlag = False

   While $i < 7
	  If _Sleep(200) Then Return False
	  _CaptureRegion()

	  Local $bound = itemSlotBound($i)

 	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\max_selected_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep(500) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.BMP"), $POPUP_BUTTON_REGION)
		 ExitLoop
	  EndIf

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\reached_max_level_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep(500) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.BMP"), $POPUP_BUTTON_REGION)
		 ExitLoop
	  EndIf

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\beyond_level_warning_text.bmp", 0, $POPUP_TEXT_REGION, $x, $y, $DefaultTolerance) Then
		 If _Sleep(100) Then Return False
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.BMP"), $POPUP_BUTTON_REGION)
		 ContinueLoop
	  EndIf

	  $pos = _PixelSearch($bound[0] + $ItemSelectedMarkRegion[0], $bound[1] + $ItemSelectedMarkRegion[1], $bound[0] + $ItemSelectedMarkRegion[2], $bound[1] + $ItemSelectedMarkRegion[3], Hex($ITEM_SELECTED_COLOR, 6), 10)
	  If IsArray($pos) Then
		 $itemSelect[$i - 1] = True
		 $i = $i + 1
		 _console("console : already selected : slot = " & $i)
		 ContinueLoop
	  EndIf

	  Local $selectedCount = 0
	  For $ii = 0 To 5
		 If $itemSelect[$ii] Then $selectedCount = $selectedCount + 1
	  Next

	  If $selectedCount >= 5 Then
		 _console("Selected 5 items..")
		 ExitLoop
	  EndIf

	  $pos = _PixelSearch($bound[0], $bound[1], $bound[0] + $ItemLevelCircleSize, $bound[1] + $ItemLevelCircleSize, Hex($MAX_LEVEL_COLOR, 6), 20)
	  If IsArray($pos) = False Then
		 Click($bound[0] + 40, $bound[1] + 40)
		 If _Sleep(800) Then Return False
	  Else
		 _console("console : max level : slot = " & $i)
		 $i = $i + 1
		 ContinueLoop
	  EndIf
   WEnd

   Local $selectedCount = 0
   For $ii = 0 To 5
	  If $itemSelect[$ii] Then $selectedCount = $selectedCount + 1
   Next

   If $selectedCount <= 0 Then Return False

   Return True
EndFunc


Func _isEmptyLevelUpItemSlot()
   Local $x, $y
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
		 If _Sleep(500) Then Return False
		 ContinueLoop
	  EndIf

	  If ImageSearchArea(@ScriptDir & "\images\blacksmith\item_grade_up.BMP", 0, $ITEM_SORT_BUTTON_REGION, $x, $y, $DefaultTolerance) = False Then
		 Click(685, 438)
		 If _Sleep(500) Then Return False
		 ContinueLoop
	  Else
		 SetLog("Sorted item grade", $COLOR_BLUE)
		 Return True
	  EndIf
   Next

   SetLog("Sorting item grade Timeout", $COLOR_RED)
   Return False
EndFunc
