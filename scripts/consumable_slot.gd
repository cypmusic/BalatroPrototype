## consumable_slot.gd
## 消耗品栏位 V0.075 - 支持动态栏位上限（Voucher 扩展）
extends Node2D

signal planet_used(planet: PlanetData)
signal tarot_used(tarot: TarotData)
signal consumable_hovered(text: String)
signal consumable_unhovered()

var MAX_CONSUMABLES: int = 2  ## 改为 var 以支持 Voucher 动态扩展
const SLOT_W: float = 90.0
const SLOT_H: float = 120.0
const SLOT_SPACING: float = 110.0

var held_items: Array = []
var hand_ref = null

func _t(key: String) -> String: return Loc.i().t(key)

func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font: lbl.add_theme_font_override("font", font)

func add_planet(planet: PlanetData) -> bool:
	if held_items.size() >= MAX_CONSUMABLES:
		return false
	held_items.append({"type": "planet", "data": planet})
	_rebuild()
	return true

func add_tarot(tarot: TarotData) -> bool:
	if held_items.size() >= MAX_CONSUMABLES:
		return false
	held_items.append({"type": "tarot", "data": tarot})
	_rebuild()
	return true

func get_held_count() -> int:
	return held_items.size()

func get_held_items() -> Array:
	return held_items

func is_full() -> bool:
	return held_items.size() >= MAX_CONSUMABLES

func get_empty_slots() -> int:
	return MAX_CONSUMABLES - held_items.size()

func clear_all() -> void:
	held_items.clear()
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()

	var title = Label.new()
	title.text = _t("CONSUMABLES")
	title.position = Vector2(-SLOT_SPACING, -SLOT_H / 2 - 22)
	title.custom_minimum_size = Vector2(SLOT_SPACING * 2, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	_f(title)
	add_child(title)

	for i in range(MAX_CONSUMABLES):
		var x = (i - (MAX_CONSUMABLES - 1) / 2.0) * SLOT_SPACING
		if i < held_items.size():
			var item = held_items[i]
			_draw_item_card(x, 0, item, i)
		else:
			_draw_empty_slot(x, 0)

func _draw_empty_slot(x: float, y: float) -> void:
	var empty = ColorRect.new()
	empty.position = Vector2(x - SLOT_W / 2, y - SLOT_H / 2)
	empty.size = Vector2(SLOT_W, SLOT_H)
	empty.color = Color(0.12, 0.15, 0.18, 0.4)
	empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(empty)
	var bw = 1.0
	for edge in [
		[Vector2(x - SLOT_W/2, y - SLOT_H/2), Vector2(SLOT_W, bw)],
		[Vector2(x - SLOT_W/2, y + SLOT_H/2 - bw), Vector2(SLOT_W, bw)],
		[Vector2(x - SLOT_W/2, y - SLOT_H/2), Vector2(bw, SLOT_H)],
		[Vector2(x + SLOT_W/2 - bw, y - SLOT_H/2), Vector2(bw, SLOT_H)],
	]:
		var border = ColorRect.new()
		border.position = edge[0]
		border.size = edge[1]
		border.color = Color(0.3, 0.3, 0.28, 0.4)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)

