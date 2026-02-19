## main.gd
## 游戏主场景 V0.075 — 卡牌增强 + Voucher 系统
## 架构: 场景树化 + 状态单例 + 效果处理器
extends Node2D

## ========== 场景树节点引用 ==========
## 子系统（在 Main.tscn 中预设）
@onready var deck: Node = $Deck
@onready var hand: Node2D = $Hand
@onready var score_display: Node2D = $ScoreDisplay
@onready var hand_preview: Node2D = $HandPreview
@onready var joker_slot: Node2D = $JokerSlot
@onready var draw_pile: Node2D = $DrawPile
@onready var discard_pile: Node2D = $DiscardPile
@onready var consumable_slot: Node2D = $ConsumableSlot
@onready var shop: Node2D = $Shop
@onready var blind_select: Node2D = $BlindSelect
@onready var round_result: Node2D = $RoundResult
@onready var victory_celebration: Node2D = $VictoryCelebration
@onready var pause_menu: Node2D = $PauseMenu
@onready var vortex: Node2D = $VortexTransition

## UI Labels（在 Main.tscn 的 UILayer 中预设）
@onready var title_label: Label = $UILayer/TitleLabel
@onready var info_label: Label = $UILayer/InfoLabel
@onready var money_label: Label = $UILayer/MoneyLabel
@onready var ante_label: Label = $UILayer/AnteLabel
@onready var blind_label: Label = $UILayer/BlindLabel
@onready var boss_effect_label: Label = $UILayer/BossEffectLabel
@onready var joker_info_label: Label = $UILayer/JokerInfoLabel
@onready var hands_label: Label = $UILayer/HandsLabel
@onready var discards_label: Label = $UILayer/DiscardsLabel
@onready var draw_pile_label: Label = $UILayer/DrawPileLabel
@onready var discard_pile_label: Label = $UILayer/DiscardPileLabel

## UI Buttons（在 Main.tscn 的 UILayer 中预设）
@onready var play_button: Button = $UILayer/PlayButton
@onready var discard_button: Button = $UILayer/DiscardButton
@onready var sort_button: Button = $UILayer/SortButton

## ========== 动画状态（仅 main 需要的临时状态）==========
var score_anim_timer: float = 0.0
var pending_score_result: Dictionary = {}
var pending_play_cards: Array = []
var exit_cards_remaining: int = 0
var discard_exit_remaining: int = 0

## ========== Voucher 状态 ==========
var owned_voucher_ids: Array = []

## ========== TAB 状态面板 ==========
var status_panel: Node2D = null

## ========== 快捷引用 ==========
var GS: Node  ## GameState
var GC  ## GameConfig (script class, not node)

