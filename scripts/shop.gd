## shop.gd
## 商店系统 V0.085 - 天书(Tome) 系统 + 折扣支持 (4K)
extends Node2D

signal shop_closed()

const SHOP_WIDTH: float = 3840.0
const SHOP_HEIGHT: float = 2160.0
const CENTER_X: float = SHOP_WIDTH / 2.0

const CARD_W: float = 280.0
const CARD_H: float = 380.0
const JOKER_AREA_Y: float = 740.0
const PLANET_AREA_Y: float = 740.0

const OWNED_Y: float = 1640.0
const OWNED_CARD_W: float = 220.0
const OWNED_CARD_H: float = 290.0
const OWNED_SPACING: float = 260.0

const BASE_REROLL_COST: int = 5

var shop_jokers: Array[JokerData] = []
var shop_consumables: Array = []
var shop_voucher: VoucherData = null  ## 每个 Ante 一张
var owned_joker_ids: Array = []
var owned_voucher_ids: Array = []
var money: int = 0
var joker_slot_ref = null
var consumable_slot_ref = null

var money_label: Label
var shop_info_label: Label

var is_animating: bool = false
var anim_particles: Array = []
var anim_layer: Node2D = null

## Reroll 递增计数器（每次刷新 +$1）
var reroll_count: int = 0

## 金钱滚动动画
var money_anim_active: bool = false
var money_anim_from: int = 0
var money_anim_to: int = 0

## ===== 字体辅助 =====
func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font: lbl.add_theme_font_override("font", font)

func _fb(btn: Button) -> void:
	var font = Loc.i().cn_font
	if font: btn.add_theme_font_override("font", font)

func _fr(rtl: RichTextLabel) -> void:
	var font = Loc.i().cn_font
	if font: rtl.add_theme_font_override("normal_font", font)
var money_anim_timer: float = 0.0
const MONEY_ANIM_DURATION: float = 0.5

func _ready() -> void:
	visible = false

## ========== Voucher 折扣计算 ==========

func _get_reroll_cost() -> int:
	var cost = BASE_REROLL_COST + reroll_count
	for vid in owned_voucher_ids:
		var v = VoucherDatabase.get_voucher_by_id(vid)
		if v and v.effect == VoucherData.VoucherEffect.REROLL_DISCOUNT:
			cost -= int(v.value)
	return maxi(cost, 0)

func _get_shop_discount() -> float:
	## 返回折扣比例，如 0.9 表示打9折
	var discount = 1.0
	for vid in owned_voucher_ids:
		var v = VoucherDatabase.get_voucher_by_id(vid)
		if v and v.effect == VoucherData.VoucherEffect.SHOP_DISCOUNT:
			discount -= v.value
	return maxf(discount, 0.5)

func _discounted_price(base_price: int) -> int:
	return maxi(1, int(base_price * _get_shop_discount()))

func get_owned_voucher_ids() -> Array:
	return owned_voucher_ids

func open_shop(current_money: int, current_joker_ids: Array, joker_slot, consumable_slot = null, voucher_ids: Array = []) -> void:
	money = current_money
	owned_joker_ids = current_joker_ids
	owned_voucher_ids = voucher_ids.duplicate()
	joker_slot_ref = joker_slot
	consumable_slot_ref = consumable_slot
	visible = true
	is_animating = false
	money_anim_active = false
	reroll_count = 0  ## 每次进商店重置刷新递增
	anim_particles.clear()
	_generate_shop_items()
	_build_ui()

func _generate_shop_items() -> void:
	shop_jokers = JokerDatabase.get_random_jokers(2, owned_joker_ids)
	shop_consumables.clear()
	for i in range(2):
		if randf() < 0.5:
			var planets = PlanetDatabase.get_random_planets(1)
			if planets.size() > 0:
				shop_consumables.append({"type": "planet", "data": planets[0]})
		else:
			var tarots = TarotDatabase.get_random_tarots(1)
			if tarots.size() > 0:
				shop_consumables.append({"type": "tarot", "data": tarots[0]})
	## 生成一张未拥有的 Voucher
	shop_voucher = VoucherDatabase.get_random_voucher(owned_voucher_ids)

func _process(delta: float) -> void:
	if not visible:
		return
	## 粒子
	if anim_particles.size() > 0:
		var to_remove: Array = []
		for i in range(anim_particles.size()):
			var p = anim_particles[i]
			p["life"] -= delta
			p["pos"] += p["vel"] * delta
			p["vel"].y += 200.0 * delta
			if p["life"] <= 0:
				to_remove.append(i)
		to_remove.reverse()
		for idx in to_remove:
			anim_particles.remove_at(idx)
		if anim_layer:
			anim_layer.queue_redraw()
	## 金钱滚动动画
	if money_anim_active:
		money_anim_timer += delta
		var t = clampf(money_anim_timer / MONEY_ANIM_DURATION, 0.0, 1.0)
		## ease out quad
		t = 1.0 - (1.0 - t) * (1.0 - t)
		var display_val = int(lerpf(money_anim_from, money_anim_to, t))
		if money_label:
			money_label.text = "$ " + str(display_val)
		if t >= 1.0:
			money_anim_active = false
			if money_label:
				money_label.text = "$ " + str(money)

