## main.gd
## 游戏主场景 V9 - 弃牌动画 + 空起始 + 顺序盲注 + 难度曲线
extends Node2D

var deck: Node
var hand: Node2D
var score_display: Node2D
var hand_preview: Node2D
var joker_slot: Node2D
var shop: Node2D
var blind_select: Node2D
var round_result: Node2D
var joker_info_label: Label
var info_label: Label
var money_label: Label
var ante_label: Label
var blind_label: Label
var boss_effect_label: Label
var play_button: Button
var discard_button: Button
var sort_suit_button: Button  ## 合并排序按钮
var hands_label: Label
var discards_label: Label
var draw_pile: Node2D
var discard_pile: Node2D
var consumable_slot: Node2D

const INITIAL_HAND_SIZE: int = 8
const MAX_SELECT: int = 5

var hands_remaining: int = 4
var discards_remaining: int = 3
var total_discarded: int = 0
var money: int = 4
var hands_played_this_round: int = 0

## Ante / Blind 状态
var current_ante: int = 1
var current_blind_type: BlindData.BlindType = BlindData.BlindType.SMALL_BLIND
var current_boss: BlindData.BossBlind = null
var blind_index: int = 0       ## 0=Small, 1=Big, 2=Boss（当前Ante进度）
var ante_boss: BlindData.BossBlind = null  ## 每个Ante的Boss在开始时确定
var used_boss_names: Array = []  ## 已出现过的 Boss（避免重复）

const MAX_ANTE: int = 8
const DESIGN_WIDTH: float = 1920.0
const DESIGN_HEIGHT: float = 1280.0
const CENTER_X: float = DESIGN_WIDTH / 2.0

const BASE_INCOME: int = 3
const INTEREST_CAP: int = 5
const WIN_BONUS: int = 1
const STARTING_MONEY: int = 4

const JOKER_Y: float = 175.0
const JOKER_INFO_Y: float = 275.0
const PREVIEW_Y: float = 420.0
const HAND_Y: float = 640.0
const BUTTON_Y: float = 880.0
const PILE_Y: float = 930.0
const DRAW_PILE_POS: Vector2 = Vector2(1780.0, PILE_Y)
const DISCARD_PILE_POS: Vector2 = Vector2(140.0, PILE_Y)
const SORT_X: float = 280.0

var is_score_animating: bool = false
var score_anim_timer: float = 0.0
var pending_score_result: Dictionary = {}
var pending_play_cards: Array = []
var exit_cards_remaining: int = 0
var round_ended: bool = false

## 弃牌动画状态
var is_discarding: bool = false
var discard_exit_remaining: int = 0

## 漩涡过渡
var vortex: Node2D = null


func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font: lbl.add_theme_font_override("font", font)

