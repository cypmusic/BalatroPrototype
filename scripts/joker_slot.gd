## joker_slot.gd
## 小丑牌槽位 UI - 屏幕上方显示持有的小丑牌
extends Node2D

signal joker_hovered(joker_data: JokerData)
signal joker_unhovered()

const SLOT_WIDTH: float = 130.0
const SLOT_HEIGHT: float = 170.0
const SLOT_SPACING: float = 145.0
const MAX_JOKERS: int = 5

var owned_jokers: Array[JokerData] = []
var joker_visuals: Array[Node2D] = []

## 触发动画
var trigger_timers: Dictionary = {}  ## joker_index -> timer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	## 更新触发动画
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

## 触发某个小丑牌的动画
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

	## 为每张小丑牌创建交互区域
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

		## 捕获 i 的值
		var joker_index = i
		area.mouse_entered.connect(func(): _on_joker_hover(joker_index))
		area.mouse_exited.connect(func(): _on_joker_unhover())

		add_child(area)
		joker_visuals.append(area)

	queue_redraw()

func _get_joker_x(index: int) -> float:
	var count = owned_jokers.size()
	var total_width = (count - 1) * SLOT_SPACING
	return -total_width / 2.0 + index * SLOT_SPACING

func _draw() -> void:
	var count = owned_jokers.size()

	## 画空槽位
	for i in range(MAX_JOKERS):
		var x = _get_slot_x(i)
		var rect = Rect2(x - SLOT_WIDTH / 2, -SLOT_HEIGHT / 2, SLOT_WIDTH, SLOT_HEIGHT)
		draw_rect(rect, Color(0.15, 0.2, 0.18, 0.4), false, 1.5)

	## 画拥有的小丑牌
	for i in range(count):
		var joker = owned_jokers[i]
		var x = _get_joker_x(i)
		_draw_joker_card(x, joker, i)

func _get_slot_x(index: int) -> float:
	var total_width = (MAX_JOKERS - 1) * SLOT_SPACING
	return -total_width / 2.0 + index * SLOT_SPACING

func _draw_joker_card(x: float, joker: JokerData, index: int) -> void:
	var rect = Rect2(x - SLOT_WIDTH / 2, -SLOT_HEIGHT / 2, SLOT_WIDTH, SLOT_HEIGHT)

	## 触发时的发光效果
	var is_triggered = trigger_timers.has(index)
	if is_triggered:
		var t = trigger_timers[index]
		var glow_alpha = sin((t / 0.6) * PI) * 0.5
		var glow_rect = Rect2(rect.position - Vector2(6, 6), rect.size + Vector2(12, 12))
		draw_rect(glow_rect, Color(1.0, 0.85, 0.3, glow_alpha))

	## 阴影
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size), Color(0, 0, 0, 0.3))

	## 背景
	var bg_color = Color(0.12, 0.15, 0.2)
	if is_triggered:
		bg_color = Color(0.2, 0.25, 0.15)
	draw_rect(rect, bg_color)

	## 稀有度边框
	var rarity_color = joker.get_rarity_color()
	draw_rect(rect, rarity_color, false, 2.5)

	## Emoji 图标
	draw_string(ThemeDB.fallback_font,
		Vector2(x - 18, -15),
		joker.emoji, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color.WHITE)

	## 名字（居中）
	var font = Loc.i().cn_font if Loc.i().cn_font else ThemeDB.fallback_font
	draw_string(font,
		Vector2(x - SLOT_WIDTH / 2 + 5, SLOT_HEIGHT / 2 - 30),
		Loc.i().t(joker.joker_name), HORIZONTAL_ALIGNMENT_CENTER, SLOT_WIDTH - 10, 13, Color(0.85, 0.85, 0.8))

	## 效果描述（居中）
	draw_string(font,
		Vector2(x - SLOT_WIDTH / 2 + 5, SLOT_HEIGHT / 2 - 10),
		Loc.i().t(joker.description), HORIZONTAL_ALIGNMENT_CENTER, SLOT_WIDTH - 10, 11, Color(0.6, 0.6, 0.55))

func _on_joker_hover(index: int) -> void:
	if index < owned_jokers.size():
		joker_hovered.emit(owned_jokers[index])

func _on_joker_unhover() -> void:
	joker_unhovered.emit()