func _start_money_anim(old_money: int, new_money: int) -> void:
	money_anim_from = old_money
	money_anim_to = new_money
	money_anim_timer = 0.0
	money_anim_active = true

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()
	anim_layer = null

	var bg = ColorRect.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(SHOP_WIDTH, SHOP_HEIGHT)
	bg.color = Color(0.03, 0.06, 0.04, 0.97)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	## 霓虹灯 SHOP 招牌
	var neon_sign = Node2D.new()
	neon_sign.set_script(load("res://scripts/neon_shop_sign.gd"))
	neon_sign.position = Vector2(CENTER_X, 60)
	add_child(neon_sign)

	money_label = Label.new()
	money_label.position = Vector2(0, 180)
	money_label.custom_minimum_size = Vector2(SHOP_WIDTH, 0)
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", 64)
	money_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	_f(money_label)
	add_child(money_label)
	money_label.text = "$ " + str(money)

	shop_info_label = Label.new()
	shop_info_label.position = Vector2(0, 270)
	shop_info_label.custom_minimum_size = Vector2(SHOP_WIDTH, 0)
	shop_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_info_label.add_theme_font_size_override("font_size", 32)
	shop_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	_f(shop_info_label)
	add_child(shop_info_label)

	var card_layer = Node2D.new()
	card_layer.name = "CardLayer"
	add_child(card_layer)

	## 区域标签
	var joker_title = Label.new()
	joker_title.text = Loc.i().t("BEASTS")
	joker_title.position = Vector2(CENTER_X / 2.0 - 300, 420)
	joker_title.custom_minimum_size = Vector2(600, 0)
	joker_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	joker_title.add_theme_font_size_override("font_size", 28)
	joker_title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	_f(joker_title)
	add_child(joker_title)

	var cons_title = Label.new()
	cons_title.text = Loc.i().t("CONSUMABLES")
	cons_title.position = Vector2(CENTER_X + CENTER_X / 2.0 - 300, 420)
	cons_title.custom_minimum_size = Vector2(600, 0)
	cons_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cons_title.add_theme_font_size_override("font_size", 28)
	cons_title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	_f(cons_title)
	add_child(cons_title)

	_build_shop_jokers(card_layer)
	_build_shop_consumables(card_layer)
	_build_shop_voucher(card_layer)
	_build_owned_jokers(card_layer)
	_build_held_consumables(card_layer)

	## 按钮（对齐 SHOP 霓虹灯边框左右边缘）
	## 霓虹灯约 360px 宽，居中在 CENTER_X (4K)
	var btn_y = 1120.0
	var neon_left_edge = CENTER_X - 180  ## SHOP 霓虹灯左边缘
	var neon_right_edge = CENTER_X + 180  ## SHOP 霓虹灯右边缘
	var reroll_cost = _get_reroll_cost()
	var reroll_button = Button.new()
	reroll_button.text = "   " + Loc.i().t("Reroll") + " ($" + str(reroll_cost) + ")   "
	reroll_button.position = Vector2(neon_left_edge - 440, btn_y)
	reroll_button.add_theme_font_size_override("font_size", 40)
	reroll_button.pressed.connect(_on_reroll)
	reroll_button.disabled = money < reroll_cost
	_fb(reroll_button)
	add_child(reroll_button)

	var skip_button = Button.new()
	skip_button.text = "   " + Loc.i().t("Next Round") + " →   "
	skip_button.position = Vector2(neon_right_edge + 20, btn_y)
	skip_button.add_theme_font_size_override("font_size", 40)
	skip_button.pressed.connect(_on_skip)
	_fb(skip_button)
	add_child(skip_button)

	## 粒子层
	anim_layer = Node2D.new()
	anim_layer.name = "AnimLayer"
	anim_layer.z_index = 20
	anim_layer.set_script(load("res://scripts/shop_particle_draw.gd"))
	anim_layer.set("shop_ref", self)
	add_child(anim_layer)

## ========== 小丑牌商品 ==========

func _build_shop_jokers(parent: Node2D) -> void:
	var count = shop_jokers.size()
	if count == 0: return
	var spacing = 340.0
	var total_w = (count - 1) * spacing
	var base_x = CENTER_X / 2.0 - total_w / 2.0
	for i in range(count):
		var joker = shop_jokers[i]
		var x = base_x + i * spacing
		var price = _discounted_price(joker.cost)
		_build_card(parent, x, JOKER_AREA_Y, joker.emoji, joker.joker_name, joker.description,
			joker.get_rarity_color(), price, CARD_W, CARD_H)
		_add_buy_area(x, JOKER_AREA_Y, CARD_W, CARD_H, "joker", i)