func _fb(btn: Button) -> void:
	var font = Loc.i().cn_font
	if font: btn.add_theme_font_override("font", font)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.08, 0.16, 0.12))
	HandLevel.reset()
	## 始终将 zpix 设为全局默认字体（支持中英文）
	var loc = Loc.i()
	if loc.cn_font:
		var theme = Theme.new()
		theme.set_default_font(loc.cn_font)
		get_tree().root.theme = theme

	deck = Node.new()
	deck.set_script(load("res://scripts/deck.gd"))
	deck.name = "Deck"
	add_child(deck)

	hand = Node2D.new()
	hand.set_script(load("res://scripts/hand.gd"))
	hand.name = "Hand"
	hand.position = Vector2(CENTER_X, 0)
	add_child(hand)
	hand.draw_pile_source = DRAW_PILE_POS
	hand.hand_changed.connect(_on_hand_changed)

	score_display = Node2D.new()
	score_display.set_script(load("res://scripts/score_display.gd"))
	score_display.name = "ScoreDisplay"
	add_child(score_display)

	hand_preview = Node2D.new()
	hand_preview.set_script(load("res://scripts/hand_preview.gd"))
	hand_preview.name = "HandPreview"
	hand_preview.position = Vector2(CENTER_X, PREVIEW_Y)
	add_child(hand_preview)

	joker_slot = Node2D.new()
	joker_slot.set_script(load("res://scripts/joker_slot.gd"))
	joker_slot.name = "JokerSlot"
	joker_slot.position = Vector2(CENTER_X, JOKER_Y)
	add_child(joker_slot)
	joker_slot.joker_hovered.connect(_on_joker_hovered)
	joker_slot.joker_unhovered.connect(_on_joker_unhovered)

	draw_pile = Node2D.new()
	draw_pile.set_script(load("res://scripts/card_pile.gd"))
	draw_pile.name = "DrawPile"
	draw_pile.position = DRAW_PILE_POS
	draw_pile.set("pile_type", 0)
	add_child(draw_pile)

	discard_pile = Node2D.new()
	discard_pile.set_script(load("res://scripts/card_pile.gd"))
	discard_pile.name = "DiscardPile"
	discard_pile.position = DISCARD_PILE_POS
	discard_pile.set("pile_type", 1)
	add_child(discard_pile)

	consumable_slot = Node2D.new()
	consumable_slot.set_script(load("res://scripts/consumable_slot.gd"))
	consumable_slot.name = "ConsumableSlot"
	consumable_slot.position = Vector2(DESIGN_WIDTH - 130, 200)
	add_child(consumable_slot)
	consumable_slot.planet_used.connect(_on_planet_used)
	consumable_slot.tarot_used.connect(_on_tarot_used)
	consumable_slot.consumable_hovered.connect(_on_consumable_hovered)
	consumable_slot.consumable_unhovered.connect(_on_consumable_unhovered)
	consumable_slot.hand_ref = hand

	shop = Node2D.new()
	shop.set_script(load("res://scripts/shop.gd"))
	shop.name = "Shop"
	shop.z_index = 50
	add_child(shop)
	shop.shop_closed.connect(_on_shop_closed)

	blind_select = Node2D.new()
	blind_select.set_script(load("res://scripts/blind_select.gd"))
	blind_select.name = "BlindSelect"
	blind_select.z_index = 50
	add_child(blind_select)
	blind_select.blind_selected.connect(_on_blind_selected)
	blind_select.blind_skipped.connect(_on_blind_skipped)

	round_result = Node2D.new()
	round_result.set_script(load("res://scripts/round_result.gd"))
	round_result.name = "RoundResult"
	round_result.z_index = 50
	add_child(round_result)
	round_result.go_to_shop.connect(_on_go_to_shop)
	round_result.restart_game.connect(_on_restart_from_result)

	var victory_celebration = Node2D.new()
	victory_celebration.set_script(load("res://scripts/victory_celebration.gd"))
	victory_celebration.name = "VictoryCelebration"
	add_child(victory_celebration)
	victory_celebration.celebration_done.connect(_on_celebration_done)

	_setup_ui()

	## 暂停菜单
	var pause_menu = Node2D.new()
	pause_menu.set_script(load("res://scripts/pause_menu.gd"))
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.joker_slot_ref = joker_slot
	pause_menu.new_game.connect(_on_new_game_from_menu)

	## 开场菜单
	var title_screen = Node2D.new()
	title_screen.set_script(load("res://scripts/title_screen.gd"))
	title_screen.name = "TitleScreen"
	add_child(title_screen)
	title_screen.open_title_menu.connect(_on_title_open_menu)
	title_screen.start_game.connect(_on_title_start_game)

	## 漩涡过渡效果
	vortex = Node2D.new()
	vortex.set_script(load("res://scripts/vortex_transition.gd"))
	vortex.name = "VortexTransition"
	add_child(vortex)
	vortex.transition_midpoint.connect(_on_vortex_midpoint)
	vortex.transition_complete.connect(_on_vortex_complete)

## 标题界面点击 Start Game → 打开标题菜单
func _on_title_open_menu() -> void:
	var pm = get_node_or_null("PauseMenu")
	if pm:
		pm.open_as_title()

## 标题菜单点击 New Game → 漩涡过渡 → 开始游戏
func _on_new_game_from_menu() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.visible = false
	var pm = get_node_or_null("PauseMenu")
	if pm:
		pm.visible = false
	vortex.start_transition()