func _ready() -> void:
	GS = GameState
	GC = GameConfig
	RenderingServer.set_default_clear_color(GC.COLOR_BG)
	HandLevel.reset()

	## 设置全局字体
	var loc = Loc.i()
	if loc.cn_font:
		var theme = Theme.new()
		theme.set_default_font(loc.cn_font)
		get_tree().root.theme = theme

	## 给 UILayer 预设 Label/Button 应用中文字体
	if loc.current_language == "中文" and loc.cn_font:
		for label in [title_label, info_label, money_label, ante_label,
				blind_label, boss_effect_label, joker_info_label,
				hands_label, discards_label, draw_pile_label, discard_pile_label]:
			if label:
				loc.apply_font_to_label(label)
		for btn in [play_button, discard_button, sort_button]:
			if btn:
				loc.apply_font_to_button(btn)

	## 配置子系统
	hand.position = Vector2(GC.CENTER_X, 0)
	hand.draw_pile_source = GC.DRAW_PILE_POS
	hand_preview.position = Vector2(GC.CENTER_X, GC.PREVIEW_Y)
	boss_effect_label.position = Vector2(0, GC.PREVIEW_Y + 80)
	boss_effect_label.custom_minimum_size = Vector2(GC.DESIGN_WIDTH, 0)
	boss_effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	joker_slot.position = Vector2(GC.CENTER_X, GC.JOKER_Y)
	draw_pile.position = GC.DRAW_PILE_POS
	discard_pile.position = GC.DISCARD_PILE_POS
	consumable_slot.position = Vector2(GC.DESIGN_WIDTH - 130, 200)

	## 连接信号
	hand.hand_changed.connect(_on_hand_changed)
	shop.shop_closed.connect(_on_shop_closed)
	blind_select.blind_selected.connect(_on_blind_selected)
	blind_select.blind_skipped.connect(_on_blind_skipped)
	round_result.go_to_shop.connect(_on_go_to_shop)
	round_result.restart_game.connect(_on_restart_from_result)
	victory_celebration.celebration_done.connect(_on_celebration_done)
	joker_slot.joker_hovered.connect(_on_joker_hovered)
	joker_slot.joker_unhovered.connect(_on_joker_unhovered)
	consumable_slot.planet_used.connect(_on_planet_used)
	consumable_slot.tarot_used.connect(_on_tarot_used)
	consumable_slot.consumable_hovered.connect(_on_consumable_hovered)
	consumable_slot.consumable_unhovered.connect(_on_consumable_unhovered)
	consumable_slot.hand_ref = hand
	pause_menu.joker_slot_ref = joker_slot
	pause_menu.new_game.connect(_on_new_game_from_menu)
	pause_menu.return_to_title.connect(_on_return_to_title_from_menu)
	pause_menu.language_changed.connect(_on_language_changed)
	vortex.transition_midpoint.connect(_on_vortex_midpoint)
	vortex.transition_complete.connect(_on_vortex_complete)

	## TAB 状态面板
	status_panel = Node2D.new()
	status_panel.set_script(load("res://scripts/status_panel.gd"))
	status_panel.name = "StatusPanel"
	add_child(status_panel)

	play_button.pressed.connect(_on_play_pressed)
	discard_button.pressed.connect(_on_discard_pressed)
	sort_button.pressed.connect(_on_sort_toggle)

	## 禁用所有按钮的 TAB 焦点导航，防止 TAB 被 UI 拦截
	for btn in [play_button, discard_button, sort_button]:
		if btn:
			btn.focus_mode = Control.FOCUS_NONE

	## draw/discard pile types
	draw_pile.set("pile_type", 0)
	discard_pile.set("pile_type", 1)

	_update_ui()

	## 创建标题界面（唯一仍需动态创建的节点，因为通关后要重建）
	_create_title_screen()

## ========== Voucher 辅助 ==========

func has_voucher(voucher_id: String) -> bool:
	return voucher_id in owned_voucher_ids

func _apply_voucher_bonuses() -> void:
	## 在每回合开始时应用 voucher 加成
	for vid in owned_voucher_ids:
		var v = VoucherDatabase.get_voucher_by_id(vid)
		if v == null:
			continue
		match v.effect:
			VoucherData.VoucherEffect.BONUS_HAND:
				GS.hands_remaining += int(v.value)
			VoucherData.VoucherEffect.BONUS_DISCARD:
				GS.discards_remaining += int(v.value)
			VoucherData.VoucherEffect.INTEREST_CAP_UP:
				## 利息上限提升（存在 GameState 中处理）
				pass
			VoucherData.VoucherEffect.JOKER_SLOT:
				joker_slot.MAX_JOKERS = 5 + int(v.value)
			VoucherData.VoucherEffect.CONSUMABLE_SLOT:
				consumable_slot.MAX_CONSUMABLES = 2 + int(v.value)
			## REROLL_DISCOUNT 和 SHOP_DISCOUNT 在 shop.gd 中处理

## ========== 标题界面（动态创建，因为通关后需要重建）==========

func _create_title_screen() -> void:
	var title_screen = Node2D.new()
	title_screen.set_script(load("res://scripts/title_screen.gd"))
	title_screen.name = "TitleScreen"
	add_child(title_screen)
	title_screen.open_title_menu.connect(_on_title_open_menu)
	title_screen.start_game.connect(_on_title_start_game)