## ========== 消耗品商品 ==========

func _build_shop_consumables(parent: Node2D) -> void:
	var count = shop_consumables.size()
	if count == 0: return
	var spacing = 340.0
	var total_w = (count - 1) * spacing
	var base_x = CENTER_X + CENTER_X / 2.0 - total_w / 2.0
	for i in range(count):
		var item = shop_consumables[i]
		var x = base_x + i * spacing
		var emoji: String; var card_name: String; var desc: String
		var border_color: Color; var cost: int
		if item["type"] == "planet":
			var p: PlanetData = item["data"]
			emoji = p.emoji; card_name = p.planet_name
			desc = "Lv↑ " + Loc.i().t(PokerHand.get_hand_name(p.hand_type))
			border_color = p.get_rarity_color(); cost = _discounted_price(p.cost)
		else:
			var t: TarotData = item["data"]
			emoji = t.emoji; card_name = t.tarot_name
			desc = t.description
			border_color = t.get_rarity_color(); cost = _discounted_price(t.cost)
		_build_card(parent, x, PLANET_AREA_Y, emoji, card_name, desc, border_color, cost, CARD_W, CARD_H)
		_add_buy_area(x, PLANET_AREA_Y, CARD_W, CARD_H, "consumable", i)

## ========== Voucher 商品 ==========

func _build_shop_voucher(parent: Node2D) -> void:
	if shop_voucher == null: return
	## Voucher 显示在小丑牌和消耗品之间，与卡池同一行
	var voucher_x = CENTER_X
	var voucher_y = JOKER_AREA_Y  ## 与小丑牌/消耗品同一水平线
	var voucher_title = Label.new()
	voucher_title.text = "🎟️ " + Loc.i().t("TOME")
	voucher_title.position = Vector2(voucher_x - 150, 420)
	voucher_title.custom_minimum_size = Vector2(300, 0)
	voucher_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	voucher_title.add_theme_font_size_override("font_size", 28)
	voucher_title.add_theme_color_override("font_color", Color(0.95, 0.75, 0.2))
	_f(voucher_title)
	parent.add_child(voucher_title)
	var v = shop_voucher
	_build_card(parent, voucher_x, voucher_y, v.emoji, v.voucher_name, v.description,
		Color(0.95, 0.75, 0.2), v.cost, CARD_W, CARD_H)
	_add_buy_area(voucher_x, voucher_y, CARD_W, CARD_H, "voucher", 0)

## ========== 已持有小丑牌 ==========

func _build_owned_jokers(parent: Node2D) -> void:
	if joker_slot_ref == null: return
	var owned = joker_slot_ref.get_owned_jokers()
	var section_title = Label.new()
	section_title.text = Loc.i().t("YOUR BEASTS") + (" (" + Loc.i().t("Right click to sell") + ")" if owned.size() > 0 else "")
	section_title.position = Vector2(0, OWNED_Y - 200)
	section_title.custom_minimum_size = Vector2(CENTER_X, 0)
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_title.add_theme_font_size_override("font_size", 26)
	section_title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	_f(section_title)
	parent.add_child(section_title)
	if owned.is_empty(): return
	var count = owned.size()
	var total_w = (count - 1) * OWNED_SPACING
	var start_x = CENTER_X / 2.0 - total_w / 2.0
	for i in range(count):
		var joker = owned[i]
		var x = start_x + i * OWNED_SPACING
		_build_card(parent, x, OWNED_Y, joker.emoji, joker.joker_name, joker.description,
			joker.get_rarity_color(), -1, OWNED_CARD_W, OWNED_CARD_H)
		var sell_lbl = Label.new()
		sell_lbl.text = Loc.i().t("Right: Sell") + " $" + str(joker.get_sell_price())
		sell_lbl.position = Vector2(x - OWNED_CARD_W / 2, OWNED_Y + OWNED_CARD_H / 2 + 10)
		sell_lbl.custom_minimum_size = Vector2(OWNED_CARD_W, 0)
		sell_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sell_lbl.add_theme_font_size_override("font_size", 24)
		sell_lbl.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
		_f(sell_lbl)
		parent.add_child(sell_lbl)
		_add_sell_area(x, OWNED_Y, OWNED_CARD_W, OWNED_CARD_H, "joker", i)

## ========== 已持有消耗品 ==========