func _draw_item_card(x: float, y: float, item: Dictionary, index: int) -> void:
	var emoji: String
	var card_name: String
	var border_color: Color
	if item["type"] == "planet":
		var p: PlanetData = item["data"]
		emoji = p.emoji
		card_name = p.planet_name
		border_color = p.get_rarity_color()
	else:
		var t: TarotData = item["data"]
		emoji = t.emoji
		card_name = t.tarot_name
		border_color = t.get_rarity_color()

	## 幽冥牌使用更深的暗紫色背景
	var bg_color := Color(0.08, 0.12, 0.2)
	if item["type"] == "tarot":
		var t_item: TarotData = item["data"]
		if t_item.artifact_type == TarotData.ArtifactType.SPECTER:
			bg_color = Color(0.06, 0.04, 0.12)

	var bg = ColorRect.new()
	bg.position = Vector2(x - SLOT_W / 2, y - SLOT_H / 2)
	bg.size = Vector2(SLOT_W, SLOT_H)
	bg.color = bg_color
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var bw = 2.0
	for edge in [
		[Vector2(x - SLOT_W/2, y - SLOT_H/2), Vector2(SLOT_W, bw)],
		[Vector2(x - SLOT_W/2, y + SLOT_H/2 - bw), Vector2(SLOT_W, bw)],
		[Vector2(x - SLOT_W/2, y - SLOT_H/2), Vector2(bw, SLOT_H)],
		[Vector2(x + SLOT_W/2 - bw, y - SLOT_H/2), Vector2(bw, SLOT_H)],
	]:
		var border = ColorRect.new()
		border.position = edge[0]
		border.size = edge[1]
		border.color = border_color
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)

	var emoji_lbl = Label.new()
	emoji_lbl.text = emoji
	emoji_lbl.position = Vector2(x - SLOT_W / 2, y - SLOT_H / 2 + 5)
	emoji_lbl.custom_minimum_size = Vector2(SLOT_W, 0)
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.add_theme_font_size_override("font_size", 28)
	add_child(emoji_lbl)

	var name_lbl = Label.new()
	name_lbl.text = _t(card_name)
	name_lbl.position = Vector2(x - SLOT_W / 2 + 2, y - SLOT_H / 2 + 50)
	name_lbl.custom_minimum_size = Vector2(SLOT_W - 4, 0)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	_f(name_lbl)
	add_child(name_lbl)

	var use_lbl = Label.new()
	use_lbl.text = "[ " + _t("Use") + " ]"
	use_lbl.position = Vector2(x - SLOT_W / 2, y + SLOT_H / 2 - 22)
	use_lbl.custom_minimum_size = Vector2(SLOT_W, 0)
	use_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	use_lbl.add_theme_font_size_override("font_size", 11)
	use_lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 0.9))
	_f(use_lbl)
	add_child(use_lbl)

	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(SLOT_W, SLOT_H)
	collision.shape = shape
	area.position = Vector2(x, y)
	area.z_index = 10
	area.add_child(collision)
	area.input_pickable = true
	var idx = index
	area.mouse_entered.connect(func(): _on_hover(idx))
	area.mouse_exited.connect(func(): _on_unhover())
	area.input_event.connect(func(_vp, ev, _si): _on_click(idx, ev))
	add_child(area)

func _on_hover(index: int) -> void:
	if index >= held_items.size(): return
	var item = held_items[index]
	var text: String
	var _l = Loc.i()
	if item["type"] == "planet":
		var p: PlanetData = item["data"]
		var info = HandLevel.get_level_info(p.hand_type)
		text = p.emoji + " " + _l.t(p.planet_name) + " - " + _l.t(p.description)
		text += " (Lv." + str(info["level"]) + "→" + str(info["level"] + 1)
		text += "  +" + str(p.level_chips) + " " + _l.t("Chips") + ", +" + str(p.level_mult) + " " + _l.t("Mult") + ")"
	else:
		var t: TarotData = item["data"]
		text = t.emoji + " " + _l.t(t.tarot_name) + " - " + _l.t(t.description)
		if t.needs_selection:
			text += " (" + _l.t("Select") + " " + str(t.min_select)
			if t.max_select > t.min_select:
				text += "-" + str(t.max_select)
			text += " " + _l.t("cards") + ")"
		elif t.needs_joker_selection:
			text += " (" + _l.t("Select") + " 1 " + _l.t("Beast") + ")"
	consumable_hovered.emit(text)

func _on_unhover() -> void:
	consumable_unhovered.emit()

func _on_click(index: int, event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_use_item(index)

func _use_item(index: int) -> void:
	if index >= held_items.size(): return
	var item = held_items[index]

	if item["type"] == "planet":
		var planet: PlanetData = item["data"]
		held_items.remove_at(index)
		planet_used.emit(planet)
		_rebuild()
	else:
		var tarot: TarotData = item["data"]
		if tarot.needs_selection and hand_ref:
			var selected = hand_ref.get_selected_cards()
			if selected.size() < tarot.min_select:
				consumable_hovered.emit("⚠ " + _t("Select") + " " + str(tarot.min_select) + "+ " + _t("cards"))
				return
			if tarot.max_select > 0 and selected.size() > tarot.max_select:
				consumable_hovered.emit("⚠ " + _t("Max") + " " + str(tarot.max_select) + " " + _t("cards"))
				return
		held_items.remove_at(index)
		tarot_used.emit(tarot)
		_rebuild()