func _on_title_open_menu() -> void:
	if pause_menu:
		pause_menu.open_as_title()

func _on_new_game_from_menu() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.visible = false
	if pause_menu:
		pause_menu.visible = false
	vortex.start_transition()

func _on_return_to_title_from_menu() -> void:
	## 关闭所有遮罩
	shop.visible = false
	blind_select.visible = false
	round_result.visible = false
	_return_to_title()

func _on_language_changed() -> void:
	## 切换语言后刷新所有 UILayer Label/Button 的字体和文本
	var loc = Loc.i()
	if loc.current_language == "中文" and loc.cn_font:
		for label in [title_label, info_label, money_label, ante_label,
				blind_label, boss_effect_label, joker_info_label,
				hands_label, discards_label, draw_pile_label, discard_pile_label]:
			if label:
				loc.apply_font_to_label(label)
		for btn in [play_button, discard_button, sort_button]:
			if btn:
				loc.apply_font_to_button(btn)
	## 刷新所有 UI 文本
	_update_ui()

func _on_vortex_midpoint() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.queue_free()
	_restart_game()
	info_label.text = ""
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))

func _on_vortex_complete() -> void:
	_open_blind_select()

func _on_title_start_game() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.queue_free()
	_open_blind_select()

## ========== 盲注选择 ==========

func _open_blind_select() -> void:
	if GS.ante_boss == null:
		GS.ante_boss = BlindData.get_random_boss(GS.used_boss_names)
		GS.used_boss_names.append(GS.ante_boss.name)
	blind_select.open_select(GS.current_ante, GS.blind_index, GS.ante_boss)

func _on_blind_selected(blind_type: int, boss) -> void:
	var target = BlindData.get_blind_target(GS.current_ante, blind_type as BlindData.BlindType)
	GS.start_round(blind_type, boss)
	## 应用 Voucher 加成（额外手数/弃牌）
	_apply_voucher_bonuses()
	score_display.set_target(target)
	score_display.reset_round()

	boss_effect_label.text = ""
	if GS.current_boss != null:
		boss_effect_label.text = "⚠ " + Loc.i().t("BOSS") + ": " + Loc.i().t(GS.current_boss.name) + " - " + Loc.i().t(GS.current_boss.description)

	deck.shuffle()
	for card in hand.cards_in_hand.duplicate():
		card.queue_free()
	hand.cards_in_hand.clear()

	_draw_initial_hand()
	play_button.disabled = false
	discard_button.disabled = false
	hand_preview.hide_preview()

	var blind_name = _get_current_blind_name()
	info_label.text = Loc.i().t(blind_name) + " - " + Loc.i().t("Target") + ": " + str(target)
	info_label.add_theme_color_override("font_color", GC.COLOR_INFO)
	_update_ui()

func _on_blind_skipped(skip_reward: String) -> void:
	_apply_skip_reward(skip_reward)
	_advance_blind()

func _apply_skip_reward(reward_id: String) -> void:
	match reward_id:
		"tarot":
			var tarots = TarotDatabase.get_random_tarots(1)
			if tarots.size() > 0 and not consumable_slot.is_full():
				consumable_slot.add_tarot(tarots[0])
				info_label.text = "🔮 " + Loc.i().t("Skip reward") + ": " + Loc.i().t(tarots[0].tarot_name) + "!"
				info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))
			elif tarots.size() > 0:
				info_label.text = "🔮 " + Loc.i().t("Consumable slots full — reward lost!")
				info_label.add_theme_color_override("font_color", GC.COLOR_WARNING)
		"planet":
			var planets = PlanetDatabase.get_random_planets(1)
			if planets.size() > 0 and not consumable_slot.is_full():
				consumable_slot.add_planet(planets[0])
				info_label.text = "🪐 " + Loc.i().t("Skip reward") + ": " + Loc.i().t(planets[0].planet_name) + "!"
				info_label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.95))
			elif planets.size() > 0:
				info_label.text = "🪐 " + Loc.i().t("Consumable slots full — reward lost!")
				info_label.add_theme_color_override("font_color", GC.COLOR_WARNING)
		"money":
			GS.money += 3
			info_label.text = "💰 " + Loc.i().t("Skip reward") + ": +$3!"
			info_label.add_theme_color_override("font_color", GC.COLOR_MONEY)
		"level_up":
			var types = PokerHand.HandType.values()
			var random_type = types[randi() % types.size()]
			HandLevel.planet_level_up(random_type, 15, 1)
			var hname = PokerHand.get_hand_name(random_type)
			var lvl = HandLevel.get_level_info(random_type)["level"]
			info_label.text = "⬆️ " + Loc.i().t("Skip reward") + ": " + Loc.i().t(hname) + " → Lv." + str(lvl) + "!"
			info_label.add_theme_color_override("font_color", GC.COLOR_SUCCESS)