func _build_held_consumables(parent: Node2D) -> void:
	if consumable_slot_ref == null: return
	var held = consumable_slot_ref.get_held_items()
	var section_title = Label.new()
	var hint_text = ""
	if held.size() > 0:
		hint_text = "  (" + Loc.i().t("Left: Use") + " | " + Loc.i().t("Right: Sell") + ")"
	section_title.text = Loc.i().t("YOUR CONSUMABLES") + " (" + str(held.size()) + "/" + str(consumable_slot_ref.MAX_CONSUMABLES) + ")" + hint_text
	section_title.position = Vector2(CENTER_X, OWNED_Y - 200)
	section_title.custom_minimum_size = Vector2(CENTER_X, 0)
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_title.add_theme_font_size_override("font_size", 26)
	section_title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	_f(section_title)
	parent.add_child(section_title)

	if held.is_empty(): return
	var count = held.size()
	var total_w = (count - 1) * OWNED_SPACING
	var start_x = CENTER_X + CENTER_X / 2.0 - total_w / 2.0
	var sell_price = 2
	for i in range(count):
		var item = held[i]
		var x = start_x + i * OWNED_SPACING
		var emoji: String; var card_name: String; var desc: String; var border_color: Color
		if item["type"] == "planet":
			var p: PlanetData = item["data"]
			emoji = p.emoji; card_name = p.planet_name
			desc = "Lv↑ " + PokerHand.get_hand_name(p.hand_type); border_color = p.get_rarity_color()
		else:
			var t: TarotData = item["data"]
			emoji = t.emoji; card_name = t.tarot_name
			desc = t.description; border_color = t.get_rarity_color()
		_build_card(parent, x, OWNED_Y, emoji, card_name, desc, border_color, -1, OWNED_CARD_W, OWNED_CARD_H)

		## 使用/出售标签
		var action_lbl = Label.new()
		action_lbl.text = Loc.i().t("Use") + " | " + Loc.i().t("Sell") + " $" + str(sell_price)
		action_lbl.position = Vector2(x - OWNED_CARD_W / 2, OWNED_Y + OWNED_CARD_H / 2 + 10)
		action_lbl.custom_minimum_size = Vector2(OWNED_CARD_W, 0)
		action_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action_lbl.add_theme_font_size_override("font_size", 20)
		action_lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 0.9))
		_f(action_lbl)
		parent.add_child(action_lbl)

		## 点击区域
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(OWNED_CARD_W, OWNED_CARD_H)
		collision.shape = shape
		area.position = Vector2(x, OWNED_Y)
		area.z_index = 10
		area.add_child(collision)
		area.input_pickable = true
		var idx = i
		area.mouse_entered.connect(func(): _on_cons_hover(idx))
		area.mouse_exited.connect(func(): _on_unhover())
		area.input_event.connect(func(vp, ev, si): _on_cons_click(idx, ev))
		parent.add_child(area)

## ========== 通用卡牌绘制（RichTextLabel 确保换行）==========

func _build_card(parent: Node2D, x: float, y: float, emoji: String, card_name: String,
		desc: String, border_color: Color, cost: int, w: float, h: float) -> void:
	## 卡牌背景（裁剪容器）
	var clip = Control.new()
	clip.position = Vector2(x - w / 2, y - h / 2)
	clip.size = Vector2(w, h)
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(clip)

	var card_bg = ColorRect.new()
	card_bg.position = Vector2(0, 0)
	card_bg.size = Vector2(w, h)
	card_bg.color = Color(0.1, 0.13, 0.18)
	card_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(card_bg)

	## Emoji（上部居中）
	var emoji_size = 76 if w >= 280 else 56
	var emoji_lbl = Label.new()
	emoji_lbl.text = emoji
	emoji_lbl.position = Vector2(0, 0)
	emoji_lbl.size = Vector2(w, h * 0.48)
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emoji_lbl.add_theme_font_size_override("font_size", emoji_size)
	clip.add_child(emoji_lbl)

	## 名字
	var name_size = 22 if w >= 280 else 18
	var name_y = h * 0.50
	var name_rtl = RichTextLabel.new()
	name_rtl.bbcode_enabled = true
	name_rtl.text = "[center]" + Loc.i().t(card_name) + "[/center]"
	name_rtl.position = Vector2(8, name_y)
	name_rtl.size = Vector2(w - 16, 44)
	name_rtl.add_theme_font_size_override("normal_font_size", name_size)
	name_rtl.add_theme_color_override("default_color", Color(0.9, 0.9, 0.85))
	name_rtl.scroll_active = false
	name_rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fr(name_rtl)
	clip.add_child(name_rtl)

	## 描述（RichTextLabel 保证换行）
	var desc_size = 18 if w >= 280 else 14
	var desc_y = name_y + 40
	var desc_rtl = RichTextLabel.new()
	desc_rtl.bbcode_enabled = true
	desc_rtl.text = "[center]" + Loc.i().t(desc) + "[/center]"
	desc_rtl.position = Vector2(8, desc_y)
	desc_rtl.size = Vector2(w - 16, h - desc_y - 4)
	desc_rtl.add_theme_font_size_override("normal_font_size", desc_size)
	desc_rtl.add_theme_color_override("default_color", Color(0.65, 0.65, 0.6))
	desc_rtl.scroll_active = false
	desc_rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fr(desc_rtl)
	clip.add_child(desc_rtl)

	## 边框
	var bw = 6.0 if w >= 280 else 4.0
	for edge in [
		[Vector2(x - w/2, y - h/2), Vector2(w, bw)],
		[Vector2(x - w/2, y + h/2 - bw), Vector2(w, bw)],
		[Vector2(x - w/2, y - h/2), Vector2(bw, h)],
		[Vector2(x + w/2 - bw, y - h/2), Vector2(bw, h)],
	]:
		var border = ColorRect.new()
		border.position = edge[0]
		border.size = edge[1]
		border.color = border_color
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(border)

	## 价格（卡牌下方）
	if cost >= 0:
		var price_color = Color(0.95, 0.8, 0.2) if money >= cost else Color(0.6, 0.3, 0.3)
		var price_lbl = Label.new()
		price_lbl.text = "$" + str(cost)
		price_lbl.position = Vector2(x - w / 2, y + h / 2 + 10)
		price_lbl.custom_minimum_size = Vector2(w, 0)
		price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_lbl.add_theme_font_size_override("font_size", 40)
		price_lbl.add_theme_color_override("font_color", price_color)
		_f(price_lbl)
		parent.add_child(price_lbl)

