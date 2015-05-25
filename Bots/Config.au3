
; -----------------------------
; Settings Variable
; -----------------------------

Global $setting_auto_start = True
Global $setting_win_x = -1
Global $setting_win_y = -1
Global $setting_stage_major = 7
Global $setting_stage_minor = 2
Global $setting_use_buff_items[$MaxBattleTypeCount][4] = [[False, False, False, False], [True, True, True, True], [False, False, False, True], [False, False, False, True], [True, False, False, True]]
Global $setting_eat_potion[$MaxBattleTypeCount] = [True, True, True, True, True]
Global $setting_item_sell_loop_index = 0
Global $setting_item_sell_maximum_level = 1
Global $setting_item_lunch_maximum_level = 2
Global $setting_loot_capture_level = 3
Global $setting_pvp_enabled = False
Global $setting_raid_enabled = True
Global $setting_guild_enabled = True
Global $setting_daily_enabled = False
Global $setting_daily_adventure_enabled = True
Global $setting_daily_level = 1	; 0~2
Global $setting_remaining_health_index[$MaxBattleTypeCount] = [4, 4, 4, 4, 4]
Global $setting_reconnect_timeout_index = 0
Global $setting_cleanup_drag_count = 1
Global $setting_traindata_index = 0
Global $setting_important_item_options[$SETTING_IMPORTANT_ITEM_OPTION_COUNT] = [False, False, False]
; ------------------------------

Local $setting_common_group = "Raven"


Func currentReconnectTimeout()
   Local $index = _GUICtrlComboBox_GetCurSel($comboReconnectTimeout)
   If $index < 0 Then
	  $index = $setting_reconnect_timeout_index
   EndIf
   Return $SETTING_RECONNECT_TIMEOUT[$index] * 60 * 1000
EndFunc


Func healthConditionPercent($battleId)
   Return ($setting_remaining_health_index[$battleId] + 1) * 10
EndFunc


Func currentItemCleanUpLoopCount()
   Return $SETTING_CLEANUP_LOOP_COUNT[$setting_item_sell_loop_index]
EndFunc


Func loadConfig()
   If FileExists($config) Then
	  $setting_auto_start = IniRead($config, $setting_common_group, "enabled_auto_start", "True") == "True" ? True : False
	  $setting_win_x = Int(IniRead($config, $setting_common_group, "win_x", "-1"))
	  $setting_win_y = Int(IniRead($config, $setting_common_group, "win_y", "-1"))

	  $setting_pvp_enabled = IniRead($config, $setting_common_group, "enabled_pvp", "False") == "True" ? True : False
	  $setting_raid_enabled = IniRead($config, $setting_common_group, "enabled_raid", "False") == "True" ? True : False
	  $setting_guild_enabled = IniRead($config, $setting_common_group, "enabled_guild", "False") == "True" ? True : False
	  $setting_daily_enabled = IniRead($config, $setting_common_group, "enabled_daily", "False") == "True" ? True : False
	  $setting_daily_adventure_enabled = IniRead($config, $setting_common_group, "enabled_daily_adventure", "True") == "True" ? True : False

	  $setting_stage_major = Int(IniRead($config, $setting_common_group, "stage_major", "7"))
	  $setting_stage_minor = Int(IniRead($config, $setting_common_group, "stage_minor", "2"))

	  For $i = 0 To $MaxBattleTypeCount - 1
		 $setting_use_buff_items[$i][0] = IniRead($config, $setting_common_group, "use_buff_" & $i & "_1", "False") == "True" ? True : False
		 $setting_use_buff_items[$i][1] = IniRead($config, $setting_common_group, "use_buff_" & $i & "_2", "False") == "True" ? True : False
		 $setting_use_buff_items[$i][2] = IniRead($config, $setting_common_group, "use_buff_" & $i & "_3", "False") == "True" ? True : False
		 $setting_use_buff_items[$i][3] = IniRead($config, $setting_common_group, "use_buff_" & $i & "_4", "False") == "True" ? True : False
		 $setting_eat_potion[$i] = IniRead($config, $setting_common_group, "eat_potion_" & $i, "False") == "True" ? True : False
		 $setting_remaining_health_index[$i] = Int(IniRead($config, $setting_common_group, "health_condition_index_" & $i, "4"))
	  Next

	  For $i = 0 To $SETTING_IMPORTANT_ITEM_OPTION_COUNT - 1
		 $setting_important_item_options[$i] = IniRead($config, $setting_common_group, "important_item_option_" & $i, "False") == "True" ? True : False
	  Next

	  $setting_item_sell_loop_index = Int(IniRead($config, $setting_common_group, "sell_item_loop_index", "1"))
	  $setting_item_sell_maximum_level = Int(IniRead($config, $setting_common_group, "sell_item_level", "1"))
	  $setting_item_lunch_maximum_level = Int(IniRead($config, $setting_common_group, "lunchbox_item_level", "2"))
	  $setting_loot_capture_level = Int(IniRead($config, $setting_common_group, "loot_item_level", "3"))
	  $setting_reconnect_timeout_index = Int(IniRead($config, $setting_common_group, "reconnect_timeout_index", "2"))

	  $setting_daily_level = Int(IniRead($config, $setting_common_group, "daily_level", "1"))
   EndIf
