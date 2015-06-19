#pragma compile(FileDescription, Raven Bot)
#pragma compile(ProductName, Raven Bot)
#pragma compile(ProductVersion, 2.3)
#pragma compile(FileVersion, 2.3)
#pragma compile(LegalCopyright, ?The Bytecode Club)

$sBotName = "Raven Bot"
$sBotVersion = "2.3"
$sBotTitle = "AutoIt " & $sBotName & " v" & $sBotVersion

If _Singleton($sBotTitle, 1) = 0 Then
   MsgBox(0, "", "Bot is already running.")
   Exit
EndIf

#include <Bots/GlobalVariables.au3>
#include <Bots/Form/MainView.au3>
#include <Bots/Config.au3>
#include <Bots/GameManager.au3>
#include <Bots/AutoFlow.au3>
#include <Bots/Stats.au3>
#include <Bots/Screen/MainScreen.au3>
#include <Bots/Screen/AdventureScreen.au3>
#include <Bots/Screen/CommonBattleScreen.au3>
#include <Bots/Screen/CommonReadyScreen.au3>
#include <Bots/Screen/RaidScreen.au3>
#include <Bots/Screen/InventoryScreen.au3>
#include <Bots/Screen/BlackSmithScreen.au3>
#include <Bots/Screen/PvPScreen.au3>
#include <Bots/Screen/GuildScreen.au3>
#include <Bots/Screen/DailyScreen.au3>
#include <Bots/Screen/AdventureStageScreen.au3>
#include <Bots/Util/SetLog.au3>
#include <Bots/Util/Time.au3>
#include <Bots/Util/CreateLogFile.au3>
#include <Bots/Util/_Sleep.au3>
#include <Bots/Util/Click.au3>
#include <Bots/Util/getBSPos.au3>
#include <Bots/Util/FindPos.au3>
#include <Bots/Util/WaitScreen.au3>
#include <Bots/Util/Wheel.au3>
#include <Bots/Util/SaveImageToFile.au3>
#include <Bots/Util/Image Search/ImageSearch.au3>
#include <Bots/Util/Pixels/_CaptureRegion.au3>
#include <Bots/Util/Pixels/_ColorCheck.au3>
#include <Bots/Util/Pixels/_GetPixelColor.au3>
#include <Bots/Util/Pixels/_MultiPixelSearch.au3>
#include <Bots/Util/Pixels/_PixelSearch.au3>
#include <Bots/Util/Pixels/_WaitForPixel.au3>
#include <Bots/Util/Pixels/boolPixelSearch.au3>
#include-once

Opt("MouseCoordMode", 2)
Opt("GUICoordMode", 2)
Opt("GUIResizeMode", 1)
Opt("GUIOnEventMode", 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "mainViewClose", $mainView)
GUIRegisterMsg($WM_COMMAND, "GUIControl")
GUIRegisterMsg($WM_SYSCOMMAND, "GUIControl")

; Initialize
DirCreate($dirLogs)
DirCreate($dirCapture)
DirCreate($dirLoots)
DirCreate($dirTrain)

_GDIPlus_Startup()
CreateLogFile()

loadConfig()
applyConfig()

clearStats()
updateStats()
updateTotalElapsed()

If $setting_win_x <> -1 AND $setting_win_y <> -1 AND $setting_win_x <> -32000 OR $setting_win_y <> -32000  Then
   WinMove($mainView, "", $setting_win_x, $setting_win_y)
EndIf

GUISetState(@SW_SHOW, $mainView)

If $setting_auto_start Then
   btnStart()
EndIf

; Just idle around
While 1
   Sleep(10)
WEnd

_log("Bye!")

Func GUIControl($hWind, $iMsg, $wParam, $lParam)
	Local $nNotifyCode = BitShift($wParam, 16)
	Local $nID = BitAND($wParam, 0x0000FFFF)
	Local $hCtrl = $lParam
	#forceref $hWind, $iMsg, $wParam, $lParam
	Switch $iMsg
	  Case 273
		Switch $nID
			Case $GUI_EVENT_CLOSE
			   mainViewClose();
			Case $btnStop
			   btnStop()
			Case $btnScreenShot
			   btnScreenShot()
			Case $checkAutoStart
			   saveConfig()
			   loadConfig()
			   applyConfig()
			EndSwitch
		Case 274
			Switch $wParam
			   Case 0xf060
				  mainViewClose();
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>GUIControl

 contolsettext

; Main Auto Flow
Func runBot()
   _log("START" )
   SetLog("Welcome to " & $sBotTitle, $COLOR_PURPLE)
   SetLog($Compiled & " running on " & @OSArch & " OS", $COLOR_GREEN)
   SetLog("Bot is starting...", $COLOR_ORANGE)

   Local $iSec, $iMin, $iHour
   Local $firstFlag = True

   clearStats()
   updateStats()

   While $RunState

	  If ProcessExists($ProcessName) = False Then

		 SetLog($Title & " starting...", $COLOR_ORANGE)

		 runBlueStack()

		 If _Sleep(5000) Then Return ExitLoop

		 ContinueLoop	; restart loop
	  Else
		 If isValidRunningEmulator() = False Then
			SetLog($Title & " initializing...", $COLOR_ORANGE)

			If _Sleep(5000) Then Return ExitLoop
			ContinueLoop	; restart loop
		 EndIf

		 If Initiate() = False Then
			SetLog("Restarting BlueStack..", $COLOR_RED)
			killBlueStack()
			If _Sleep(2000) Then Return ExitLoop
			ContinueLoop	; restart loop
		 EndIf
	  EndIf

	  WinMove($Title, "", 0, 0)
	  WinActivate($Title)

	  Local $hTimer = TimerInit()

	  $Restart = False

	  ; Config re-apply
      saveConfig()
      loadConfig()
	  applyConfig()

	  If $firstFlag AND $testMode = False Then
		 SetLog("Checking start screen...", $COLOR_ORANGE)
		 Local $tempCount = 1
		 For $tempCount = 1 To 20
			If closeAllPopupOnMainScreen(True) = False Then
			   SetLog("Start screen located.", $COLOR_BLUE)
			   ExitLoop
			EndIf
			If _Sleep(2000) Then ExitLoop
		 Next

		 SetLog("Start Loop : " & $loopCount + 1, $COLOR_PURPLE)
	  EndIf

	  $firstFlag = False

	  Local $res = AutoFlow()

	  If $res = False Then
		 If $RunState = True Then
			SetLog("Error occurred..", $COLOR_RED)
		 EndIf

		 $errorCount = $errorCount + 1
		 $totalErrorCount = $totalErrorCount + 1
		 updateStats()

		 If $errorCount = 1 Then
			; only saved screen shot at first error
			SaveImageToFile()
		 EndIf

		 If $errorCount >= $RestartAppErrorCount Then
			SaveImageToFile("max_error")
			killBlueStack()
			SetLog("Kill the bluestack to resolve the error.", $COLOR_RED)
		 EndIf
	  Else
		 $errorCount = 0
		 $loopCount = $loopCount + 1

		 Local $time = _TicksToTime(Int(TimerDiff($hTimer)), $iHour, $iMin, $iSec)

		 $lastElapsed = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)

		 updateStats()

		 ; Success and go to first
		 If $loopCount > 0 Then
			_GUICtrlEdit_SetText($txtLog, "")
		 EndIf
		 SetLog("Start Loop : " & $loopCount + 1, $COLOR_PURPLE)
	  EndIf

	  If $testMode Then
		 ExitLoop
	  EndIf
   WEnd

   SetLog("Bot stopped.", $COLOR_RED)

   _log("Bye" )
   btnStop()
EndFunc


