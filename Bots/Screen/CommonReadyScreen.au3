; Adventure Ready Window Spot Image Region
Local Const $ADVENTURE_BUFF_REGION[4] = [397, 64, 717, 204]

Local Const $ADVENTURE_START_BUTTON_POS[2] = [572, 429]
Local Const $ADVENTURE_GIFT_BUTTON_POS[2] = [649, 323]

; Buff Item position
Local Const $ADVENTURE_BUFF1_POS[2] = [435, 148]
Local Const $ADVENTURE_BUFF2_POS[2] = [520, 148]
Local Const $ADVENTURE_BUFF3_POS[2] = [590, 148]
Local Const $ADVENTURE_BUFF4_POS[2] = [660, 148]

Local Const $LOAD_COMPLETE_COLOR[1][4] = [[414, 247, 0x1E150E, 10]]


Func selectBuffItem($battleId)
   _log("Waiting for Battle Ready Screen to use buff items")

   If waitBattleReadyScreen() = False Then
	  SetLog("Failed to locate Battle Ready Screen.", $COLOR_RED)
	  Return False
   EndIf

   SetLog("Selecting buff items...", $COLOR_ORANGE)

   If _Sleep(2000) Then Return True	; to avoid loading status

   _CaptureRegion()

   Local $nouseBuff1 = ImageSearchArea(String(@ScriptDir & "\images\buff_item_1.bmp"), 0, $ADVENTURE_BUFF_REGION, $x, $y, 80);
   Local $nouseBuff2 = ImageSearchArea(String(@ScriptDir & "\images\buff_item_2.bmp"), 0, $ADVENTURE_BUFF_REGION, $x, $y, 80);
   Local $nouseBuff3 = ImageSearchArea(String(@ScriptDir & "\images\buff_item_3.bmp"), 0, $ADVENTURE_BUFF_REGION, $x, $y, 80);
   Local $nouseBuff4 = ImageSearchArea(String(@ScriptDir & "\images\buff_item_4.bmp"), 0, $ADVENTURE_BUFF_REGION, $x, $y, 80);

   _log("Current buff item status : " & $nouseBuff1 & ", " & $nouseBuff2 & ", " & $nouseBuff3 & ", " & $nouseBuff4 )

   Local $useBuff1 = $setting_use_buff_items[$battleId][0]
   Local $useBuff2 = $setting_use_buff_items[$battleId][1]
   Local $useBuff3 = $setting_use_buff_items[$battleId][2]
   Local $useBuff4 = $setting_use_buff_items[$battleId][3]

   if $useBuff1 = $nouseBuff1 Then
	  ClickPos($ADVENTURE_BUFF1_POS, 1000)
	  SetLog("Select buff items 1 : " & $setting_use_buff_items[$battleId][0], $COLOR_DARKGREY)
   EndIf

   if $useBuff2 = $nouseBuff2 Then
	  ClickPos($ADVENTURE_BUFF2_POS, 1000)
	  SetLog("Select buff items 2 : " & $setting_use_buff_items[$battleId][1], $COLOR_DARKGREY)
   EndIf

   if $useBuff3 = $nouseBuff3 Then
	  ClickPos($ADVENTURE_BUFF3_POS, 1000)
	  SetLog("Select buff items 3 : " & $setting_use_buff_items[$battleId][2], $COLOR_DARKGREY)
   EndIf

   if $useBuff4 = $nouseBuff4 Then
	  ClickPos($ADVENTURE_BUFF4_POS, 1000)
	  SetLog("Select buff items 4 : " & $setting_use_buff_items[$battleId][3], $COLOR_DARKGREY)
   EndIf

   Return True
EndFunc	;==>selectBuffItem


Func waitBattleReadyScreen($checkOne = False)

   Local $x, $y
   Local $image = @ScriptDir & "\images\screen_battle_ready.bmp"
   Local $bound = [395, 63, 725, 99]

   For $i = 0 To $RetryWaitCountShort
	  _CaptureRegion()

	  Local $x, $y

	  If _ImageSearchArea($image, 0, $bound[0], $bound[1], $bound[2], $bound[3], $x, $y, $DefaultTolerance + 20) Then
		 ; Success
		 If $checkOne Then Return True

		 _Sleep(1000)

		 ; But we need to check the loading status..
		 If WaitScreenPixel($LOAD_COMPLETE_COLOR, True) Then
			Return True
		 Else
			SetLog("Loading icon detected.", $COLOR_PINK)
		 EndIf
	  Else
		 If $checkOne Then ExitLoop

		 ; TODO : known issue : this ready button is only working from Adventure Battle mode......
		 ; Dirty codes.....
		 _clickReadyButton()	; refer to AdventureScreen.au3
	  EndIf

Next

   Return False

EndFunc	;==>waitBattleReadyScreen


Func clickBattleStartButton($firstCall = True)
   ClickPos($ADVENTURE_GIFT_BUTTON_POS, 1000, 3)
   ClickPos($ADVENTURE_START_BUTTON_POS, 1000)
   If $firstCall Then
	  SetLog("Starting battle...", $COLOR_ORANGE)
   EndIf
EndFunc