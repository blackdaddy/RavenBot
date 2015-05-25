
GUICtrlSetOnEvent($comboStageMajor, "comboStageMajorChanged")

Func comboStageMajorChanged()
   loadStageMinorCombo(_GUICtrlComboBox_GetCurSel($comboStageMajor) + 1)
EndFunc

Func getMaxStageMinor($stageMajor)

   Switch $stageMajor
   Case 1 To 5
	  Return 6
   Case 6 To 10
	  Return 8
   Case 11 To 15
	  Return 10
   Case 16 To 18
	  Return 5
   EndSwitch

   Return 0
EndFunc


Func loadStageMinorCombo($stageMajor)

   _GUICtrlComboBox_ResetContent($comboStageMinor)

   $count = getMaxStageMinor($stageMajor)
   For $i = 1 To $count
	  GUICtrlSetData($comboStageMinor, "" & $i)
   Next
   _GUICtrlComboBox_SetCurSel($comboStageMinor, 0)
   _log("loadStageMinorCombo : " & $stageMajor & "=" & $count )
EndFunc


Func getStaminaCount($stageMajor)
   If $stageMajor <= 5 Then Return 1
   If $stageMajor <= 15 Then Return 3
   If $stageMajor <= 16 Then Return 1
   If $stageMajor <= 17 Then Return 2
   If $stageMajor <= 18 Then Return 3
EndFunc


Func getPixelStage($stageMajor, $stageMinor)

   Local $pos[2]
   Switch $stageMajor

	  Case 1 To 5
		 Switch $stageMinor
			Case 1
			   $pos[0] = 172
			   $pos[1] = 172
			Case 2
			   $pos[0] = 172
			   $pos[1] = 318
			Case 3
			   $pos[0] = 372
			   $pos[1] = 318
			Case 4
			   $pos[0] = 372
			   $pos[1] = 172
			Case 5
			   $pos[0] = 572
			   $pos[1] = 172
			Case 6
			   $pos[0] = 572
			   $pos[1] = 318
		 EndSwitch

	  Case 6 To 10
		 Switch $stageMinor
			Case 1
			   $pos[0] = 106
			   $pos[1] = 178
			Case 2
			   $pos[0] = 239
			   $pos[1] = 178
			Case 3
			   $pos[0] = 239
			   $pos[1] = 317
			Case 4
			   $pos[0] = 372
			   $pos[1] = 317
			Case 5
			   $pos[0] = 372
			   $pos[1] = 178
			Case 6
			   $pos[0] = 505
			   $pos[1] = 178
			Case 7
			   $pos[0] = 505
			   $pos[1] = 317
			Case 8
			   $pos[0] = 639
			   $pos[1] = 317
		 EndSwitch

	  Case 11 To 15
		 Switch $stageMinor
			Case 1
			   $pos[0] = 106
			   $pos[1] = 317
			Case 2
			   $pos[0] = 106
			   $pos[1] = 178
			Case 3
			   $pos[0] = 239
			   $pos[1] = 178
			Case 4
			   $pos[0] = 239
			   $pos[1] = 317
			Case 5
			   $pos[0] = 372
			   $pos[1] = 317
			Case 6
			   $pos[0] = 372
			   $pos[1] = 178
			Case 7
			   $pos[0] = 505
			   $pos[1] = 178
			Case 8
			   $pos[0] = 505
			   $pos[1] = 317
			Case 9
			   $pos[0] = 639
			   $pos[1] = 317
			Case 10
			   $pos[0] = 639
			   $pos[1] = 178
		 EndSwitch

	  Case 16 To 18
		 Switch $stageMinor
			Case 1
			   $pos[0] = 172
			   $pos[1] = 174
			Case 2
			   $pos[0] = 172
			   $pos[1] = 319
			Case 3
			   $pos[0] = 372
			   $pos[1] = 319
			Case 4
			   $pos[0] = 372
			   $pos[1] = 174
			Case 5
			   $pos[0] = 572
			   $pos[1] = 174
		 EndSwitch
   EndSwitch

   _log("getPixelStage : " & $stageMajor & ":" & $stageMinor & "==> " & $pos[0] & "x" & $pos[1] )

   Return $pos
EndFunc