func _advance_blind() -> void:
	GS.advance_blind()
	if GS.current_ante > GC.MAX_ANTE:
		_show_game_victory()
		return
	_open_blind_select()

## ========== 游戏主循环 ==========

func _process(delta: float) -> void:
	var overlay_open = (shop.visible or blind_select.visible or round_result.visible)
	GS.overlay_active = overlay_open
	hand.set_process(!overlay_open)
	consumable_slot.set_process_input(!overlay_open)
	for card in hand.cards_in_hand:
		if is_instance_valid(card):
			for child in card.get_children():
				if child is Area2D:
					child.input_pickable = !overlay_open

	if GS.is_score_animating:
		score_anim_timer += delta
		if score_anim_timer > 1.0:
			_start_exit_animation()

func _draw_initial_hand() -> void:
	var drawn = deck.draw_cards(GC.INITIAL_HAND_SIZE)
	for card_data in drawn:
		hand.add_card(card_data, true)
	hand.request_auto_sort()
	_update_ui()

func _on_hand_changed() -> void:
	_update_preview()

func _update_preview() -> void:
	var selected = hand.get_selected_cards()
	if selected.is_empty():
		hand_preview.hide_preview()
		return
	var base_result = PokerHand.calculate_score(selected)
	_apply_boss_to_result(base_result)
	var joker_result = JokerEffect.apply_jokers(
		joker_slot.get_owned_jokers(), base_result, base_result["scoring_cards"])
	var preview = base_result.duplicate()
	preview["total_chips"] = joker_result["total_chips"]
	preview["total_mult"] = joker_result["total_mult"]
	preview["final_score"] = joker_result["final_score"]
	hand_preview.update_preview(preview)

## ========== Boss 效果（委托 BossEffectProcessor）==========

func _apply_boss_to_result(result: Dictionary) -> void:
	BossEffectProcessor.apply_to_result(result, GS.current_boss, GS.hands_played_this_round)

## ========== 出牌 ==========

