#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         gunoodaddy

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
;$testMode = True


Func AutoFlow()
   ; For test
   ;waitBattleScreen()
   ;doBattle($Id_Adventure)
   ;doTempleBattle()
   ;doPvpBattle()
   ;Local $__newBadgeCount = 0
   ;sellItems($__newBadgeCount)
   ;selectAdventureStage()
   ;checkInventory()
   ;waitAdventureScreen()
   ;selectBuffItem($Id_Raid)
   ;selectBuffItem($Id_Guild)
   ;_checkHealthAndEatPotion($Id_Adventure)

   If $testMode Then
	  Return False
   EndIf

   If waitMainScreen() = False Then
	  Return False
   EndIf

   If 1 Then
   If $setting_daily_enabled Then
	  If checkActiveDailyStatus() Then

		 doDailyBattle()

		 If waitMainScreen() = False Then
			Return False
		 EndIf
	  EndIf
   EndIf

   If $setting_raid_enabled Then
	  If checkActiveRaidStatus() Then

		 doRaidBattle()

		 If waitMainScreen() = False Then
			Return False
		 EndIf
	  EndIf
   EndIf

   If $setting_pvp_enabled Then
	  If checkActivePvpStatus() Then

		 doPvpBattle()

		 If waitMainScreen() = False Then
			Return False
		 EndIf
	  EndIf
   EndIf

   If $setting_guild_enabled Then
	  If checkActiveGuildStatus() Then

		 doGuildBattle()

		 If waitMainScreen() = False Then
			Return False
		 EndIf
	  EndIf
   EndIf

   If $setting_item_sell_maximum_level >= 1 Then
	  If checkInventory() = False Then
		 Return False
	  EndIf
   EndIf

   EndIf

   checkStamina()

   If checkActiveAdventureStatus() Then
	  Return doAdventureBattle()
   EndIf

   Return False
EndFunc	;==>AutoFlow


Func checkInventory()
   clickBlackSmithButton()

   If waitBlacksmithScreen() = False Then
	  Return False
   EndIf

   Local $newBadgeCount = 0
   If sellItems($newBadgeCount) = False Then
	  If waitMainScreen() = False Then
		 Return False
	  EndIf

	  Return False
   EndIf

   clickBackButton()

   If waitMainScreen() = False Then
	  Return False
   EndIf

   If $newBadgeCount > 0 Then
	  ; Entering Inventory to remove new badge on Blacksmith screen
	  clickInventoryButton()

	  If waitInventoryScreen() = False Then
		 Return False
	  EndIf

	  _Sleep(700)

	  clickBackButton()

	  If waitMainScreen() = False Then
		 Return False
	  EndIf
   EndIf

   Return True
EndFunc	;==>checkInventory


Func clickBackButton()
   ClickPos($BACK_BUTTON_POS)
EndFunc	;==>clickBackButton


Func doPvpBattle()
   If waitPvpScreen() = False Then
	  Return False
   EndIf

   If checkPvpStamina() = False Then
	  Return True
   EndIf

   If startPvpBattle() = False Then
	  Return False
   EndIf

   ; Select Buff Item If you need
   selectBuffItem($Id_Pvp)

   ; Click Battle button
   clickBattleStartButton()

   ; Do PvP
   doPvpBattleScreen()

   $pvpAttackCount = $pvpAttackCount + 1
   updateStats()

   Return True
EndFunc	;==>doPvpBattle


Func doGuildBattle()
   If waitGuildScreen() = False Then
	  Return False
   EndIf

   If startGuildBattle() = False Then
	  Return False
   EndIf

   ; Select Buff Item If you need
   selectBuffItem($Id_Guild)

   ; Click Battle button
   clickBattleStartButton()

   ; Do PvP
   doGuildBattleScreen()

   $guildAttackCount = $guildAttackCount + 1
   updateStats()

   Return True
EndFunc	;==>doGuildBattle


Func doDailyBattle()
   If waitDailyScreen() = False Then
	  Return
   EndIf

   Local $ok = False

   If checkActiveDailyAdventureStatus() Then
	  If waitDailyAdventureScreen() = False Then
		 Return
	  EndIf

	  selectDailyAdventureLevel()

	  If startDailyAdventureBattle() = False Then
		 Return
	  EndIf

	  ; Select Buff Item If you need
	  selectBuffItem($Id_Daily)

	  ; Start Battle
	  clickBattleStartButton()

	  ; Do Battle!
	  $ok = doBattle($Id_Adventure)
   ElseIf checkActiveDailyTempleStatus() Then
	  If waitDailyTempleScreen() = False Then
		 Return
	  EndIf

	  ; Start Battle
	  clickBattleStartButton()

	  ; Do Battle!
	  $ok = doTempleBattle()
   EndIf

   If $ok Then
	  $dailyAttackCount = $dailyAttackCount + 1
	  updateStats()
   EndIf
EndFunc	;==>doDailyBattle


Func doRaidBattle()
   If waitRaidScreen() = False Then
	  Return
   EndIf

   If startRaidBattle() = False Then
	  Return
   EndIf

   ; Select Buff Item If you need
   selectBuffItem($Id_Raid)

   ; Start Battle
   clickBattleStartButton()

   ; Do Battle!
   If doBattle($Id_Raid) Then
	  $raidAttackCount = $raidAttackCount + 1
	  updateStats()
   EndIf

EndFunc	;==>doRaidBattle


Func doAdventureBattle()
   ; Go To Adventure Screen
   clickAdventureButton()

   If _Sleep($IdleMsec) Then Return False

   If waitAdventureScreen() = False Then
	  Return False
   EndIf

   ; Select Stage
   If selectAdventureStage() = False Then
	  Return False
   EndIf

   ; Select Buff Item If you need
   selectBuffItem($Id_Adventure)
   If $Restart Then Return False

   ; Start Battle
   clickBattleStartButton()

   ; Do Battle!
   doBattle($Id_Adventure)

   Return True
EndFunc	;==>doAdventureBattle
