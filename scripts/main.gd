## main.gd
## 游戏主场景 V0.071 — 架构重构: 场景树化 + 状态单例
## 变更: @onready 引用替代手动节点创建, GameState 管理状态, GameConfig 管理常量
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

	## 配置子系统
	hand.position = Vector2(GC.CENTER_X, 0)
	hand.draw_pile_source = GC.DRAW_PILE_POS
	hand_preview.position = Vector2(GC.CENTER_X, GC.PREVIEW_Y)
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
	if pause_menu.has_signal("continue_game"):
		pause_menu.continue_game.connect(_on_continue_from_menu)
	vortex.transition_midpoint.connect(_on_vortex_midpoint)
	vortex.transition_complete.connect(_on_vortex_complete)
	play_button.pressed.connect(_on_play_pressed)
	discard_button.pressed.connect(_on_discard_pressed)
	sort_button.pressed.connect(_on_sort_toggle)

	## draw/discard pile types
	draw_pile.set("pile_type", 0)
	discard_pile.set("pile_type", 1)

	_update_ui()

	## 创建标题界面（唯一仍需动态创建的节点，因为通关后要重建）
	_create_title_screen()

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

## 标题菜单点击 Continue → 读档恢复
func _on_continue_from_menu() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.visible = false
		ts.stop_bgm()
	if pause_menu:
		pause_menu.visible = false
	if SaveManager.load_game(self):
		_update_ui()
		_open_blind_select()
	else:
		vortex.start_transition()

func _on_vortex_midpoint() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.queue_free()
	_restart_game()

func _on_vortex_complete() -> void:
	_open_blind_select()

func _on_title_start_game() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.queue_free()
	_open_blind_select()

## ========== 盲注选择 ==========

func _open_blind_select() -> void:
	## 自动存档（回合间安全点）
	SaveManager.save_game(self)
	if GS.ante_boss == null:
		GS.ante_boss = BlindData.get_random_boss(GS.used_boss_names)
		GS.used_boss_names.append(GS.ante_boss.name)
	blind_select.open_select(GS.current_ante, GS.blind_index, GS.ante_boss)

func _on_blind_selected(blind_type: int, boss) -> void:
	var target = BlindData.get_blind_target(GS.current_ante, blind_type as BlindData.BlindType)
	GS.start_round(blind_type, boss)
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

## ========== Boss 效果 ==========

func _apply_boss_to_result(result: Dictionary) -> void:
	if GS.current_boss == null:
		return
	match GS.current_boss.effect:
		BlindData.BossEffect.NO_FACE_CARDS:
			var new_chips = result["base_chips"] + result.get("level_bonus_chips", 0)
			for card in result["scoring_cards"]:
				if card.card_data.rank < 11:
					new_chips += card.card_data.get_chip_value()
			result["total_chips"] = new_chips
			result["final_score"] = new_chips * result["total_mult"]
		BlindData.BossEffect.NO_HEARTS:
			_debuff_suit(result, CardData.Suit.HEARTS)
		BlindData.BossEffect.NO_DIAMONDS:
			_debuff_suit(result, CardData.Suit.DIAMONDS)
		BlindData.BossEffect.NO_SPADES:
			_debuff_suit(result, CardData.Suit.SPADES)
		BlindData.BossEffect.NO_CLUBS:
			_debuff_suit(result, CardData.Suit.CLUBS)
		BlindData.BossEffect.DEBUFF_FIRST_HAND:
			if GS.hands_played_this_round == 0:
				result["total_chips"] = int(result["total_chips"] / 2)
				result["final_score"] = int(result["total_chips"] * result["total_mult"])

func _debuff_suit(result: Dictionary, suit) -> void:
	var new_chips = result["base_chips"] + result.get("level_bonus_chips", 0)
	for card in result["scoring_cards"]:
		if card.card_data.suit != suit:
			new_chips += card.card_data.get_chip_value()
	result["total_chips"] = new_chips
	result["final_score"] = new_chips * result["total_mult"]

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
	SaveManager.delete_save()
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
	shop.open_shop(GS.money, owned_ids, joker_slot, consumable_slot)

func _on_shop_closed() -> void:
	GS.money = shop.get_money()
	boss_effect_label.text = ""
	_advance_blind()

func _on_restart_from_result() -> void:
	vortex.start_transition()

## ========== 胜利 ==========

func _show_game_victory() -> void:
	SaveManager.delete_save()
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
	_open_blind_select()