EndFunc	;==>loadConfig

Func applyConfig()

   For $i = 0 To $SETTING_IMPORTANT_ITEM_OPTION_COUNT - 1
	  If $setting_important_item_options[$i] = 1 Then
		 GUICtrlSetState($checkItemOptions[$i], $GUI_CHECKED)
	  Else
		 GUICtrlSetState($checkItemOptions[$i], $GUI_UNCHECKED)
	  EndIf
   Next

   For $i = 0 To $MaxBattleTypeCount - 1
	  If $setting_use_buff_items[$i][0] = 1 Then
		 GUICtrlSetState($checkBuffAttack[$i], $GUI_CHECKED)
	  Else
		 GUICtrlSetState($checkBuffAttack[$i], $GUI_UNCHECKED)
	  EndIf

	  If $setting_use_buff_items[$i][1] = 1 Then
		 GUICtrlSetState($checkBuffDefence[$i], $GUI_CHECKED)
	  Else
		 GUICtrlSetState($checkBuffDefence[$i], $GUI_UNCHECKED)
	  EndIf

	  If $setting_use_buff_items[$i][2] = 1 Then
		 GUICtrlSetState($checkBuffHealth[$i], $GUI_CHECKED)
	  Else
		 GUICtrlSetState($checkBuffHealth[$i], $GUI_UNCHECKED)
	  EndIf

	  If $setting_use_buff_items[$i][3] = 1 Then
		 GUICtrlSetState($checkBuffAutoSkill[$i], $GUI_CHECKED)
	  Else
		 GUICtrlSetState($checkBuffAutoSkill[$i], $GUI_UNCHECKED)
	  EndIf

	  If $setting_eat_potion[$i] = 1 Then
		 GUICtrlSetState($checkBattleEatPotion[$i], $GUI_CHECKED)
	  Else
		 GUICtrlSetState($checkBattleEatPotion[$i], $GUI_UNCHECKED)
	  EndIf

	  _GUICtrlComboBox_SetCurSel($comboBattleHealthCondition[$i], Int($setting_remaining_health_index[$i]))
   Next

   If $setting_pvp_enabled = 1 Then
	  GUICtrlSetState($checkPvpEnabled, $GUI_CHECKED)
   Else
	  GUICtrlSetState($checkPvpEnabled, $GUI_UNCHECKED)
   EndIf

   If $setting_raid_enabled = 1 Then
	  GUICtrlSetState($checkRaidEnabled, $GUI_CHECKED)
   Else
	  GUICtrlSetState($checkRaidEnabled, $GUI_UNCHECKED)
   EndIf

   If $setting_daily_enabled = 1 Then
	  GUICtrlSetState($checkDailyEnabled, $GUI_CHECKED)
   Else
	  GUICtrlSetState($checkDailyEnabled, $GUI_UNCHECKED)
   EndIf

    If $setting_daily_adventure_enabled = 1 Then
	  GUICtrlSetState($checkDailyAdventureEnabled, $GUI_CHECKED)
   Else
	  GUICtrlSetState($checkDailyAdventureEnabled, $GUI_UNCHECKED)
   EndIf

   If $setting_guild_enabled = 1 Then
	  GUICtrlSetState($checkGuildEnabled, $GUI_CHECKED)
   Else
	  GUICtrlSetState($checkGuildEnabled, $GUI_UNCHECKED)
   EndIf

   _GUICtrlComboBox_SetCurSel($comboStageMajor, Int($setting_stage_major) - 1)
   loadStageMinorCombo($setting_stage_major)
   _GUICtrlComboBox_SetCurSel($comboStageMinor, Int($setting_stage_minor) - 1)

   _GUICtrlComboBox_SetCurSel($comboLootItemLevel, Int($setting_loot_capture_level))
   _GUICtrlComboBox_SetCurSel($comboSellTermLoop, Int($setting_item_sell_loop_index))
   _GUICtrlComboBox_SetCurSel($comboLunchBoxItemLevel, Int($setting_item_lunch_maximum_level))
   _GUICtrlComboBox_SetCurSel($comboSellItemLevel, Int($setting_item_sell_maximum_level))
   _GUICtrlComboBox_SetCurSel($comboReconnectTimeout, Int($setting_reconnect_timeout_index))
   _GUICtrlComboBox_SetCurSel($comboDailyLevel, Int($setting_daily_level))

   If $setting_auto_start = True Then
	  RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", "RavenBot", "REG_SZ", @ScriptDir & "\RavenBot.exe")
	  GUICtrlSetState($checkAutoStart, $GUI_CHECKED)
   Else
	  RegDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", "RavenBot")
	  GUICtrlSetState($checkAutoStart, $GUI_UNCHECKED)
   EndIf

