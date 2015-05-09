Global $Initiate = 0

Local $tabX = 10
Local $tabY = 10
Local $contentPaneX = $tabX + 10
Local $contentPaneY = $tabY + 30

Local $gap = 10
Local $generalRightHeight = 240
Local $generalBottomHeight = 70
Local $logViewWidth = 260
Local $logViewHeight = 300
Local $frameWidth = $contentPaneX + $logViewWidth + $gap + $generalRightHeight + $tabX
Local $frameHeight = $contentPaneY + $logViewHeight + $gap + $generalBottomHeight + $tabY

Local $tabHeight = $frameHeight - $tabY - $tabY
Local $contentPaneWidth = $frameWidth - $contentPaneX * 2
Local $contentPaneHeight = $tabHeight - 30
Local $x
Local $y
Local $h = 20
Local $w

; Main GUI Settings
$mainView = GUICreate($sBotTitle, $frameWidth, $frameHeight, -1, -1)

$idTab = GUICtrlCreateTab($tabX, $tabY, $frameWidth - $tabX * 2, $tabHeight)



;-----------------------------------------------------------
; Tab : General
;-----------------------------------------------------------
Local $generalRightX = $frameWidth - $tabX - $generalRightHeight
Local $generalBottomY = $frameHeight - $tabY - $generalBottomHeight

GUICtrlCreateTabItem("General")

$x = $generalRightX
$y = $contentPaneY + 5
GUICtrlCreateLabel("Sell Item Max Level", $x, $y)
$comboSellItemLevel = GUICtrlCreateCombo("", $x + 120, $y - 2, 100, $h)
$y += 30
GUICtrlCreateLabel("Reconnect Timeout", $x, $y)
$comboReconnectTimeout = GUICtrlCreateCombo("", $x + 120, $y - 2, 100, $h)
$y += 25
$labelRemainingReconnectTime = GUICtrlCreateLabel("Remaining Time : ", $x, $y, 200, 30)
GUICtrlSetColor($labelRemainingReconnectTime, $COLOR_RED)
GUICtrlSetState($labelRemainingReconnectTime, $GUI_HIDE)

$y += 20
$checkDailyEnabled = GUICtrlCreateCheckbox("Daily Enabled", $x, $y, $w, 25)
$y += 30
$checkRaidEnabled = GUICtrlCreateCheckbox("Raid Enabled", $x, $y, $w, 25)
$y += 30
$checkPvpEnabled = GUICtrlCreateCheckbox("PvP Enabled", $x, $y, $w, 25)
$y += 30
$checkGuildEnabled = GUICtrlCreateCheckbox("Guild Enabled", $x, $y, $w, 25)

; The Bot Status Screen
$txtLog = _GUICtrlRichEdit_Create($mainView, "", $contentPaneX, $contentPaneY, $logViewWidth, $logViewHeight, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL, 8912))

; Start/Stop Button
$x = $contentPaneX
Local $btnWidth = 90
$btnStart = GUICtrlCreateButton("Start Bot", $x, $generalBottomY, $btnWidth, 50)
$btnStop = GUICtrlCreateButton("Stop Bot", $x, $generalBottomY, $btnWidth, 50)

$x += $btnWidth
$x += $gap
$btnScreenShot = GUICtrlCreateButton("Screen Shot", $x, $generalBottomY, $btnWidth, 50)


; Statistics
$x = $generalRightX
$y += 35
$txtStats = GUICtrlCreateLabel("", $x, $y, 200, 150);, BitOR($GUI_SS_DEFAULT_LABEL,$SS_GRAYFRAME))
Local Const $sFont = "Comic Sans Ms"
GUICtrlSetColor(-1, $COLOR_PURPLE)
GUICtrlSetFont(-1, 10, 800, 0, $sFont) ; Set the font of the previous control.


;-----------------------------------------------------------
; Tab : Adventure
;-----------------------------------------------------------
GUICtrlCreateTabItem("Adventure")

$x = $contentPaneX
$y = $contentPaneY

$comboStageMajor = GUICtrlCreateCombo("", $x, $y, 100, 20)
$comboStageMinor = GUICtrlCreateCombo("", $x + 110, $y, 50, 20)

; Battle Buff Items
$x = $contentPaneX
$y = $contentPaneY + 30
$h = 20
$w = 120

Global $checkBuffAttack[$MaxBattleTypeCount];
Global $checkBuffDefence[$MaxBattleTypeCount];
Global $checkBuffHealth[$MaxBattleTypeCount];
Global $checkBuffAutoSkill[$MaxBattleTypeCount];
Global $checkBattleEatPotion[$MaxBattleTypeCount];
Global $comboBattleHealthCondition[$MaxBattleTypeCount];

