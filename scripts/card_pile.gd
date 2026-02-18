## card_pile.gd
## 卡牌堆显示 V6.2 - 缩小尺寸确保完整显示
extends Node2D

enum PileType { DRAW_PILE, DISCARD_PILE }

@export var pile_type: PileType = PileType.DRAW_PILE

var card_count: int = 0
var pile_label: Label

const CARD_WIDTH: float = 90.0
const CARD_HEIGHT: float = 126.0

const BACK_COLOR_PRIMARY: Color = Color(0.15, 0.25, 0.55)
const BACK_COLOR_BORDER: Color = Color(0.6, 0.5, 0.2)
const BACK_PATTERN_COLOR: Color = Color(0.2, 0.32, 0.65)

func _ready() -> void:
	pile_label = Label.new()
	pile_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pile_label.position = Vector2(-CARD_WIDTH / 2, CARD_HEIGHT / 2 + 8)
	pile_label.custom_minimum_size = Vector2(CARD_WIDTH, 25)
	pile_label.add_theme_font_size_override("font_size", 18)
	pile_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
	add_child(pile_label)
	_update_label()

func set_count(count: int) -> void:
	card_count = count
	_update_label()
	queue_redraw()

func _update_label() -> void:
	if pile_label == null:
		return
	pile_label.text = str(card_count)

func _draw() -> void:
	if card_count <= 0:
		var rect = Rect2(-CARD_WIDTH / 2, -CARD_HEIGHT / 2, CARD_WIDTH, CARD_HEIGHT)
		draw_rect(rect, Color(0.3, 0.3, 0.25, 0.3), false, 2.0)
		return

	var layers = mini(card_count, 3)
	for i in range(layers):
		var offset = Vector2(-(layers - 1 - i) * 2, -(layers - 1 - i) * 2)
		_draw_card_back(offset)

func _draw_card_back(offset: Vector2) -> void:
	var rect = Rect2(-CARD_WIDTH / 2 + offset.x, -CARD_HEIGHT / 2 + offset.y, CARD_WIDTH, CARD_HEIGHT)

	## 阴影
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size), Color(0, 0, 0, 0.3))

	## 卡背底色
	draw_rect(rect, BACK_COLOR_PRIMARY)

	## 内边框
	var m = 6.0
	draw_rect(Rect2(rect.position.x + m, rect.position.y + m, rect.size.x - m * 2, rect.size.y - m * 2),
		BACK_COLOR_BORDER, false, 1.5)

	## 中心菱形
	var cx = rect.position.x + rect.size.x / 2
	var cy = rect.position.y + rect.size.y / 2
	var ds = 18.0
	var diamond = PackedVector2Array([
		Vector2(cx, cy - ds), Vector2(cx + ds * 0.7, cy),
		Vector2(cx, cy + ds), Vector2(cx - ds * 0.7, cy)])
	draw_colored_polygon(diamond, BACK_PATTERN_COLOR)
	draw_polyline(diamond, BACK_COLOR_BORDER, 1.5)
	draw_line(diamond[-1], diamond[0], BACK_COLOR_BORDER, 1.5)

	## 外边框
	draw_rect(rect, Color(0.4, 0.35, 0.2), false, 1.5)