## ========== 交互区域 ==========

func _add_buy_area(x: float, y: float, w: float, h: float, item_type: String, index: int) -> void:
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(w, h)
	collision.shape = shape
	area.position = Vector2(x, y)
	area.z_index = 10
	area.add_child(collision)
	area.input_pickable = true
	var t = item_type; var idx = index
	area.mouse_entered.connect(func(): _on_buy_hover(t, idx))
	area.mouse_exited.connect(func(): _on_unhover())
	area.input_event.connect(func(vp, ev, si): _on_buy_click(t, idx, ev))
	add_child(area)

func _add_sell_area(x: float, y: float, w: float, h: float, item_type: String, index: int) -> void:
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(w, h)
	collision.shape = shape
	area.position = Vector2(x, y)
	area.z_index = 10
	area.add_child(collision)
	area.input_pickable = true
	var t = item_type; var idx = index
	area.mouse_entered.connect(func(): _on_sell_hover(t, idx))
	area.mouse_exited.connect(func(): _on_unhover())
	area.input_event.connect(func(vp, ev, si): _on_sell_click(t, idx, ev))
	add_child(area)

## ========== 粒子 ==========

func _spawn_shatter_particles(cx: float, cy: float, color: Color, count: int = 20) -> void:
	for i in range(count):
		var angle = randf() * TAU
		var speed = randf_range(80.0, 300.0)
		anim_particles.append({
			"pos": Vector2(cx + randf_range(-20, 20), cy + randf_range(-20, 20)),
			"vel": Vector2(cos(angle) * speed, sin(angle) * speed - 100.0),
			"color": Color(color.r + randf_range(-0.1, 0.1), color.g + randf_range(-0.1, 0.1), color.b + randf_range(-0.1, 0.1)),
			"life": randf_range(0.4, 0.9), "max_life": 0.9,
			"size": randf_range(3.0, 8.0),
		})

func _spawn_glow_particles(cx: float, cy: float, color: Color, count: int = 15) -> void:
	for i in range(count):
		var angle = randf() * TAU
		var speed = randf_range(30.0, 120.0)
		anim_particles.append({
			"pos": Vector2(cx + randf_range(-10, 10), cy + randf_range(-10, 10)),
			"vel": Vector2(cos(angle) * speed, sin(angle) * speed - 50.0),
			"color": Color(color.r, color.g, color.b, 0.9),
			"life": randf_range(0.3, 0.7), "max_life": 0.7,
			"size": randf_range(4.0, 10.0),
		})

## ========== 交互回调 ==========