$checkBuffAttack[$Id_Adventure] = GUICtrlCreateCheckbox("Buff Attack", $x, $y, $w, 25)
$y += $h
$checkBuffDefence[$Id_Adventure] = GUICtrlCreateCheckbox("Buff Defence", $x, $y, $w, 25)
$y += $h
$checkBuffHealth[$Id_Adventure] = GUICtrlCreateCheckbox("Buff Health", $x, $y, $w, 25)
$y += $h
$checkBuffAutoSkill[$Id_Adventure] = GUICtrlCreateCheckbox("Buff AutoSkill", $x, $y, $w, 25)
$y += $h
$checkBattleEatPotion[$Id_Adventure] = GUICtrlCreateCheckbox("Eat health potion", $x, $y, 120, 25)
$y += ($h + 15)
GUICtrlCreateLabel("Remaining Health", $x, $y)
$comboBattleHealthCondition[$Id_Adventure] = GUICtrlCreateCombo("", $x + 110, $y - 2, 80, $h)


;-----------------------------------------------------------
; Tab : PvP
;-----------------------------------------------------------

GUICtrlCreateTabItem("PvP")

; Battle Buff Items
$x = $contentPaneX
$y = $contentPaneY
$h = 20
$w = 120

$checkBuffAttack[$Id_Pvp] = GUICtrlCreateCheckbox("Buff Attack", $x, $y, $w, 25)
$y += $h
$checkBuffDefence[$Id_Pvp] = GUICtrlCreateCheckbox("Buff Defence", $x, $y, $w, 25)
$y += $h
$checkBuffHealth[$Id_Pvp] = GUICtrlCreateCheckbox("Buff Health", $x, $y, $w, 25)
$y += $h
$checkBuffAutoSkill[$Id_Pvp] = GUICtrlCreateCheckbox("Buff AutoSkill", $x, $y, $w, 25)
$y += $h
$checkBattleEatPotion[$Id_Pvp] = GUICtrlCreateCheckbox("Eat health potion", $x, $y, 120, 25)
$y += ($h + 15)
GUICtrlCreateLabel("Remaining Health", $x, $y)
$comboBattleHealthCondition[$Id_Pvp] = GUICtrlCreateCombo("", $x + 110, $y - 2, 80, $h)

GUICtrlSetState($checkBuffAutoSkill[$Id_Pvp], $GUI_CHECKED)
ControlDisable($mainView, "", $checkBuffAutoSkill[$Id_Pvp] )


;-----------------------------------------------------------
; Tab : Raid
;-----------------------------------------------------------

GUICtrlCreateTabItem("Raid")

; Battle Buff Items
$x = $contentPaneX
$y = $contentPaneY
$h = 20
$w = 120

$checkBuffAttack[$Id_Raid] = GUICtrlCreateCheckbox("Buff Attack", $x, $y, $w, 25)
$y += $h
$checkBuffDefence[$Id_Raid] = GUICtrlCreateCheckbox("Buff Defence", $x, $y, $w, 25)
$y += $h
$checkBuffHealth[$Id_Raid] = GUICtrlCreateCheckbox("Buff Health", $x, $y, $w, 25)
$y += $h
$checkBuffAutoSkill[$Id_Raid] = GUICtrlCreateCheckbox("Buff AutoSkill", $x, $y, $w, 25)
$y += $h
$checkBattleEatPotion[$Id_Raid] = GUICtrlCreateCheckbox("Eat health potion", $x, $y, 120, 25)
$y += ($h + 15)
GUICtrlCreateLabel("Remaining Health", $x, $y)
$comboBattleHealthCondition[$Id_Raid] = GUICtrlCreateCombo("", $x + 110, $y - 2, 80, $h)

GUICtrlSetState($checkBuffAutoSkill[$Id_Raid], $GUI_CHECKED)
ControlDisable($mainView, "", $checkBuffAutoSkill[$Id_Raid] )


;-----------------------------------------------------------
; Tab : Guild
;-----------------------------------------------------------

GUICtrlCreateTabItem("Guild")

; Battle Buff Items
$x = $contentPaneX
$y = $contentPaneY
$h = 20
$w = 120