func _on_vortex_midpoint() -> void:
	## 黑屏时刻 - 清理标题界面，重置游戏
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.queue_free()
	_restart_game()

func _on_vortex_complete() -> void:
	## 过渡完成 - 打开盲注选择
	_open_blind_select()

## 旧过渡动画完成时的备用回调（title_screen.start_game信号）
func _on_title_start_game() -> void:
	var ts = get_node_or_null("TitleScreen")
	if ts:
		ts.queue_free()
	_open_blind_select()

func _open_blind_select() -> void:
	if ante_boss == null:
		ante_boss = BlindData.get_random_boss(used_boss_names)
		used_boss_names.append(ante_boss.name)
	blind_select.open_select(current_ante, blind_index, ante_boss)

func _process(delta: float) -> void:
	## 遮罩时禁止手牌和消耗品交互
	var overlay_open = (shop.visible or blind_select.visible or round_result.visible)
	hand.set_process(!overlay_open)
	consumable_slot.set_process_input(!overlay_open)
	for card in hand.cards_in_hand:
		if is_instance_valid(card):
			for child in card.get_children():
				if child is Area2D:
					child.input_pickable = !overlay_open

	if is_score_animating:
		score_anim_timer += delta
		if score_anim_timer > 1.0:
			_start_exit_animation()

## ========== 调试作弊码 ==========
## F1 = 加 $100
## F2 = 跳到最终Boss (Ante 8 Boss)
## F3 = 直接触发胜利动画
## F4 = 当前回合自动达标
## F5 = 获得随机小丑牌
func _unhandled_input(event: InputEvent) -> void:
	## 通关后点击返回标题
	if game_won and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		game_won = false
		_return_to_title()
		return
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_F1:
			money += 100
			_update_ui()
			info_label.text = "🔧 DEBUG: +$100"
			info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
		KEY_F2:
			## 跳到 Ante 8 Boss
			current_ante = MAX_ANTE
			blind_index = 2
			ante_boss = BlindData.get_random_boss(used_boss_names)
			## 关闭所有遮罩
			shop.visible = false
			blind_select.visible = false
			round_result.visible = false
			round_ended = false
			is_discarding = false
			## 通过正确函数开始回合
			_on_blind_selected(BlindData.BlindType.BOSS_BLIND, ante_boss)
			info_label.text = "🔧 DEBUG: Jumped to Ante 8 Boss!"
			info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
		KEY_F3:
			## 直接触发胜利庆祝
			shop.visible = false
			blind_select.visible = false
			round_result.visible = false
			_show_game_victory()
		KEY_F4:
			## 当前回合自动达标
			if not round_ended:
				var target = score_display.target_score
				score_display.round_score = target + 100
				score_display.target_round_score = float(target + 100)
				score_display.display_round_score = float(target + 100)
				info_label.text = "🔧 DEBUG: Score set to target!"
				info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
				_trigger_victory()
		KEY_F5:
			## 获得随机小丑牌
			if joker_slot.get_owned_jokers().size() < 5:
				var owned_ids: Array = []
				for j in joker_slot.get_owned_jokers():
					owned_ids.append(j.id)
				var new_jokers = JokerDatabase.get_random_jokers(1, owned_ids)
				if new_jokers.size() > 0:
					joker_slot.add_joker(new_jokers[0])
					info_label.text = "🔧 DEBUG: Added " + new_jokers[0].joker_name
					info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))