func _on_play_pressed() -> void:
	if GS.hands_remaining <= 0 or GS.is_score_animating or GS.is_round_ended or GS.is_discarding:
		return
	var selected = hand.get_selected_cards()
	if selected.is_empty():
		info_label.text = Loc.i().t("Select cards first")
		return
	if selected.size() > GC.MAX_SELECT:
		info_label.text = "Max " + str(GC.MAX_SELECT) + " cards!"
		return

	var base_result = PokerHand.calculate_score(selected)
	_apply_boss_to_result(base_result)
	var joker_result = JokerEffect.apply_jokers(
		joker_slot.get_owned_jokers(), base_result, base_result["scoring_cards"])

	var final_result = base_result.duplicate()
	final_result["total_chips"] = joker_result["total_chips"]
	final_result["total_mult"] = joker_result["total_mult"]
	final_result["final_score"] = joker_result["final_score"]

	var level_result = HandLevel.record_play(base_result["hand_type"])
	for trigger in joker_result["joker_triggers"]:
		joker_slot.trigger_joker_animation(trigger["joker"])

	GS.is_score_animating = true
	score_anim_timer = 0.0
	pending_score_result = final_result
	pending_play_cards = selected.duplicate()

	## 记录打出的牌用于 TAB 面板追踪
	if status_panel:
		status_panel.record_played_cards(selected)

	var scoring_cards = base_result["scoring_cards"]
	for i in range(scoring_cards.size()):
		scoring_cards[i].play_score_animation(i * 0.12)
	score_display.show_score(final_result)

	var info_text = final_result["hand_name"] + "! +" + str(final_result["final_score"])
	if not joker_result["joker_triggers"].is_empty():
		var trigger_texts: PackedStringArray = []
		for trigger in joker_result["joker_triggers"]:
			trigger_texts.append(trigger["joker"].joker_name + " " + trigger["text"])
		info_text += " [" + ", ".join(trigger_texts) + "]"

	if level_result["leveled_up"]:
		score_display.show_level_up(final_result["hand_name"], level_result["level"])
		info_label.add_theme_color_override("font_color", GC.COLOR_SUCCESS)
	else:
		info_label.add_theme_color_override("font_color", GC.COLOR_INFO)

	info_label.text = info_text
	hand_preview.hide_preview()
	play_button.disabled = true
	discard_button.disabled = true
	GS.use_hand()

## ========== 弃牌 ==========

func _on_discard_pressed() -> void:
	if GS.discards_remaining <= 0 or GS.is_score_animating or exit_cards_remaining > 0 or GS.is_round_ended or GS.is_discarding:
		return
	var selected = hand.get_selected_cards()
	if selected.is_empty():
		info_label.text = Loc.i().t("Select cards first")
		return

	play_button.disabled = true
	discard_button.disabled = true
	GS.is_discarding = true

	var removed = hand.remove_selected_cards_for_animation()
	GS.use_discard(removed.size())
	discard_exit_remaining = removed.size()

	var discard_local = GC.DISCARD_PILE_POS - hand.global_position
	for i in range(removed.size()):
		var card = removed[i]
		card.card_exit_done.connect(_on_discard_exit_done)
		card.animate_exit(discard_local, i * 0.06)

	hand_preview.hide_preview()
	info_label.text = "Discarded " + str(removed.size()) + " cards"
	info_label.add_theme_color_override("font_color", GC.COLOR_INFO)

func _on_discard_exit_done(card_node: Node2D) -> void:
	card_node.queue_free()
	discard_exit_remaining -= 1
	discard_pile.set_count(GS.total_discarded)
	if discard_exit_remaining <= 0:
		_finish_discard()

func _finish_discard() -> void:
	GS.is_discarding = false
	var to_draw = GC.INITIAL_HAND_SIZE - hand.cards_in_hand.size()
	var new_cards = deck.draw_cards(to_draw)
	for card_data in new_cards:
		hand.add_card(card_data, true)
	if new_cards.size() > 0:
		hand.request_auto_sort()
	play_button.disabled = false
	discard_button.disabled = false
	_update_ui()

## ========== 出牌后退场动画 ==========

func _start_exit_animation() -> void:
	GS.is_score_animating = false
	var discard_local = GC.DISCARD_PILE_POS - hand.global_position
	exit_cards_remaining = pending_play_cards.size()
	GS.total_discarded += pending_play_cards.size()

	for i in range(pending_play_cards.size()):
		var card = pending_play_cards[i]
		if is_instance_valid(card):
			card.card_exit_done.connect(_on_card_exit_done)
			card.animate_exit(discard_local, i * 0.08)
	if exit_cards_remaining <= 0:
		_finish_after_exit()

func _on_card_exit_done(card_node: Node2D) -> void:
	var idx = hand.cards_in_hand.find(card_node)
	if idx >= 0:
		hand.cards_in_hand.remove_at(idx)
	card_node.queue_free()
	exit_cards_remaining -= 1
	discard_pile.set_count(GS.total_discarded)
	if exit_cards_remaining <= 0:
		_finish_after_exit()

