; ---------- STATS ----------
Global $loopCount = 1
Global $lastElapsed = ""
Global $totalElapsed = ""
Global $raidAttackCount = 0
Global $pvpAttackCount = 0
Global $guildAttackCount = 0
Global $dailyAttackCount = 0
Global $itemSoldCount = 0
Global $errorCount = 0
Global $totalErrorCount = 0
Global $hTotalTimer

Func clearStats()
   $loopCount = 0
   $errorCount = 0
   $lastElapsed = "--:--:--"
   $totalElapsed = "--:--:--"
   $raidAttackCount = 0
   $pvpAttackCount = 0
   $guildAttackCount = 0
   $dailyAttackCount = 0
   $itemSoldCount = 0
   $totalErrorCount = 0
EndFunc


Func updateTotalElapsed()

   If $RunState Then
	  Local $iSec, $iMin, $iHour
	  Local $time = _TicksToTime(Int(TimerDiff($hTotalTimer)), $iHour, $iMin, $iSec)
	  $totalElapsed = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
   Else
	  $totalElapsed = "--:--:--"
   EndIf

   Local $text = "Total Elapsed : " & $totalElapsed
   GUICtrlSetData($txtTotalElapsed, $text)
EndFunc

Func updateStats()

   Local $text = "Loop : " & $loopCount & @CRLF & "Elapsed : " & $lastElapsed & @CRLF & "PvP : " & $pvpAttackCount & @CRLF & "Raid : " & $raidAttackCount & @CRLF   & "Guild : " & $guildAttackCount & @CRLF & "Daily : " & $dailyAttackCount & @CRLF & "Item sold : " & $itemSoldCount & @CRLF & "Error : " & $errorCount & "(" & $totalErrorCount & ")"

   GUICtrlSetData($txtStats, $text)
EndFunc


Func updateRemainingReconnectStatus($msec)
   Local $iSec, $iMin, $iHour
   Local $time = _TicksToTime($msec, $iHour, $iMin, $iSec)
   Local $s = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
   Local $text = "Reconnect : " & $s
   GUICtrlSetData($labelRemainingReconnectTime, $text)
EndFunc