func _setup_ui() -> void:
	var title_label = Label.new()
	title_label.text = "BALATRO PROTOTYPE"
	title_label.position = Vector2(0, 15)
	title_label.custom_minimum_size = Vector2(DESIGN_WIDTH, 0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_f(title_label)
	add_child(title_label)

	info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.position = Vector2(0, 50)
	info_label.custom_minimum_size = Vector2(DESIGN_WIDTH, 0)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 20)
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	_f(info_label)
	add_child(info_label)

	money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.position = Vector2(DESIGN_WIDTH - 220, 340)
	money_label.add_theme_font_size_override("font_size", 26)
	money_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	add_child(money_label)

	ante_label = Label.new()
	ante_label.name = "AnteLabel"
	ante_label.position = Vector2(DESIGN_WIDTH - 220, 375)
	ante_label.add_theme_font_size_override("font_size", 16)
	ante_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(ante_label)
	add_child(ante_label)

	blind_label = Label.new()
	blind_label.name = "BlindLabel"
	blind_label.position = Vector2(DESIGN_WIDTH - 220, 397)
	blind_label.add_theme_font_size_override("font_size", 16)
	blind_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(blind_label)
	add_child(blind_label)

	boss_effect_label = Label.new()
	boss_effect_label.name = "BossEffect"
	boss_effect_label.position = Vector2(0, PREVIEW_Y + 60)
	boss_effect_label.custom_minimum_size = Vector2(DESIGN_WIDTH, 0)
	boss_effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_effect_label.add_theme_font_size_override("font_size", 18)
	boss_effect_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	_f(boss_effect_label)
	add_child(boss_effect_label)

	joker_info_label = Label.new()
	joker_info_label.name = "JokerInfo"
	joker_info_label.position = Vector2(0, JOKER_INFO_Y)
	joker_info_label.custom_minimum_size = Vector2(DESIGN_WIDTH, 0)
	joker_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	joker_info_label.add_theme_font_size_override("font_size", 16)
	joker_info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
	_f(joker_info_label)
	add_child(joker_info_label)

	sort_suit_button = Button.new()
	sort_suit_button.text = " ♠♥♣♦ / A→2 "
	sort_suit_button.position = Vector2(CENTER_X - 100, BUTTON_Y + 45)
	sort_suit_button.custom_minimum_size = Vector2(200, 0)
	sort_suit_button.add_theme_font_size_override("font_size", 16)
	sort_suit_button.pressed.connect(_on_sort_toggle)
	_fb(sort_suit_button)
	add_child(sort_suit_button)

	hands_label = Label.new()
	hands_label.name = "HandsLabel"
	hands_label.position = Vector2(CENTER_X - 280, BUTTON_Y - 28)
	hands_label.custom_minimum_size = Vector2(200, 0)
	hands_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hands_label.add_theme_font_size_override("font_size", 18)
	hands_label.add_theme_color_override("font_color", Color(0.3, 0.6, 0.9))
	_f(hands_label)
	add_child(hands_label)

	play_button = Button.new()
	play_button.text = "   " + Loc.i().t("Play Hand") + "   "
	play_button.position = Vector2(CENTER_X - 280, BUTTON_Y)
	play_button.custom_minimum_size = Vector2(200, 0)
	play_button.add_theme_font_size_override("font_size", 22)
	play_button.pressed.connect(_on_play_pressed)
	_fb(play_button)
	add_child(play_button)

	discards_label = Label.new()
	discards_label.name = "DiscardsLabel"
	discards_label.position = Vector2(CENTER_X + 80, BUTTON_Y - 28)
	discards_label.custom_minimum_size = Vector2(200, 0)
	discards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	discards_label.add_theme_font_size_override("font_size", 18)
	discards_label.add_theme_color_override("font_color", Color(0.9, 0.35, 0.3))
	_f(discards_label)
	add_child(discards_label)

	discard_button = Button.new()
	discard_button.text = "   " + Loc.i().t("Discard") + "   "
	discard_button.position = Vector2(CENTER_X + 80, BUTTON_Y)
	discard_button.custom_minimum_size = Vector2(200, 0)
	discard_button.add_theme_font_size_override("font_size", 22)
	discard_button.pressed.connect(_on_discard_pressed)
	_fb(discard_button)
	add_child(discard_button)

	var draw_label = Label.new()
	draw_label.text = Loc.i().t("DRAW")
	draw_label.position = Vector2(DRAW_PILE_POS.x - 45, PILE_Y - 100)
	draw_label.custom_minimum_size = Vector2(90, 0)
	draw_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draw_label.add_theme_font_size_override("font_size", 16)
	draw_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(draw_label)
	add_child(draw_label)

	var discard_label_text = Label.new()
	discard_label_text.text = Loc.i().t("DISCARD")
	discard_label_text.position = Vector2(DISCARD_PILE_POS.x - 45, PILE_Y - 100)
	discard_label_text.custom_minimum_size = Vector2(90, 0)
	discard_label_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	discard_label_text.add_theme_font_size_override("font_size", 16)
	discard_label_text.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(discard_label_text)
	add_child(discard_label_text)

	_update_ui()

