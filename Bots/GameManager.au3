
;==================================
; Methods
;==================================

Func isValidRunningEmulator()
   If IsArray(ControlGetPos($Title, "_ctl.Window", $WindowClass)) Then
	  Return True
   EndIf

   Return False
EndFunc


Func Initiate()
   If isValidRunningEmulator() Then
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
		 SetLog("Resolution reset : " & $DEFAULT_WIDTH & "x" & $DEFAULT_HEIGHT, $COLOR_GREEN)
		 Return False
	  EndIf

	  Return True
   Else
	  SetLog("Could not find " & $Title, $COLOR_RED)
	  Return False
   EndIf
EndFunc


Func runBlueStack()
   $restartCount = $restartCount + 1
   updateStats()

   Local $sWow64 = ""
   If @AutoItX64 Then $sWow64 = "\Wow6432Node"
   Local $sFile = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE" & $sWow64 & "\BlueStacks", "InstallDir") & "\HD-StartLauncher.exe"
   Return ShellExecute($sFile)
EndFunc


Func killBlueStack()
   $errorCount = 0
   updateStats()

   Local $pid = ProcessExists($ProcessNameForKill)
   If $pid <> 0 Then
	  ProcessClose($pid)
   EndIf
EndFunc