func _return_to_title_state() -> void:
	GS.reset()
	HandLevel.reset()
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
	match tarot.effect:
		TarotData.TarotEffect.COPY_CARD:
			if selected.size() >= 1:
				var src = selected[0]
				var new_data = CardData.new()
				new_data.suit = src.card_data.suit
				new_data.rank = src.card_data.rank
				hand.add_card(new_data, true)
				info_label.text = "🃏 Copied " + src.card_data.get_display_name() + "!"
				info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

		TarotData.TarotEffect.RANDOM_SUIT:
			if selected.size() >= 1:
				var card = selected[0]
				var suits = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS, CardData.Suit.CLUBS, CardData.Suit.SPADES]
				var old_suit = card.card_data.suit
				suits.erase(old_suit)
				card.card_data.suit = suits[randi() % suits.size()]
				card.is_selected = false
				card.queue_redraw()
				info_label.text = "🎩 Changed to " + card.card_data.get_suit_symbol() + "!"
				info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

		TarotData.TarotEffect.CHANGE_TO_HEARTS:
			_change_suit(selected, CardData.Suit.HEARTS, "♥")

		TarotData.TarotEffect.CHANGE_TO_SPADES:
			_change_suit(selected, CardData.Suit.SPADES, "♠")

		TarotData.TarotEffect.CHANGE_TO_CLUBS:
			_change_suit(selected, CardData.Suit.CLUBS, "♣")

		TarotData.TarotEffect.CHANGE_TO_DIAMONDS:
			_change_suit(selected, CardData.Suit.DIAMONDS, "♦")

		TarotData.TarotEffect.DESTROY_CARD:
			if selected.size() >= 1:
				var card = selected[0]
				var name_text = card.card_data.get_display_name()
				hand.cards_in_hand.erase(card)
				card.queue_free()
				hand._arrange_cards()
				hand.hand_changed.emit()
				info_label.text = "💀 Destroyed " + name_text + "!"
				info_label.add_theme_color_override("font_color", GC.COLOR_ERROR)

		TarotData.TarotEffect.GAIN_MONEY:
			GS.money += 5
			info_label.text = "🔮 " + Loc.i().t("The Hermit") + " +$5!"
			info_label.add_theme_color_override("font_color", GC.COLOR_MONEY)
			_update_ui()

		TarotData.TarotEffect.CLONE_CARD:
			if selected.size() >= 2:
				var left_idx = hand.cards_in_hand.find(selected[0])
				var right_idx = hand.cards_in_hand.find(selected[1])
				var src_card: Node2D
				var dst_card: Node2D
				if left_idx < right_idx:
					dst_card = selected[0]
					src_card = selected[1]
				else:
					dst_card = selected[1]
					src_card = selected[0]
				dst_card.card_data.suit = src_card.card_data.suit
				dst_card.card_data.rank = src_card.card_data.rank
				dst_card.is_selected = false
				src_card.is_selected = false
				dst_card.queue_redraw()
				src_card.queue_redraw()
				info_label.text = "⚖️ Card transformed to " + src_card.card_data.get_display_name() + "!"
				info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

		TarotData.TarotEffect.SPAWN_TAROT:
			var empty = consumable_slot.get_empty_slots()
			var to_add = mini(2, empty)
			if to_add <= 0:
				info_label.text = "🌎 " + Loc.i().t("No empty slots!")
				info_label.add_theme_color_override("font_color", GC.COLOR_ERROR)
			else:
				var new_tarots = TarotDatabase.get_random_tarots(to_add)
				var names: PackedStringArray = []
				for t in new_tarots:
					consumable_slot.add_tarot(t)
					names.append(t.tarot_name)
				info_label.text = "🌎 Created " + ", ".join(names) + "!"
				info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

		TarotData.TarotEffect.SPAWN_PLANET:
			var empty = consumable_slot.get_empty_slots()
			var to_add = mini(2, empty)
			if to_add <= 0:
				info_label.text = "☀️ " + Loc.i().t("No empty slots!")
				info_label.add_theme_color_override("font_color", GC.COLOR_ERROR)
			else:
				var new_planets = PlanetDatabase.get_random_planets(to_add)
				var names: PackedStringArray = []
				for p in new_planets:
					consumable_slot.add_planet(p)
					names.append(p.planet_name)
				info_label.text = "☀️ Created " + ", ".join(names) + "!"
				info_label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.95))

		TarotData.TarotEffect.RANDOM_LEVEL_UP:
			var types = PokerHand.HandType.values()
			var random_type = types[randi() % types.size()]
			HandLevel.planet_level_up(random_type, 20, 2)
			HandLevel.planet_level_up(random_type, 20, 2)
			var hname = PokerHand.get_hand_name(random_type)
			var lvl = HandLevel.get_level_info(random_type)["level"]
			info_label.text = "🎰 " + Loc.i().t(hname) + " → Lv." + str(lvl) + "!"
			info_label.add_theme_color_override("font_color", GC.COLOR_MONEY)
			score_display.show_level_up(hname, lvl)

	_update_preview()

func _change_suit(cards: Array, new_suit: int, symbol: String) -> void:
	var changed = 0
	for card in cards:
		card.card_data.suit = new_suit
		card.is_selected = false
		card.queue_redraw()
		changed += 1
	info_label.text = "Changed " + str(changed) + " card(s) to " + symbol + "!"
	info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

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
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_F1:
			GS.money += 100
			_update_ui()
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
			if joker_slot.get_owned_jokers().size() < GC.MAX_JOKER_SLOTS:
				var owned_ids: Array = []
				for j in joker_slot.get_owned_jokers():
					owned_ids.append(j.id)
				var new_jokers = JokerDatabase.get_random_jokers(1, owned_ids)
				if new_jokers.size() > 0:
					joker_slot.add_joker(new_jokers[0])
					info_label.text = "🔧 DEBUG: Added " + new_jokers[0].joker_name
					info_label.add_theme_color_override("font_color", GC.COLOR_DEBUG)