func _finish_after_exit() -> void:
	pending_play_cards.clear()
	hand._arrange_cards()

	if not GS.is_round_ended and score_display.round_score >= score_display.target_score:
		_trigger_victory()
		return

	var to_draw = GC.INITIAL_HAND_SIZE - hand.cards_in_hand.size()
	var new_cards = deck.draw_cards(to_draw)
	for card_data in new_cards:
		hand.add_card(card_data, true)
	if new_cards.size() > 0:
		hand.request_auto_sort()
	play_button.disabled = false
	discard_button.disabled = false

	if GS.hands_remaining <= 0 and not GS.is_round_ended:
		_trigger_defeat()
	else:
		_update_ui()

## ========== 回合结束 ==========

func _trigger_victory() -> void:
	GS.is_round_ended = true
	play_button.disabled = true
	discard_button.disabled = true
	var reward = BlindData.get_blind_reward(GS.current_blind_type)
	var income = GS.calculate_income(true) + reward
	GS.money += income
	var blind_name = _get_current_blind_name()
	_update_ui()
	await get_tree().create_timer(0.8).timeout
	round_result.show_victory(score_display.round_score, score_display.target_score, income, blind_name)

func _trigger_defeat() -> void:
	GS.is_round_ended = true
	play_button.disabled = true
	discard_button.disabled = true
	var blind_name = _get_current_blind_name()
	await get_tree().create_timer(0.8).timeout
	round_result.show_defeat(score_display.round_score, score_display.target_score, blind_name)

func _get_current_blind_name() -> String:
	if GS.current_boss and GS.current_blind_type == BlindData.BlindType.BOSS_BLIND:
		return GS.current_boss.name
	return BlindData.get_blind_name(GS.current_blind_type)

## ========== 商店 ==========

func _on_go_to_shop() -> void:
	var owned_ids: Array = []
	for j in joker_slot.get_owned_jokers():
		owned_ids.append(j.id)
	shop.open_shop(GS.money, owned_ids, joker_slot, consumable_slot, owned_voucher_ids)

func _on_shop_closed() -> void:
	GS.money = shop.get_money()
	## 同步 voucher 购买
	owned_voucher_ids = shop.get_owned_voucher_ids()
	boss_effect_label.text = ""
	_advance_blind()

func _on_restart_from_result() -> void:
	vortex.start_transition()

## ========== 胜利 ==========

func _show_game_victory() -> void:
	info_label.text = ""
	if victory_celebration:
		victory_celebration.start_celebration()

func _on_celebration_done() -> void:
	info_label.text = "🏆 " + Loc.i().t("CONGRATULATIONS!") + " 🏆\n" + Loc.i().t("Click to return to title")
	info_label.add_theme_color_override("font_color", GC.COLOR_GOLD)
	GS.is_game_won = true

func _return_to_title() -> void:
	GS.reset()
	HandLevel.reset()
	owned_voucher_ids.clear()
	if status_panel:
		status_panel.reset_tracking()
	## 重置动态上限
	joker_slot.MAX_JOKERS = 5
	consumable_slot.MAX_CONSUMABLES = 2

	while joker_slot.get_owned_jokers().size() > 0:
		joker_slot.remove_joker(0)
	consumable_slot.clear_all()

	score_display.set_target(300)
	score_display.reset_round()
	deck.shuffle()
	for card in hand.cards_in_hand.duplicate():
		card.queue_free()
	hand.cards_in_hand.clear()
	play_button.disabled = false
	discard_button.disabled = false
	hand_preview.hide_preview()
	boss_effect_label.text = ""
	info_label.text = ""
	info_label.add_theme_color_override("font_color", GC.COLOR_INFO)
	_update_ui()

	var vc = get_node_or_null("VictoryCelebration")
	if vc:
		vc.stop_celebration()

	_create_title_screen()

func _restart_game() -> void:
	_return_to_title_state()
	info_label.text = ""
	info_label.add_theme_color_override("font_color", GC.COLOR_INFO)