## ========== 盲注选择 ==========

func _on_blind_selected(blind_type: int, boss) -> void:
	current_blind_type = blind_type as BlindData.BlindType
	current_boss = boss
	hands_played_this_round = 0
	round_ended = false

	var target = BlindData.get_blind_target(current_ante, current_blind_type)
	score_display.set_target(target)
	score_display.reset_round()

	hands_remaining = 4
	discards_remaining = 3
	boss_effect_label.text = ""

	if current_boss != null:
		match current_boss.effect:
			BlindData.BossEffect.FEWER_HANDS:
				hands_remaining = 3
			BlindData.BossEffect.NO_DISCARDS:
				discards_remaining = 0
		boss_effect_label.text = "⚠ " + Loc.i().t("BOSS") + ": " + Loc.i().t(current_boss.name) + " - " + Loc.i().t(current_boss.description)

	total_discarded = 0
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
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	_update_ui()

## 跳过当前盲注（不获得奖励，直接推进）
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
				info_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.3))
		"planet":
			var planets = PlanetDatabase.get_random_planets(1)
			if planets.size() > 0 and not consumable_slot.is_full():
				consumable_slot.add_planet(planets[0])
				info_label.text = "🪐 " + Loc.i().t("Skip reward") + ": " + Loc.i().t(planets[0].planet_name) + "!"
				info_label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.95))
			elif planets.size() > 0:
				info_label.text = "🪐 " + Loc.i().t("Consumable slots full — reward lost!")
				info_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.3))
		"money":
			money += 3
			info_label.text = "💰 " + Loc.i().t("Skip reward") + ": +$3!"
			info_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
		"level_up":
			var types = PokerHand.HandType.values()
			var random_type = types[randi() % types.size()]
			HandLevel.planet_level_up(random_type, 15, 1)
			var hname = PokerHand.get_hand_name(random_type)
			var lvl = HandLevel.get_level_info(random_type)["level"]
			info_label.text = "⬆️ " + Loc.i().t("Skip reward") + ": " + Loc.i().t(hname) + " → Lv." + str(lvl) + "!"
			info_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))

## 推进盲注进度
func _advance_blind() -> void:
	blind_index += 1
	if blind_index >= 3:
		## 完成本Ante所有盲注，进入下一个Ante
		blind_index = 0
		current_ante += 1
		ante_boss = null  ## 新 Ante 重新随机 Boss
		if current_ante > MAX_ANTE:
			_show_game_victory()
			return
	_open_blind_select()

func _draw_initial_hand() -> void:
	var drawn = deck.draw_cards(INITIAL_HAND_SIZE)
	for card_data in drawn:
		hand.add_card(card_data, true)
	## 不立即排序，等入场动画完成后自动整理
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
	if current_boss == null:
		return
	match current_boss.effect:
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
			if hands_played_this_round == 0:
				result["total_chips"] = int(result["total_chips"] / 2)
				result["final_score"] = result["total_chips"] * result["total_mult"]

func _debuff_suit(result: Dictionary, suit: int) -> void:
	var new_chips = result["base_chips"] + result.get("level_bonus_chips", 0)
	for card in result["scoring_cards"]:
		if card.card_data.suit != suit:
			new_chips += card.card_data.get_chip_value()
	result["total_chips"] = new_chips
	result["final_score"] = new_chips * result["total_mult"]

## ========== 游戏操作 ==========

func _on_joker_hovered(joker_data: JokerData) -> void:
	joker_info_label.text = Loc.i().t(joker_data.joker_name) + ": " + Loc.i().t(joker_data.description)

func _on_joker_unhovered() -> void:
	joker_info_label.text = ""

