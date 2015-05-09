
Func Wheel($x, $y, $direction, $clicks = 1)
   WinActivate($Title)
   MouseMove($x, $y)
   MouseWheel($direction, $clicks)
EndFunc	;==>Wheel

Func WheelPos($pos, $direction, $clicks = 1)
   Wheel($pos[0], $pos[1], $direction, $clicks)
EndFunc	;==>Wheel