EndFunc	;==>applyConfig


Func saveConfig()
   Local $pos = WinGetPos($mainView)
   If $pos[0] <> -32000 Then
	  IniWrite($config, $setting_common_group, "win_x", $pos[0])
	  IniWrite($config, $setting_common_group, "win_y", $pos[1])
   EndIf

   IniWrite($config, $setting_common_group, "enabled_auto_start", _IsChecked($checkAutoStart))
   IniWrite($config, $setting_common_group, "enabled_pvp", _IsChecked($checkPvpEnabled))
   IniWrite($config, $setting_common_group, "enabled_raid", _IsChecked($checkRaidEnabled))
   IniWrite($config, $setting_common_group, "enabled_guild", _IsChecked($checkGuildEnabled))
   IniWrite($config, $setting_common_group, "enabled_daily", _IsChecked($checkDailyEnabled))
   IniWrite($config, $setting_common_group, "enabled_daily_adventure", _IsChecked($checkDailyAdventureEnabled))

   For $i = 0 To $MaxBattleTypeCount - 1
	  IniWrite($config, $setting_common_group, "use_buff_" & $i & "_1", _IsChecked($checkBuffAttack[$i]))
	  IniWrite($config, $setting_common_group, "use_buff_" & $i & "_2", _IsChecked($checkBuffDefence[$i]))
	  IniWrite($config, $setting_common_group, "use_buff_" & $i & "_3", _IsChecked($checkBuffHealth[$i]))
	  IniWrite($config, $setting_common_group, "use_buff_" & $i & "_4", _IsChecked($checkBuffAutoSkill[$i]))
	  IniWrite($config, $setting_common_group, "eat_potion_" & $i, _IsChecked($checkBattleEatPotion[$i]))
	  IniWrite($config, $setting_common_group, "health_condition_index_" & $i, _GUICtrlComboBox_GetCurSel($comboBattleHealthCondition[$i]))
   Next

   For $i = 0 To $SETTING_IMPORTANT_ITEM_OPTION_COUNT - 1
	  IniWrite($config, $setting_common_group, "important_item_option_" & $i, _IsChecked($checkItemOptions[$i]))
   Next

   IniWrite($config, $setting_common_group, "stage_major", _GUICtrlComboBox_GetCurSel($comboStageMajor) + 1)
   IniWrite($config, $setting_common_group, "stage_minor", _GUICtrlComboBox_GetCurSel($comboStageMinor) + 1)
   IniWrite($config, $setting_common_group, "sell_item_level", _GUICtrlComboBox_GetCurSel($comboSellItemLevel))
   IniWrite($config, $setting_common_group, "sell_item_loop_index", _GUICtrlComboBox_GetCurSel($comboSellTermLoop))
   IniWrite($config, $setting_common_group, "lunchbox_item_level", _GUICtrlComboBox_GetCurSel($comboLunchBoxItemLevel))

   IniWrite($config, $setting_common_group, "loot_item_level", _GUICtrlComboBox_GetCurSel($comboLootItemLevel))
   IniWrite($config, $setting_common_group, "daily_level", _GUICtrlComboBox_GetCurSel($comboDailyLevel))
   IniWrite($config, $setting_common_group, "reconnect_timeout_index", _GUICtrlComboBox_GetCurSel($comboReconnectTimeout))
EndFunc	;==>saveConfig

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