func _on_buy_hover(item_type: String, index: int) -> void:
	if is_animating: return
	var _t = Loc.i()
	if item_type == "joker" and index < shop_jokers.size():
		var j = shop_jokers[index]
		var price = _discounted_price(j.cost)
		shop_info_label.text = _t.t(j.joker_name) + " - " + _t.t(j.description) + "  |  $" + str(price) + "  [" + _t.t(j.get_rarity_name()) + "]"
	elif item_type == "consumable" and index < shop_consumables.size():
		var item = shop_consumables[index]
		if item["type"] == "planet":
			var p: PlanetData = item["data"]
			var hand_name = PokerHand.get_hand_name(p.hand_type)
			var info = HandLevel.get_level_info(p.hand_type)
			var price = _discounted_price(p.cost)
			shop_info_label.text = _t.t(p.planet_name) + " - " + _t.t("Upgrades " + hand_name) + " (Lv." + str(info["level"]) + "→" + str(info["level"]+1) + ")  |  $" + str(price)
		else:
			var t: TarotData = item["data"]
			var price = _discounted_price(t.cost)
			shop_info_label.text = _t.t(t.tarot_name) + " - " + _t.t(t.description) + "  |  $" + str(price) + "  [" + _t.t("Artifact Cards") + "]"
	elif item_type == "voucher" and shop_voucher != null:
		shop_info_label.text = "🎟️ " + _t.t(shop_voucher.voucher_name) + " - " + _t.t(shop_voucher.description) + "  |  $" + str(shop_voucher.cost) + "  [" + _t.t("Celestial Tome") + "]"
	shop_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))

func _on_sell_hover(item_type: String, index: int) -> void:
	if is_animating: return
	if item_type == "joker" and joker_slot_ref:
		var owned = joker_slot_ref.get_owned_jokers()
		if index < owned.size():
			var j = owned[index]
			shop_info_label.text = Loc.i().t("Sell") + " " + Loc.i().t(j.joker_name) + " $" + str(j.get_sell_price()) + "  |  " + Loc.i().t(j.description)
			shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))

func _on_unhover() -> void:
	if is_animating: return
	shop_info_label.text = ""

func _on_buy_click(item_type: String, index: int, event: InputEvent) -> void:
	if is_animating: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if item_type == "joker":
			_buy_joker(index)
		elif item_type == "consumable":
			_buy_consumable(index)
		elif item_type == "voucher":
			_buy_voucher()

func _on_sell_click(item_type: String, index: int, event: InputEvent) -> void:
	if is_animating: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if item_type == "joker":
			_sell_joker(index)

## ========== 购买/卖出 ==========

func _buy_joker(index: int) -> void:
	if index >= shop_jokers.size(): return
	var joker = shop_jokers[index]
	var price = _discounted_price(joker.cost)
	if money < price:
		shop_info_label.text = Loc.i().t("Not enough money!")
		shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return
	var max_jokers = joker_slot_ref.MAX_JOKERS if joker_slot_ref else 5
	if joker_slot_ref and joker_slot_ref.get_owned_jokers().size() >= max_jokers:
		shop_info_label.text = Loc.i().t("Beast slots full!")
		shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return

	var count = shop_jokers.size()
	var spacing = 340.0
	var total_w = (count - 1) * spacing
	var base_x = CENTER_X / 2.0 - total_w / 2.0
	var cx = base_x + index * spacing
	_spawn_shatter_particles(cx, JOKER_AREA_Y, Color(0.3, 0.9, 0.4), 15)

	var old_money = money
	money -= price
	_start_money_anim(old_money, money)

	if joker_slot_ref:
		joker_slot_ref.add_joker(joker)
	owned_joker_ids.append(joker.id)
	shop_jokers.remove_at(index)

	is_animating = true
	shop_info_label.text = Loc.i().t("Purchased") + " " + Loc.i().t(joker.joker_name) + "!"
	shop_info_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
	await get_tree().create_timer(0.4).timeout
	_build_ui()
	is_animating = false

func _buy_consumable(index: int) -> void:
	if index >= shop_consumables.size(): return
	var item = shop_consumables[index]
	var base_cost: int; var item_name: String
	if item["type"] == "planet":
		base_cost = (item["data"] as PlanetData).cost
		item_name = (item["data"] as PlanetData).planet_name
	else:
		base_cost = (item["data"] as TarotData).cost
		item_name = (item["data"] as TarotData).tarot_name
	var price = _discounted_price(base_cost)

	if money < price:
		shop_info_label.text = Loc.i().t("Not enough money!")
		shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return
	if consumable_slot_ref and consumable_slot_ref.is_full():
		shop_info_label.text = Loc.i().t("Consumable slots full!")
		shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return

	var count = shop_consumables.size()
	var spacing = 340.0
	var total_w = (count - 1) * spacing
	var base_x = CENTER_X + CENTER_X / 2.0 - total_w / 2.0
	var cx = base_x + index * spacing
	var pc = Color(0.2, 0.55, 0.85) if item["type"] == "planet" else Color(0.7, 0.35, 0.75)
	_spawn_glow_particles(cx, PLANET_AREA_Y, pc, 18)

	var old_money = money
	money -= price
	_start_money_anim(old_money, money)

	if consumable_slot_ref:
		if item["type"] == "planet":
			consumable_slot_ref.add_planet(item["data"])
		else:
			consumable_slot_ref.add_tarot(item["data"])
	shop_consumables.remove_at(index)

	is_animating = true
	shop_info_label.text = Loc.i().t("Purchased") + " " + Loc.i().t(item_name) + "!"
	var tc = Color(0.2, 0.6, 0.95) if item["type"] == "planet" else Color(0.7, 0.35, 0.75)
	shop_info_label.add_theme_color_override("font_color", tc)
	await get_tree().create_timer(0.4).timeout
	_build_ui()
	is_animating = false