$checkBuffAttack[$Id_Guild] = GUICtrlCreateCheckbox("Buff Attack", $x, $y, $w, 25)
$y += $h
$checkBuffDefence[$Id_Guild] = GUICtrlCreateCheckbox("Buff Defence", $x, $y, $w, 25)
$y += $h
$checkBuffHealth[$Id_Guild] = GUICtrlCreateCheckbox("Buff Health", $x, $y, $w, 25)


;-----------------------------------------------------------
; Tab : Day Battle
;-----------------------------------------------------------

GUICtrlCreateTabItem("Daily")

$x = $contentPaneX
$y = $contentPaneY
$h = 20
$w = 120

$comboDailyLevel = GUICtrlCreateCombo("", $x, $y, 100, 20)
$y += 30

$checkBuffAttack[$Id_Daily] = GUICtrlCreateCheckbox("Buff Attack", $x, $y, $w, 25)
$y += $h
$checkBuffDefence[$Id_Daily] = GUICtrlCreateCheckbox("Buff Defence", $x, $y, $w, 25)
$y += $h
$checkBuffHealth[$Id_Daily] = GUICtrlCreateCheckbox("Buff Health", $x, $y, $w, 25)
$y += $h
$checkBuffAutoSkill[$Id_Daily] = GUICtrlCreateCheckbox("Buff AutoSkill", $x, $y, $w, 25)
$y += $h
$checkBattleEatPotion[$Id_Daily] = GUICtrlCreateCheckbox("Eat health potion", $x, $y, 120, 25)
$y += ($h + 15)
GUICtrlCreateLabel("Remaining Health", $x, $y)
$comboBattleHealthCondition[$Id_Daily] = GUICtrlCreateCombo("", $x + 110, $y - 2, 80, $h)


;==================================
; Control Initial setting
;==================================

For $i = 1 To $MaxStageNumber
   If $i = 16 Then
	  GUICtrlSetData($comboStageMajor, "Stage-" & $i & " *")
   Else
	  GUICtrlSetData($comboStageMajor, "Stage-" & $i)
   EndIf
Next

For $i = 0 To UBound($SETTING_RECONNECT_TIMEOUT) - 1
   GUICtrlSetData($comboReconnectTimeout, $SETTING_RECONNECT_TIMEOUT[$i] & " min")
Next

GUICtrlSetData($comboSellItemLevel, "None")
For $i = 1 To 6
   GUICtrlSetData($comboSellItemLevel, "Level " & $i)
Next

For $i = 10 To 60 Step 10
   For $j = 0 To $MaxBattleTypeCount - 1
	  GUICtrlSetData($comboBattleHealthCondition[$j], $i & "%")
   Next
Next

GUICtrlSetData($comboDailyLevel, "Easy")
GUICtrlSetData($comboDailyLevel, "Normal")
GUICtrlSetData($comboDailyLevel, "Hard")

;GUICtrlSetOnEvent($btnScreenShot, "btnScreenShot")	; already called in RavenBot event loop
GUICtrlSetOnEvent($btnStart, "btnStart")
GUICtrlSetOnEvent($btnStop, "btnStop")
GUICtrlSetOnEvent($idTab, "tabChanged")

GUICtrlSetState($btnStart, $GUI_SHOW)
GUICtrlSetState($btnStop, $GUI_HIDE)


;==================================
; Control Callback
;==================================

Func tabChanged()
   If _GUICtrlTab_GetCurSel($idTab) = 0 Then
	  ControlShow($mainView, "", $txtLog)
   Else
	  ControlHide($mainView, "", $txtLog)
   EndIf
EndFunc


Func btnScreenShot()
   _CaptureRegion()
   SaveImageToFile("screenshot")
   _log("SCREEN SHOT BUTTON CLICKED" )

   ; For Test
   If 0 Then
	  Local $x, $y
	  _CaptureRegion()
	  Local $bmpPath = String(@ScriptDir & "\images\stage_13.bmp")
	  If _ImageSearch($bmpPath, 0, $x, $y,  $DefaultTolerance / 3) Then
		 _log("OK! :" & $x & "x" & $y)
	  EndIf

	  $RunState = True
	  $PauseBot = False
	  runBot()
   EndIf
EndFunc


Func btnStart()

   If $RunState = True Then Return

   _log("START BUTTON CLICKED" )

   _GUICtrlEdit_SetText($txtLog, "")
   _WinAPI_EmptyWorkingSet(WinGetProcess($Title)) ; Reduce BlueStacks Memory Usage

   GUICtrlSetState($btnStart, $GUI_HIDE)
   GUICtrlSetState($btnStop, $GUI_SHOW)

   $RunState = True
   $PauseBot = False

   saveConfig()

   Initiate()

