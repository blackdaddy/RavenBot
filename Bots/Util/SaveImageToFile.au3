
Func SaveImageToFile($tag = "", $dir = $dirCapture, $ext = "bmp", $useData = True)
   If StringLen($tag) <= 0 Then
	  $tag = "image"
   EndIf

   Local $dateText = "_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC
   If $useData = False Then
	  $dateText = ""
   EndIf
   Local $path = $dir & "\" & $tag & $dateText & "." & $ext
   _GDIPlus_ImageSaveToFile($hBitmap, $path)
EndFunc