func _return_to_title_state() -> void:
	GS.reset()
	HandLevel.reset()
	owned_voucher_ids.clear()
	if status_panel:
		status_panel.reset_tracking()
	joker_slot.MAX_JOKERS = 5
	consumable_slot.MAX_CONSUMABLES = 2
	while joker_slot.get_owned_jokers().size() > 0:
		joker_slot.remove_joker(0)
	consumable_slot.clear_all()
	score_display.set_target(300)
	score_display.reset_round()
	deck.shuffle()
	for card in hand.cards_in_hand.duplicate():
		card.queue_free()
	hand.cards_in_hand.clear()
	play_button.disabled = false
	discard_button.disabled = false
	hand_preview.hide_preview()
	boss_effect_label.text = ""
	_update_ui()

## ========== 消耗品回调 ==========

func _on_planet_used(planet: PlanetData) -> void:
	var result = HandLevel.planet_level_up(planet.hand_type, planet.level_chips, planet.level_mult)
	var hand_name = PokerHand.get_hand_name(planet.hand_type)
	info_label.text = planet.emoji + " " + Loc.i().t(planet.planet_name) + "! " + Loc.i().t(hand_name) + " → Lv." + str(result["new_level"])
	info_label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.95))
	score_display.show_level_up(hand_name, result["new_level"])
	_update_preview()

func _on_tarot_used(tarot: TarotData) -> void:
	var selected = hand.get_selected_cards()
	## 处理增强塔罗牌（直接在 main 中处理，因为需要修改 card_data）
	if tarot.effect == TarotData.TarotEffect.ADD_FOIL:
		if selected.size() >= 1:
			selected[0].card_data.enhancement = CardData.Enhancement.FOIL
			selected[0].is_selected = false
			selected[0].queue_redraw()
			info_label.text = "✨ " + Loc.i().t("Foil") + "! " + selected[0].card_data.get_display_name() + " +50 " + Loc.i().t("Chips")
			info_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
		_update_preview()
		return
	if tarot.effect == TarotData.TarotEffect.ADD_HOLOGRAPHIC:
		if selected.size() >= 1:
			selected[0].card_data.enhancement = CardData.Enhancement.HOLOGRAPHIC
			selected[0].is_selected = false
			selected[0].queue_redraw()
			info_label.text = "🌈 " + Loc.i().t("Holographic") + "! " + selected[0].card_data.get_display_name() + " +10 " + Loc.i().t("Mult")
			info_label.add_theme_color_override("font_color", Color(0.8, 0.5, 1.0))
		_update_preview()
		return
	if tarot.effect == TarotData.TarotEffect.ADD_POLYCHROME:
		if selected.size() >= 1:
			selected[0].card_data.enhancement = CardData.Enhancement.POLYCHROME
			selected[0].is_selected = false
			selected[0].queue_redraw()
			info_label.text = "🎨 " + Loc.i().t("Polychrome") + "! " + selected[0].card_data.get_display_name() + " ×1.5 " + Loc.i().t("Mult")
			info_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
		_update_preview()
		return

	## 其他塔罗效果委托给 TarotEffectProcessor
	var result = TarotEffectProcessor.apply(tarot, selected, hand, consumable_slot)
	if result["message"] != "":
		info_label.text = result["message"]
		info_label.add_theme_color_override("font_color", result["color"])
	## GAIN_MONEY 需要刷新 UI
	if tarot.effect == TarotData.TarotEffect.GAIN_MONEY:
		_update_ui()
	## RANDOM_LEVEL_UP 需要显示升级动画
	if result.has("level_up"):
		score_display.show_level_up(result["level_up"]["hand_name"], result["level_up"]["level"])
	_update_preview()

## ========== Joker/Consumable 悬停 ==========

func _on_joker_hovered(joker_data: JokerData) -> void:
	joker_info_label.text = Loc.i().t(joker_data.joker_name) + ": " + Loc.i().t(joker_data.description)

func _on_joker_unhovered() -> void:
	joker_info_label.text = ""

func _on_consumable_hovered(text: String) -> void:
	joker_info_label.text = text

func _on_consumable_unhovered() -> void:
	joker_info_label.text = ""

