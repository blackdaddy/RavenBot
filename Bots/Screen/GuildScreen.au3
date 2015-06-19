
Local Const $GUILD_BATTLE_BUTTON_REGION[4] = [547, 380, 716, 451]
Local Const $BATTLE_READY_BUTTON_REGION[4] = [466, 380, 680, 446]
Local Const $GUILD_BATTLE_MARK_REGION[4] = [351, 2, 405, 30]

Func waitGuildScreen()
   SetLog("Waiting for Guild Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\guild_text.bmp"
	  If ImageSearchArea($bmpPath, 0, $LEFT_TOP_SCREEN_NAME_REGION, $x, $y, 30) = False Then
		 If _Sleep($SleepWaitMSec) Then Return False

		 ; Checking RAID
		 If ClickButtonImage(String(@ScriptDir & "\images\button_raid_close.bmp")) Then
			SetLog("Raid detected.", $COLOR_PINK)
		 EndIf

		 ; In this Pvp screen, this server disconnected popup can show up often. So just close the popup and try reconnect
		 If ClickButtonImageArea(String(@ScriptDir & "\images\button_retry.bmp"), $POPUP_BUTTON_REGION) Then
			SetLog("Retry button detected.", $COLOR_PINK)
		 EndIf

		 ; Re-click adventure button on MainScreen
		 clickGuildButton()
		 If _Sleep($SleepWaitMSec) Then ExitLoop
	  Else
		 SetLog("Guild Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next
   SetLog("Guild Screen Timeout", $COLOR_RED)
   Return False
EndFunc	;==>waitGuildScreen



Func startGuildBattle()
   Local $x, $y

   Local $clickedReward = False
   SetLog("Waiting for Guild Battle Ready Screen", $COLOR_ORANGE)
   For $i = 0 To $RetryWaitCount

	  If clickOkButton() == 2 Then ExitLoop

	  If _ImageSearchArea(String(@ScriptDir & "\images\button_guild_attendance_tab.bmp"), 0, 163, 67, 271, 96, $x, $y, $DefaultTolerance) Then
		 Click(84, 264)
		 Local $region = [570, 300, 712, 351];
		 ClickButtonImageArea(String(@ScriptDir & "\images\button_guild_attendance_reward.bmp"), $region);
		 _Sleep(1000)
		 clickOkButton()
		 SetLog("Guild Attendace checked.", $COLOR_BLUE)
	  EndIf

	  ClickButtonImageArea(String(@ScriptDir & "\images\button_guild_battle.bmp"), $GUILD_BATTLE_BUTTON_REGION)

	  If ImageSearchArea(String(@ScriptDir & "\images\button_battle_ready.bmp"), 0, $BATTLE_READY_BUTTON_REGION, $x, $y, $DefaultTolerance) Then
		 If $clickedReward = False Then
			_Sleep(1000)

			; click ranking reward button
			Click(646, 240)
			_Sleep(2000)
			If clickOkButton() == 2 Then ExitLoop
			_Sleep(1000)

			; click daily reward button
			Click(678, 342)
			_Sleep(2000)
			If clickOkButton() == 2 Then ExitLoop
			_Sleep(1000)

			$clickedReward = True
		 EndIf

		 Click($x, $y)
	  EndIf

	  If waitBattleReadyScreen(True) Then
		 SetLog("Guild Battle Ready Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf

	  If _Sleep($SleepWaitMSec) Then Return False
   Next
   Return False
EndFunc	;==>startGuildBattle


Func doGuildBattleScreen()

   _waitGuildBattleScreen()

   Local $order = 0
   Local $hTimer = TimerInit()
   While 1
	  If Int(TimerDiff($hTimer)) > 300000 Then
		 SetLog("Unexpected battle detected...", $COLOR_RED)
		 SaveImageToFile("guild_error");
		 $RunState = True
		 Return
	  EndIf

	  Local $battleEnd = WaitScreenImage(String(@ScriptDir & "\images\button_ok.bmp"), $BOTTOM_OK_BUTTON_REGION, True);

	  If $battleEnd Then
		 SetLog("Finished Guild Battle!", $COLOR_RED)
		 ExitLoop
	  EndIf

	  ; Click any buff among 3 cards
	  Switch Mod($order, 3)
		 Case 0
			Click(268, 410)
		 Case 1
			Click(375, 410)
		 Case 2
			Click(481, 410)
	  EndSwitch

	  $order = $order + 1

	  If _Sleep(3000) Then Return
   WEnd

   ; To remove 3 continuous reward text
   Click(186, 362)
   If _Sleep(3000) Then Return

   ; Click OK Button
   ClickButtonImageArea(String(@ScriptDir & "\images\button_ok.bmp"), $BOTTOM_OK_BUTTON_REGION)

EndFunc	;==>doGuildBattleScreen


Func _waitGuildBattleScreen()
   SetLog("Waiting for Guild Battle Screen", $COLOR_ORANGE)

   For $i = 0 To ($RetryWaitCount * 2)	; Guild battle loading time can be quite a few slow!!
	  _CaptureRegion()

	  Local $x, $y
	  Local $bmpPath = @ScriptDir & "\images\battle_guild_mark.bmp"
	  If ImageSearchArea($bmpPath, 0, $GUILD_BATTLE_MARK_REGION, $x, $y, $DefaultTolerance) = False Then
		 Click(400, 200)	; Click anywhere to start
		 If _Sleep($SleepWaitMSec) Then Return False
	  Else
		 SetLog("Guild Battle Screen Located", $COLOR_BLUE)
		 Return True
	  EndIf
   Next

   Return False
EndFunc	;==>_waitGuildBattleScreen

