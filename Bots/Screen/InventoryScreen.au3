#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         gunoodaddy

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

Func waitInventoryScreen()
   SetLog("Waiting for Inventory Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\inventory_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		; Re-click inventory button on MainScreen
		closeAllPopupOnMainScreen()
		clickInventoryButton()
		If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("Inventory Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next

   SetLog("Inventory Screen Timeout", $COLOR_RED)
   Return False
EndFunc