func _on_sort_toggle() -> void:
	if GS.is_score_animating or GS.is_round_ended or GS.is_discarding: return
	hand.toggle_sort()

## ========== UI 更新 ==========

func _update_ui() -> void:
	if hands_label:
		hands_label.text = Loc.i().t("Hands") + ": " + str(GS.hands_remaining)
	if discards_label:
		discards_label.text = Loc.i().t("Discard") + ": " + str(GS.discards_remaining)
	if draw_pile:
		draw_pile.set_count(deck.remaining())
	if discard_pile:
		discard_pile.set_count(GS.total_discarded)
	if money_label:
		money_label.text = "$ " + str(GS.money)
	if ante_label:
		ante_label.text = Loc.i().t("Ante") + " " + str(GS.current_ante) + " / " + str(GC.MAX_ANTE)
	if blind_label:
		blind_label.text = Loc.i().t(_get_current_blind_name())

## ========== 调试快捷键 ==========

func _unhandled_input(event: InputEvent) -> void:
	if GS.is_game_won and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GS.is_game_won = false
		_return_to_title()
		return
	if not event is InputEventKey:
		return
	## TAB 松开时隐藏状态面板
	if not event.pressed and event.keycode == KEY_TAB:
		if status_panel and status_panel.visible:
			status_panel.hide_panel()
		get_viewport().set_input_as_handled()
		return
	if not event.pressed:
		return
	match event.keycode:
		KEY_TAB:
			## TAB 状态面板 — 忽略长按重复
			if event.is_echo():
				get_viewport().set_input_as_handled()
				return
			if status_panel:
				var voucher_ids: Array = []
				if shop.visible and shop.has_method("get_owned_voucher_ids"):
					voucher_ids = shop.get_owned_voucher_ids()
				else:
					voucher_ids = owned_voucher_ids
				status_panel.update_vouchers(voucher_ids)
				if status_panel.visible:
					status_panel.hide_panel()
				else:
					status_panel.show_panel()
				get_viewport().set_input_as_handled()
		KEY_F1:
			GS.money += 100
			_update_ui()
			if shop.visible:
				shop.money = GS.money
				shop._build_ui()
			info_label.text = "🔧 DEBUG: +$100"
			info_label.add_theme_color_override("font_color", GC.COLOR_DEBUG)
		KEY_F2:
			GS.current_ante = GC.MAX_ANTE
			GS.blind_index = 2
			GS.ante_boss = BlindData.get_random_boss(GS.used_boss_names)
			shop.visible = false
			blind_select.visible = false
			round_result.visible = false
			GS.is_round_ended = false
			GS.is_discarding = false
			_on_blind_selected(BlindData.BlindType.BOSS_BLIND, GS.ante_boss)
			info_label.text = "🔧 DEBUG: Jumped to Ante 8 Boss!"
			info_label.add_theme_color_override("font_color", GC.COLOR_DEBUG)
		KEY_F3:
			shop.visible = false
			blind_select.visible = false
			round_result.visible = false
			_show_game_victory()
		KEY_F4:
			if not GS.is_round_ended:
				var target = score_display.target_score
				score_display.round_score = target + 100
				score_display.target_round_score = float(target + 100)
				score_display.display_round_score = float(target + 100)
				info_label.text = "🔧 DEBUG: Score set to target!"
				info_label.add_theme_color_override("font_color", GC.COLOR_DEBUG)
				_trigger_victory()
		KEY_F5:
			if joker_slot.get_owned_jokers().size() < joker_slot.MAX_JOKERS:
				var owned_ids: Array = []
				for j in joker_slot.get_owned_jokers():
					owned_ids.append(j.id)
				var new_jokers = JokerDatabase.get_random_jokers(1, owned_ids)
				if new_jokers.size() > 0:
					joker_slot.add_joker(new_jokers[0])
					info_label.text = "🔧 DEBUG: Added " + new_jokers[0].joker_name
					info_label.add_theme_color_override("font_color", GC.COLOR_DEBUG)