EndFunc

Func btnStop()
   _log("STOP BUTTON CLICKED" )

   GUICtrlSetState($btnStart, $GUI_SHOW)
   GUICtrlSetState($btnStop, $GUI_HIDE)

   $Restart = False
   $RunState = False
   $PauseBot = True
EndFunc

; System callback
Func mainViewClose()
   saveConfig()
   _GDIPlus_Shutdown()
   _GUICtrlRichEdit_Destroy($txtLog)
   Exit
EndFunc


;==================================
; Methods
;==================================

Func Initiate()
   If IsArray(ControlGetPos($Title, "_ctl.Window", $WindowClass)) Then
	  Local $BSsize = [ControlGetPos($Title, "_ctl.Window", $WindowClass)[2], ControlGetPos($Title, "_ctl.Window", $WindowClass)[3]]
	  Local $fullScreenRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "FullScreen")
	  Local $guestHeightRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "GuestHeight")
	  Local $guestWidthRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "GuestWidth")
	  Local $windowHeightRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "WindowHeight")
	  Local $windowWidthRegistryData = RegRead($REGISTRY_KEY_DIRECTORY, "WindowWidth")

	  Local $BSx = ($BSsize[0] > $BSsize[1]) ? $BSsize[0] : $BSsize[1]
	  Local $BSy = ($BSsize[0] > $BSsize[1]) ? $BSsize[1] : $BSsize[0]

	  If $BSx <> $DEFAULT_WIDTH Or $BSy <> $DEFAULT_HEIGHT Then
		 RegWrite($REGISTRY_KEY_DIRECTORY, "FullScreen", "REG_DWORD", "0")
		 RegWrite($REGISTRY_KEY_DIRECTORY, "GuestHeight", "REG_DWORD", $DEFAULT_HEIGHT)
		 RegWrite($REGISTRY_KEY_DIRECTORY, "GuestWidth", "REG_DWORD", $DEFAULT_WIDTH)
		 RegWrite($REGISTRY_KEY_DIRECTORY, "WindowHeight", "REG_DWORD", $DEFAULT_HEIGHT)
		 RegWrite($REGISTRY_KEY_DIRECTORY, "WindowWidth", "REG_DWORD", $DEFAULT_WIDTH)
		 SetLog("Please restart your computer for the applied changes to take effect.", $COLOR_ORANGE)
		 _Sleep(3000)

		 $MsgRet = MsgBox(BitOR($MB_OKCANCEL, $MB_SYSTEMMODAL), "Restart Computer", "Restart your computer for the applied changes to take effect." & @CRLF & "If your BlueStacks is the correct size  (" & $DEFAULT_WIDTH & " x " & $DEFAULT_HEIGHT & "), click OK.", 10)
		 If $MsgRet <> $IDOK Then
			btnStop()
			Return
		 EndIf
		 Exit
	  EndIf

	  WinMove($Title, "", 0, 0)
	  WinActivate($Title)

	  SetLog("Welcome to " & $sBotTitle, $COLOR_PURPLE)
	  SetLog($Compiled & " running on " & @OSArch & " OS", $COLOR_GREEN)
	  SetLog("Bot is starting...", $COLOR_ORANGE)

	  runBot()
   Else
	  SetLog("Could not find " & $Title, $COLOR_RED)
	  btnStop()
   EndIf
EndFunc


Func clearStats()
   $loopCount = 0
   $lastElapsed = "--:--:--"
   $raidAttackCount = 0
   $pvpAttackCount = 0
   $guildAttackCount = 0
   $dailyAttackCount = 0
   $itemSoldCount = 0
EndFunc


Func updateStats()

   Local $text = "Loop : " & $loopCount & @CRLF & "Elapsed : " & $lastElapsed & @CRLF & "PvP : " & $pvpAttackCount & @CRLF & "Raid : " & $raidAttackCount & @CRLF   & "Guild : " & $guildAttackCount & @CRLF & "Daily : " & $dailyAttackCount & @CRLF & "Item sold : " & $itemSoldCount & @CRLF & "Error : " & $errorCount

   GUICtrlSetData($txtStats, $text)
EndFunc


Func updateRemainingReconnectStatus($msec)
   Local $iSec, $iMin, $iHour
   Local $time = _TicksToTime($msec, $iHour, $iMin, $iSec)
   Local $s = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
   Local $text = "Remaining Time : " & $s
   GUICtrlSetData($labelRemainingReconnectTime, $text)
EndFunc