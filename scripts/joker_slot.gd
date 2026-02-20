## joker_slot.gd
## 小丑牌槽位 UI V3 - 改用 Label 节点解决中文+Emoji 渲染 (4K×2)
extends Node2D

signal joker_hovered(joker_data: JokerData)
signal joker_unhovered()

const SLOT_WIDTH: float = 260.0
const SLOT_HEIGHT: float = 340.0
const SLOT_SPACING: float = 290.0
var MAX_JOKERS: int = 5

var owned_jokers: Array[JokerData] = []
var joker_visuals: Array[Node2D] = []
var card_labels: Array[Node] = []  ## Label 节点缓存

## 触发动画
var trigger_timers: Dictionary = {}  ## joker_index -> timer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var to_remove: Array = []
	for idx in trigger_timers:
		trigger_timers[idx] += delta
		if trigger_timers[idx] > 0.6:
			to_remove.append(idx)
	for idx in to_remove:
		trigger_timers.erase(idx)
	if not trigger_timers.is_empty() or not to_remove.is_empty():
		queue_redraw()

func add_joker(data: JokerData) -> bool:
	if owned_jokers.size() >= MAX_JOKERS:
		return false
	owned_jokers.append(data)
	_rebuild_visuals()
	return true

func remove_joker(index: int) -> void:
	if index < 0 or index >= owned_jokers.size():
		return
	owned_jokers.remove_at(index)
	_rebuild_visuals()

func get_owned_jokers() -> Array[JokerData]:
	return owned_jokers

func trigger_joker_animation(joker_data: JokerData) -> void:
	var idx = owned_jokers.find(joker_data)
	if idx >= 0:
		trigger_timers[idx] = 0.0
		queue_redraw()

func _rebuild_visuals() -> void:
	## 清除旧的交互区域
	for visual in joker_visuals:
		if is_instance_valid(visual):
			visual.queue_free()
	joker_visuals.clear()

	## 清除旧的 Label 节点
	for lbl in card_labels:
		if is_instance_valid(lbl):
			lbl.queue_free()
	card_labels.clear()

	## 为每张小丑牌创建交互区域 + Label
	for i in range(owned_jokers.size()):
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(SLOT_WIDTH, SLOT_HEIGHT)
		collision.shape = shape

		var x_pos = _get_joker_x(i)
		area.position = Vector2(x_pos, 0)
		area.add_child(collision)
		area.input_pickable = true

		var joker_index = i
		area.mouse_entered.connect(func(): _on_joker_hover(joker_index))
		area.mouse_exited.connect(func(): _on_joker_unhover())

		add_child(area)
		joker_visuals.append(area)

		## 创建 Label 节点（自动使用全局 Theme 字体，支持 emoji 回退）
		_create_card_labels(x_pos, owned_jokers[i])

	queue_redraw()

func _create_card_labels(x: float, joker: JokerData) -> void:
	var loc = Loc.i()

	## Emoji 图标
	var emoji_lbl = Label.new()
	emoji_lbl.text = joker.emoji
	emoji_lbl.position = Vector2(x - SLOT_WIDTH / 2, -SLOT_HEIGHT / 2 + 20)
	emoji_lbl.custom_minimum_size = Vector2(SLOT_WIDTH, 100)
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.add_theme_font_size_override("font_size", 72)
	emoji_lbl.add_theme_color_override("font_color", Color.WHITE)
	emoji_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(emoji_lbl)
	card_labels.append(emoji_lbl)

	## 名称
	var name_lbl = Label.new()
	name_lbl.text = loc.t(joker.joker_name)
	name_lbl.position = Vector2(x - SLOT_WIDTH / 2 + 6, SLOT_HEIGHT / 2 - 84)
	name_lbl.custom_minimum_size = Vector2(SLOT_WIDTH - 12, 0)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 24)
	name_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	name_lbl.clip_text = true
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if loc.cn_font:
		name_lbl.add_theme_font_override("font", loc.cn_font)
	add_child(name_lbl)
	card_labels.append(name_lbl)

	## 效果描述
	var desc_lbl = Label.new()
	desc_lbl.text = loc.t(joker.description)
	desc_lbl.position = Vector2(x - SLOT_WIDTH / 2 + 6, SLOT_HEIGHT / 2 - 44)
	desc_lbl.custom_minimum_size = Vector2(SLOT_WIDTH - 12, 0)
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 20)
	desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	desc_lbl.clip_text = true
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if loc.cn_font:
		desc_lbl.add_theme_font_override("font", loc.cn_font)
	add_child(desc_lbl)
	card_labels.append(desc_lbl)

func _get_joker_x(index: int) -> float:
	var count = owned_jokers.size()
	var total_width = (count - 1) * SLOT_SPACING
	return -total_width / 2.0 + index * SLOT_SPACING

func _draw() -> void:
	## 画空槽位
	for i in range(MAX_JOKERS):
		var x = _get_slot_x(i)
		var rect = Rect2(x - SLOT_WIDTH / 2, -SLOT_HEIGHT / 2, SLOT_WIDTH, SLOT_HEIGHT)
		draw_rect(rect, Color(0.15, 0.2, 0.18, 0.4), false, 3.0)

	## 画拥有的小丑牌卡片背景/边框/发光（文字由 Label 节点负责）
	for i in range(owned_jokers.size()):
		var joker = owned_jokers[i]
		var x = _get_joker_x(i)
		_draw_joker_card_bg(x, joker, i)

func _get_slot_x(index: int) -> float:
	var total_width = (MAX_JOKERS - 1) * SLOT_SPACING
	return -total_width / 2.0 + index * SLOT_SPACING

func _draw_joker_card_bg(x: float, joker: JokerData, index: int) -> void:
	var rect = Rect2(x - SLOT_WIDTH / 2, -SLOT_HEIGHT / 2, SLOT_WIDTH, SLOT_HEIGHT)

	## 触发时的发光效果
	var is_triggered = trigger_timers.has(index)
	if is_triggered:
		var t = trigger_timers[index]
		var glow_alpha = sin((t / 0.6) * PI) * 0.5
		var glow_rect = Rect2(rect.position - Vector2(12, 12), rect.size + Vector2(24, 24))
		draw_rect(glow_rect, Color(1.0, 0.85, 0.3, glow_alpha))

	## 阴影
	draw_rect(Rect2(rect.position + Vector2(6, 6), rect.size), Color(0, 0, 0, 0.3))

	## 背景
	var bg_color = Color(0.12, 0.15, 0.2)
	if is_triggered:
		bg_color = Color(0.2, 0.25, 0.15)
	draw_rect(rect, bg_color)

	## 稀有度边框
	var rarity_color = joker.get_rarity_color()
	draw_rect(rect, rarity_color, false, 5.0)

func _on_joker_hover(index: int) -> void:
	if index < owned_jokers.size():
		joker_hovered.emit(owned_jokers[index])

func _on_joker_unhover() -> void:
	joker_unhovered.emit()
