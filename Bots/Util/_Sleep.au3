Func _Sleep($iDelay, $bPauseAllow = True)
   Local $iBegin = TimerInit()
   While TimerDiff($iBegin) < $iDelay
	  If $RunState = False Then Return True
	  While ($PauseBot And $bPauseAllow)
		 Sleep(1000)
	  WEnd
	  updateTotalElapsed()
	  tabChanged()
	  Sleep(($iDelay > 50) ? 50 : 1)
   WEnd
   Return False
EndFunc   ;==>_Sleep