func _on_consumable_hovered(text: String) -> void:
	joker_info_label.text = text

func _on_consumable_unhovered() -> void:
	joker_info_label.text = ""

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
				info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

		TarotData.TarotEffect.GAIN_MONEY:
			money += 5
			info_label.text = "🔮 " + Loc.i().t("The Hermit") + " +$5!"
			info_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
			_update_ui()

		TarotData.TarotEffect.CLONE_CARD:
			if selected.size() >= 2:
				## 手牌中靠左的变成靠右的副本
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
				info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
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
				info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
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
			info_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
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

func _on_sort_toggle() -> void:
	if is_score_animating or round_ended or is_discarding: return
	hand.toggle_sort()

func _on_play_pressed() -> void:
	if hands_remaining <= 0 or is_score_animating or round_ended or is_discarding:
		return
	var selected = hand.get_selected_cards()
	if selected.is_empty():
		info_label.text = Loc.i().t("Select cards first")
		return
	if selected.size() > MAX_SELECT:
		info_label.text = "Max " + str(MAX_SELECT) + " cards!"
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

	is_score_animating = true
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
		info_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	else:
		info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))

	info_label.text = info_text
	hand_preview.hide_preview()
	play_button.disabled = true
	discard_button.disabled = true
	hands_remaining -= 1
	hands_played_this_round += 1

## ========== 弃牌（带动画）==========

func _on_discard_pressed() -> void:
	if discards_remaining <= 0 or is_score_animating or exit_cards_remaining > 0 or round_ended or is_discarding:
		return
	var selected = hand.get_selected_cards()
	if selected.is_empty():
		info_label.text = Loc.i().t("Select cards first")
		return

	discards_remaining -= 1
	play_button.disabled = true
	discard_button.disabled = true
	is_discarding = true

	## 用新方法：移除但不 free
	var removed = hand.remove_selected_cards_for_animation()
	total_discarded += removed.size()
	discard_exit_remaining = removed.size()

	## 启动每张卡牌的飞行动画
	var discard_local = DISCARD_PILE_POS - hand.global_position
	for i in range(removed.size()):
		var card = removed[i]
		card.card_exit_done.connect(_on_discard_exit_done)
		card.animate_exit(discard_local, i * 0.06)

	hand_preview.hide_preview()
	info_label.text = "Discarded " + str(removed.size()) + " cards"
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))

func _on_discard_exit_done(card_node: Node2D) -> void:
	card_node.queue_free()
	discard_exit_remaining -= 1
	discard_pile.set_count(total_discarded)

	if discard_exit_remaining <= 0:
		_finish_discard()

func _finish_discard() -> void:
	is_discarding = false

	var to_draw = INITIAL_HAND_SIZE - hand.cards_in_hand.size()
	var new_cards = deck.draw_cards(to_draw)
	for card_data in new_cards:
		hand.add_card(card_data, true)

	## 新牌入场后自动整理
	if new_cards.size() > 0:
		hand.request_auto_sort()

	play_button.disabled = false
	discard_button.disabled = false
	_update_ui()

## ========== 出牌后退场动画 ==========

func _start_exit_animation() -> void:
	is_score_animating = false
	var discard_local = DISCARD_PILE_POS - hand.global_position
	exit_cards_remaining = pending_play_cards.size()
	total_discarded += pending_play_cards.size()

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
	discard_pile.set_count(total_discarded)
	if exit_cards_remaining <= 0:
		_finish_after_exit()

func _finish_after_exit() -> void:
	pending_play_cards.clear()
	hand._arrange_cards()

	if not round_ended and score_display.round_score >= score_display.target_score:
		_trigger_victory()
		return

	var to_draw = INITIAL_HAND_SIZE - hand.cards_in_hand.size()
	var new_cards = deck.draw_cards(to_draw)
	for card_data in new_cards:
		hand.add_card(card_data, true)

	## 新牌入场后自动整理
	if new_cards.size() > 0:
		hand.request_auto_sort()

	play_button.disabled = false
	discard_button.disabled = false

	if hands_remaining <= 0 and not round_ended:
		_trigger_defeat()
	else:
		_update_ui()