func _buy_voucher() -> void:
	if shop_voucher == null: return
	if money < shop_voucher.cost:
		shop_info_label.text = Loc.i().t("Not enough money!")
		shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return

	_spawn_glow_particles(CENTER_X, JOKER_AREA_Y, Color(0.95, 0.75, 0.2), 25)

	var old_money = money
	money -= shop_voucher.cost
	_start_money_anim(old_money, money)

	owned_voucher_ids.append(shop_voucher.id)
	var vname = shop_voucher.voucher_name
	shop_voucher = null  ## 每个 Ante 只能买一张

	is_animating = true
	shop_info_label.text = "🎟️ " + Loc.i().t("Purchased") + " " + Loc.i().t(vname) + "!"
	shop_info_label.add_theme_color_override("font_color", Color(0.95, 0.75, 0.2))
	await get_tree().create_timer(0.4).timeout
	_build_ui()
	is_animating = false

func _sell_joker(index: int) -> void:
	if joker_slot_ref == null: return
	var owned = joker_slot_ref.get_owned_jokers()
	if index >= owned.size(): return
	var joker = owned[index]
	var sell_price = joker.get_sell_price()

	var count = owned.size()
	var total_w = (count - 1) * OWNED_SPACING
	var start_x = CENTER_X / 2.0 - total_w / 2.0
	var cx = start_x + index * OWNED_SPACING
	_spawn_shatter_particles(cx, OWNED_Y, Color(0.9, 0.5, 0.15), 25)
	_spawn_glow_particles(cx, OWNED_Y - 30, Color(0.95, 0.8, 0.2), 10)

	var old_money = money
	money += sell_price
	_start_money_anim(old_money, money)

	joker_slot_ref.remove_joker(index)
	var id_idx = owned_joker_ids.find(joker.id)
	if id_idx >= 0:
		owned_joker_ids.remove_at(id_idx)

	is_animating = true
	shop_info_label.text = Loc.i().t("Sold") + " " + Loc.i().t(joker.joker_name) + " $" + str(sell_price)
	shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
	await get_tree().create_timer(0.4).timeout
	_build_ui()
	is_animating = false

func _on_reroll() -> void:
	if is_animating: return
	var reroll_cost = _get_reroll_cost()
	if money < reroll_cost:
		shop_info_label.text = Loc.i().t("Not enough money to reroll!")
		shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		return
	var old_money = money
	money -= reroll_cost
	reroll_count += 1  ## 下次刷新费用 +$1
	_start_money_anim(old_money, money)
	## 只刷新小丑和消耗品，不刷新 Voucher（每Ante仅一张）
	shop_jokers = JokerDatabase.get_random_jokers(2, owned_joker_ids)
	shop_consumables.clear()
	for i in range(2):
		if randf() < 0.5:
			var planets = PlanetDatabase.get_random_planets(1)
			if planets.size() > 0:
				shop_consumables.append({"type": "planet", "data": planets[0]})
		else:
			var tarots = TarotDatabase.get_random_tarots(1)
			if tarots.size() > 0:
				shop_consumables.append({"type": "tarot", "data": tarots[0]})
	await get_tree().create_timer(0.3).timeout
	_build_ui()

func _on_skip() -> void:
	if is_animating: return
	visible = false
	anim_particles.clear()
	money_anim_active = false
	shop_closed.emit()

func get_money() -> int:
	return money

func _update_money_display() -> void:
	if money_label:
		money_label.text = "$ " + str(money)

## ========== 商店内消耗品 使用/出售 ==========

func _on_cons_hover(index: int) -> void:
	if is_animating: return
	if consumable_slot_ref == null: return
	var held = consumable_slot_ref.get_held_items()
	if index >= held.size(): return
	var item = held[index]
	var _l = Loc.i()
	var text: String
	if item["type"] == "planet":
		var p: PlanetData = item["data"]
		var hand_name = PokerHand.get_hand_name(p.hand_type)
		var info = HandLevel.get_level_info(p.hand_type)
		text = p.emoji + " " + _l.t(p.planet_name) + " - " + _l.t(p.description)
		text += " (Lv." + str(info["level"]) + "→" + str(info["level"] + 1) + ")"
	else:
		var t: TarotData = item["data"]
		text = t.emoji + " " + _l.t(t.tarot_name) + " - " + _l.t(t.description)
	text += "  [" + _l.t("Left: Use") + " | " + _l.t("Right: Sell") + " $2]"
	shop_info_label.text = text
	shop_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))

