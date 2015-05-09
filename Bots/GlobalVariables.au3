#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <FileConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <GUIEdit.au3>
#include <GUIComboBox.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIProc.au3>
#include <ScreenCapture.au3>
#include <Date.au3>
#include <Misc.au3>
#include <File.au3>
#include <TrayConstants.au3>
#include <GUIMenu.au3>
#include <ColorConstants.au3>
#include <GDIPlus.au3>
#include <GuiRichEdit.au3>
#include <GuiTab.au3>
#include <WinAPISys.au3>

Global Const $64Bit = StringInStr(@OSArch, "64") > 0
Global Const $DEFAULT_WIDTH = 800
Global Const $DEFAULT_HEIGHT = 480
Global Const $REGISTRY_KEY_DIRECTORY = "HKEY_LOCAL_MACHINE\SOFTWARE\BlueStacks\Guests\Android\FrameBuffer\0"

Global $WindowClass = "[CLASS:BlueStacksApp; INSTANCE:1]"
Global $Title = "BlueStacks App Player" ; Name of the Window
;Global $WindowClass = "[CLASS:Afx:00000000FF980000:8; INSTANCE:1]"
;Global $Title = "���̺�1.bmp - �׸���"

Global $HWnD = WinGetHandle($Title) ;Handle for Bluestacks window

Global $Compiled
If @Compiled Then
	$Compiled = "Executable"
Else
	$Compiled = "Au3 Script"
EndIf

Global $sLogPath ; `Will create a new log file every time the start button is pressed
Global $hLogFileHandle
Global $Restart = False
Global $RunState = False
Global $PauseBot = False
Global $testMode = False

Global $hBitmap; Image for pixel functions
Global $hHBitmap; Handle Image for pixel functions

Global $dirLogs = @ScriptDir & "\logs\"
Global $dirCapture = @ScriptDir & "\capture\"
Global $ReqText
Global $config = @ScriptDir & "\config.ini"

Global $BSpos[2] ; Inside BlueStacks positions relative to the screen

Global Const $RetryWaitCount = 30
Global Const $SleepWaitMSec = 1500

Global Const $RetryWaitCountShort = 15
Global Const $SleepWaitMSecShort = 1000

Global Const $MaxStageNumber = 18
Global Const $IdleMsec = 1000

Global Const $DefaultTolerance = 30

Global Const $MaxBattleTypeCount = 5
Global Const $Id_Adventure = 0
Global Const $Id_Pvp = 1
Global Const $Id_Raid = 2
Global Const $Id_Guild = 3
Global Const $Id_Daily = 4

Global Const $SETTING_RECONNECT_TIMEOUT[8] = [1, 5, 10, 15, 30, 45, 60, 120]

; ---------- STATS ----------
Global $loopCount = 1
Global $lastElapsed = ""
Global $raidAttackCount = 0
Global $pvpAttackCount = 0
Global $guildAttackCount = 0
Global $dailyAttackCount = 0
Global $itemSoldCount = 0
Global $errorCount = 0

; ---------- REGIONS ------------
Global Const $LEFT_TOP_SCREEN_NAME_REGION[4] = [70, 9, 135, 38]
Global Const $BACK_BUTTON_POS[2] = [57, 22]
Global Const $BACK_BUTTON_REGION = [30, 0, 75, 50]
Global Const $NOTICE_POPUP_CLOSE_BUTTON_REGION = [668, 0, 799, 50]
Global Const $NORMAL_CLOSE_BUTTON_REGION = [590, 0, 799, 104]
Global Const $SMALL_CLOSE_BUTTON_REGION = [557, 74, 606, 115]
Global Const $AD_POPUP_CLOSE_BUTTON_REGION = [670, 410, 790, 479]
Global Const $GAME_START_REGION = [140, 430, 345, 479]
Global Const $SCREEN_NAME_REGION = [250, 5, 530, 45]
Global Const $POPUP_BUTTON_REGION = [182, 239, 627, 441]
Global Const $POPUP_CENTER_OK_BUTTON_REGION = [292, 336, 467, 425]
Global Const $BOTTOM_MAINSCREEN_BUTTON_REGION = [0, 320, 764, 468]
Global Const $BOTTOM_OK_BUTTON_REGION = [15, 401, 749, 468]
Global Const $ARCHIEVEMENT_POPUP_CLOSE_BUTTON_REGION = [631, 378, 761, 474]

; ---------- BATTLE ACTION ICON POSITIONS ------------
Local Const $BATTLE_ATTACK_BUTTON_POS[2] = [621, 329]
Local Const $BATTLE_SKILL1_BUTTON_POS[2] = [538, 413]
Local Const $BATTLE_SKILL2_BUTTON_POS[2] = [529, 341]
Local Const $BATTLE_SKILL3_BUTTON_POS[2] = [581, 273]
Local Const $BATTLE_SKILL4_BUTTON_POS[2] = [665, 275]
Local Const $BATTLE_DODGE_BUTTON_POS[2] = [705, 413]
Local Const $BATTLE_POTION_BUTTON_POS[2] = [712, 156]


; ---------- COLORS ------------
Global Const $COLOR_ORANGE = 0xFFA500
Global Const $COLOR_PINK = 0xFFAEC9
Global Const $COLOR_DARKGREY = 0x555555