## ========== 回合结束 ==========

func _trigger_victory() -> void:
	round_ended = true
	play_button.disabled = true
	discard_button.disabled = true
	var reward = BlindData.get_blind_reward(current_blind_type)
	var income = _calculate_income(true) + reward
	money += income
	var blind_name = _get_current_blind_name()
	_update_ui()
	await get_tree().create_timer(0.8).timeout
	round_result.show_victory(score_display.round_score, score_display.target_score, income, blind_name)

func _trigger_defeat() -> void:
	round_ended = true
	play_button.disabled = true
	discard_button.disabled = true
	var blind_name = _get_current_blind_name()
	await get_tree().create_timer(0.8).timeout
	round_result.show_defeat(score_display.round_score, score_display.target_score, blind_name)

func _get_current_blind_name() -> String:
	if current_boss and current_blind_type == BlindData.BlindType.BOSS_BLIND:
		return current_boss.name
	return BlindData.get_blind_name(current_blind_type)

func _calculate_income(won: bool) -> int:
	var income = BASE_INCOME
	var interest = mini(int(money / 5), INTEREST_CAP)
	income += interest
	if won:
		income += WIN_BONUS
	return income

## 胜利 → 商店
func _on_go_to_shop() -> void:
	var owned_ids: Array = []
	for j in joker_slot.get_owned_jokers():
		owned_ids.append(j.id)
	shop.open_shop(money, owned_ids, joker_slot, consumable_slot)

func _on_restart_from_result() -> void:
	vortex.start_transition()

## 商店关闭 → 推进盲注
func _on_shop_closed() -> void:
	money = shop.get_money()
	boss_effect_label.text = ""
	_advance_blind()

func _show_game_victory() -> void:
	info_label.text = ""
	var vc = get_node("VictoryCelebration")
	if vc:
		vc.start_celebration()

func _on_celebration_done() -> void:
	info_label.text = "🏆 " + Loc.i().t("CONGRATULATIONS!") + " 🏆\n" + Loc.i().t("Click to return to title")
	info_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.3))
	## 等待玩家点击
	game_won = true

var game_won: bool = false

func _return_to_title() -> void:
	## 重置游戏状态
	_restart_game_state()
	## 停止庆祝动画
	var vc = get_node_or_null("VictoryCelebration")
	if vc:
		vc.stop_celebration()
	## 隐藏所有游戏 UI
	info_label.text = ""
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	## 重新创建标题界面
	var title_screen = Node2D.new()
	title_screen.set_script(load("res://scripts/title_screen.gd"))
	title_screen.name = "TitleScreen"
	add_child(title_screen)
	title_screen.open_title_menu.connect(_on_title_open_menu)
	title_screen.start_game.connect(_on_title_start_game)

## 只重置游戏数据，不打开盲注选择
func _restart_game_state() -> void:
	money = STARTING_MONEY
	current_ante = 1
	blind_index = 0
	current_boss = null
	ante_boss = null
	used_boss_names.clear()
	round_ended = false
	is_discarding = false
	HandLevel.reset()
	while joker_slot.get_owned_jokers().size() > 0:
		joker_slot.remove_joker(0)
	consumable_slot.clear_all()
	hands_remaining = 4
	discards_remaining = 3
	total_discarded = 0
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

func _restart_game() -> void:
	_restart_game_state()
	info_label.text = ""
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	_open_blind_select()

func _update_ui() -> void:
	if hands_label:
		hands_label.text = Loc.i().t("Hands") + ": " + str(hands_remaining)
	if discards_label:
		discards_label.text = Loc.i().t("Discard") + ": " + str(discards_remaining)
	if draw_pile:
		draw_pile.set_count(deck.remaining())
	if discard_pile:
		discard_pile.set_count(total_discarded)
	if money_label:
		money_label.text = "$ " + str(money)
	if ante_label:
		ante_label.text = Loc.i().t("Ante") + " " + str(current_ante) + " / " + str(MAX_ANTE)
	if blind_label:
		blind_label.text = Loc.i().t(_get_current_blind_name())