func _on_cons_click(index: int, event: InputEvent) -> void:
	if is_animating: return
	if not event is InputEventMouseButton or not event.pressed: return
	if event.button_index == MOUSE_BUTTON_LEFT:
		_use_consumable_in_shop(index)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		_sell_consumable_in_shop(index)

func _use_consumable_in_shop(index: int) -> void:
	if consumable_slot_ref == null: return
	var held = consumable_slot_ref.get_held_items()
	if index >= held.size(): return
	var item = held[index]
	var _l = Loc.i()
	if item["type"] == "planet":
		var planet: PlanetData = item["data"]
		var result = HandLevel.planet_level_up(planet.hand_type, planet.level_chips, planet.level_mult)
		var hand_name = PokerHand.get_hand_name(planet.hand_type)
		held.remove_at(index)
		consumable_slot_ref._rebuild()
		shop_info_label.text = "✨ " + _l.t(planet.planet_name) + "! " + _l.t(hand_name) + " → Lv." + str(result["new_level"])
		shop_info_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))
		_spawn_glow_particles(CENTER_X + CENTER_X / 2.0, OWNED_Y, Color(0.3, 0.5, 0.9))
	else:
		var tarot: TarotData = item["data"]
		## 需要选择手牌的塔罗在商店无法使用
		if tarot.needs_selection:
			shop_info_label.text = "⚠ " + _l.t("Use tarots during gameplay!")
			shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
			return
		## 不需要选牌的塔罗可以在商店直接使用
		held.remove_at(index)
		consumable_slot_ref._rebuild()
		match tarot.effect:
			TarotData.TarotEffect.GAIN_MONEY:
				var gain = 5
				var old_money = money
				money += gain
				_start_money_anim(old_money, money)
				shop_info_label.text = "🔮 " + _l.t(tarot.tarot_name) + "! +$" + str(gain)
				shop_info_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
			TarotData.TarotEffect.SPAWN_TAROT:
				var empty = consumable_slot_ref.get_empty_slots()
				var to_add = mini(2, empty)
				if to_add <= 0:
					shop_info_label.text = "🌎 " + _l.t("No empty slots!")
					shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
				else:
					var new_tarots = TarotDatabase.get_random_tarots(to_add)
					var names: PackedStringArray = []
					for t in new_tarots:
						consumable_slot_ref.add_tarot(t)
						names.append(_l.t(t.tarot_name))
					shop_info_label.text = "🌎 " + _l.t("Created") + " " + ", ".join(names) + "!"
					shop_info_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))
			TarotData.TarotEffect.SPAWN_PLANET:
				var empty = consumable_slot_ref.get_empty_slots()
				var to_add = mini(2, empty)
				if to_add <= 0:
					shop_info_label.text = "☀️ " + _l.t("No empty slots!")
					shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
				else:
					var new_planets = PlanetDatabase.get_random_planets(to_add)
					var names: PackedStringArray = []
					for p in new_planets:
						consumable_slot_ref.add_planet(p)
						names.append(_l.t(p.planet_name))
					shop_info_label.text = "☀️ " + _l.t("Created") + " " + ", ".join(names) + "!"
					shop_info_label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.95))
			TarotData.TarotEffect.RANDOM_LEVEL_UP:
				var types = PokerHand.HandType.values()
				var random_type = types[randi() % types.size()]
				HandLevel.planet_level_up(random_type, 20, 2)
				HandLevel.planet_level_up(random_type, 20, 2)
				var hname = PokerHand.get_hand_name(random_type)
				var lvl = HandLevel.get_level_info(random_type)["level"]
				shop_info_label.text = "🎰 " + _l.t(hname) + " → Lv." + str(lvl) + "!"
				shop_info_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
			_:
				shop_info_label.text = "⚠ " + _l.t("Use tarots during gameplay!")
				shop_info_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
				return
		_spawn_glow_particles(CENTER_X + CENTER_X / 2.0, OWNED_Y, Color(0.7, 0.35, 0.75))
	_build_ui()

func _sell_consumable_in_shop(index: int) -> void:
	if consumable_slot_ref == null: return
	var held = consumable_slot_ref.get_held_items()
	if index >= held.size(): return
	var item = held[index]
	var _l = Loc.i()
	var sell_price = 2
	var item_name: String
	if item["type"] == "planet":
		item_name = item["data"].planet_name
	else:
		item_name = item["data"].tarot_name
	held.remove_at(index)
	consumable_slot_ref._rebuild()
	money += sell_price
	_update_money_display()
	shop_info_label.text = _l.t("Sold") + " " + _l.t(item_name) + " +$" + str(sell_price)
	shop_info_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	_spawn_glow_particles(CENTER_X + CENTER_X / 2.0, OWNED_Y, Color(0.95, 0.8, 0.2))
	_build_ui()
