## card.gd
## 单张卡牌 V7.0 - 视觉升级：象牙白底色 + 经典红黑花色 + 人物图片加载
extends Node2D

signal card_clicked(card_node: Node2D)
signal card_hovered(card_node: Node2D)
signal card_unhovered(card_node: Node2D)
signal card_drag_started(card_node: Node2D)
signal card_drag_ended(card_node: Node2D)
signal card_exit_done(card_node: Node2D)

var card_data: CardData
var is_selected: bool = false
var is_hovered: bool = false
var is_animating: bool = false
var is_dragging: bool = false
var is_scoring: bool = false
var is_exiting: bool = false

## 卡牌视觉参数
const CARD_WIDTH: float = 140.0
const CARD_HEIGHT: float = 195.0
const HOVER_OFFSET: float = -35.0
const SELECT_OFFSET: float = -55.0
const CORNER_RADIUS: float = 8.0

var base_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

## 拖拽判定
var mouse_press_pos: Vector2 = Vector2.ZERO
var is_mouse_down: bool = false
var drag_confirmed: bool = false
const DRAG_THRESHOLD: float = 10.0

## 入场动画参数
var anim_progress: float = 0.0
var anim_start_pos: Vector2 = Vector2.ZERO
var anim_delay: float = 0.0
var anim_timer: float = 0.0
const ANIM_DURATION: float = 0.35

## 退场动画参数
var exit_start_pos: Vector2 = Vector2.ZERO
var exit_target_pos: Vector2 = Vector2.ZERO
var exit_progress: float = 0.0
var exit_delay: float = 0.0
var exit_timer: float = 0.0
const EXIT_DURATION: float = 0.4

## 计分动画参数
var score_anim_timer: float = 0.0
var score_anim_duration: float = 0.8
var score_glow_intensity: float = 0.0

## 视觉效果
var hover_glow: float = 0.0
var target_hover_glow: float = 0.0

## 防抖动
var hover_amount: float = 0.0
var hover_target: float = 0.0
const HOVER_SPEED_UP: float = 8.0
const HOVER_SPEED_DOWN: float = 5.0

## ========== 配色常量 ==========

## 卡牌底色 - 象牙白/淡米色
const CARD_BG_TOP: Color = Color(0.98, 0.96, 0.91)       # 顶部稍亮
const CARD_BG_BOTTOM: Color = Color(0.94, 0.91, 0.85)     # 底部稍暖
const CARD_BG_SELECTED_TOP: Color = Color(0.92, 0.94, 0.98)
const CARD_BG_SELECTED_BOTTOM: Color = Color(0.87, 0.90, 0.96)
const CARD_BG_SCORING: Color = Color(1.0, 0.97, 0.88)

## 花色颜色 - 经典红黑
const SUIT_RED: Color = Color(0.78, 0.12, 0.12)           # 深红
const SUIT_BLACK: Color = Color(0.12, 0.12, 0.14)         # 近黑
const SUIT_RED_LIGHT: Color = Color(0.88, 0.22, 0.22)     # 亮红（悬停）
const SUIT_BLACK_LIGHT: Color = Color(0.25, 0.25, 0.28)   # 亮黑（悬停）

## 边框颜色
const BORDER_NORMAL: Color = Color(0.72, 0.68, 0.62)
const BORDER_HOVER: Color = Color(0.55, 0.60, 0.75)
const BORDER_SELECTED: Color = Color(0.30, 0.45, 0.85)
const BORDER_SCORING: Color = Color(0.90, 0.72, 0.18)
const BORDER_DRAG: Color = Color(0.50, 0.65, 0.95)

## ========== 人物牌图片缓存 ==========
## 图片路径格式: res://assets/cards/face_[suit]_[rank].png
## 例如: res://assets/cards/face_spades_jack.png
static var face_textures: Dictionary = {}
static var face_textures_loaded: bool = false

static func _load_face_textures() -> void:
	if face_textures_loaded:
		return
	face_textures_loaded = true
	var suit_names = {
		CardData.Suit.HEARTS: "hearts",
		CardData.Suit.DIAMONDS: "diamonds",
		CardData.Suit.CLUBS: "clubs",
		CardData.Suit.SPADES: "spades"
	}
	var rank_names = {
		CardData.Rank.JACK: "jack",
		CardData.Rank.QUEEN: "queen",
		CardData.Rank.KING: "king"
	}
	for suit in suit_names:
		for rank in rank_names:
			var path = "res://assets/cards/face_%s_%s.png" % [suit_names[suit], rank_names[rank]]
			if ResourceLoader.exists(path):
				face_textures["%d_%d" % [suit, rank]] = load(path)

func _get_face_texture() -> Texture2D:
	if not face_textures_loaded:
		_load_face_textures()
	var key = "%d_%d" % [card_data.suit, card_data.rank]
	return face_textures.get(key, null)

## ========== 花色符号位置布局 ==========
## 经典扑克牌花色排列（相对于卡牌中心的归一化坐标）

const SUIT_LAYOUTS: Dictionary = {
	1: [Vector2(0, 0)],  # A - 居中一个大符号
	2: [Vector2(0, -0.32), Vector2(0, 0.32)],
	3: [Vector2(0, -0.32), Vector2(0, 0), Vector2(0, 0.32)],
	4: [Vector2(-0.22, -0.32), Vector2(0.22, -0.32), Vector2(-0.22, 0.32), Vector2(0.22, 0.32)],
	5: [Vector2(-0.22, -0.32), Vector2(0.22, -0.32), Vector2(0, 0), Vector2(-0.22, 0.32), Vector2(0.22, 0.32)],
	6: [Vector2(-0.22, -0.32), Vector2(0.22, -0.32), Vector2(-0.22, 0), Vector2(0.22, 0), Vector2(-0.22, 0.32), Vector2(0.22, 0.32)],
	7: [Vector2(-0.22, -0.32), Vector2(0.22, -0.32), Vector2(0, -0.16), Vector2(-0.22, 0), Vector2(0.22, 0), Vector2(-0.22, 0.32), Vector2(0.22, 0.32)],
	8: [Vector2(-0.22, -0.32), Vector2(0.22, -0.32), Vector2(0, -0.16), Vector2(-0.22, 0), Vector2(0.22, 0), Vector2(0, 0.16), Vector2(-0.22, 0.32), Vector2(0.22, 0.32)],
	9: [Vector2(-0.22, -0.35), Vector2(0.22, -0.35), Vector2(-0.22, -0.12), Vector2(0.22, -0.12), Vector2(0, 0), Vector2(-0.22, 0.12), Vector2(0.22, 0.12), Vector2(-0.22, 0.35), Vector2(0.22, 0.35)],
	10: [Vector2(-0.22, -0.35), Vector2(0.22, -0.35), Vector2(0, -0.22), Vector2(-0.22, -0.12), Vector2(0.22, -0.12), Vector2(-0.22, 0.12), Vector2(0.22, 0.12), Vector2(0, 0.22), Vector2(-0.22, 0.35), Vector2(0.22, 0.35)],
}

func _ready() -> void:
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	collision.shape = shape
	area.add_child(collision)
	add_child(area)

	area.input_pickable = true
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)

func setup(data: CardData) -> void:
	card_data = data
	queue_redraw()

func animate_from(from_pos: Vector2, delay: float) -> void:
	is_animating = true
	anim_start_pos = from_pos
	anim_progress = 0.0
	anim_delay = delay
	anim_timer = 0.0
	position = from_pos

func animate_exit(target_pos: Vector2, delay: float = 0.0) -> void:
	is_exiting = true
	is_selected = false
	exit_start_pos = position
	exit_target_pos = target_pos
	exit_progress = 0.0
	exit_delay = delay
	exit_timer = 0.0

func play_score_animation(delay: float = 0.0) -> void:
	is_scoring = true
	score_anim_timer = -delay
	score_glow_intensity = 0.0

func _process(delta: float) -> void:
	## 退场动画（优先级最高）
	if is_exiting:
		exit_timer += delta
		if exit_timer < exit_delay:
			return
		exit_progress += delta / EXIT_DURATION
		if exit_progress >= 1.0:
			exit_progress = 1.0
			is_exiting = false
			card_exit_done.emit(self)
			return
		var t = exit_progress * exit_progress
		position = exit_start_pos.lerp(exit_target_pos, t)
		var s = 1.0 - exit_progress * 0.4
		scale = Vector2(s, s)
		modulate.a = 1.0 - exit_progress * 0.5
		return

	## 入场动画
	if is_animating:
		anim_timer += delta
		if anim_timer < anim_delay:
			return
		anim_progress += delta / ANIM_DURATION
		if anim_progress >= 1.0:
			anim_progress = 1.0
			is_animating = false
		var t = 1.0 - pow(1.0 - anim_progress, 3.0)
		position = anim_start_pos.lerp(base_position, t)
		return

	## 计分动画
	if is_scoring:
		score_anim_timer += delta
		if score_anim_timer >= 0.0:
			var progress = score_anim_timer / score_anim_duration
			if progress >= 1.0:
				is_scoring = false
				score_glow_intensity = 0.0
			else:
				score_glow_intensity = sin(progress * PI)
			queue_redraw()

	## 拖拽阈值检测
	if is_mouse_down and not drag_confirmed:
		var current_mouse = get_global_mouse_position()
		if current_mouse.distance_to(mouse_press_pos) > DRAG_THRESHOLD:
			drag_confirmed = true
			is_dragging = true
			z_index = 100
			card_drag_started.emit(self)

	## 拖拽跟随
	if is_dragging:
		var mouse_pos = get_parent().get_local_mouse_position()
		position.x = mouse_pos.x
		position.y = base_position.y + SELECT_OFFSET
		return

	## 平滑悬停
	hover_target = 1.0 if is_hovered else 0.0
	if hover_amount < hover_target:
		hover_amount = minf(hover_amount + delta * HOVER_SPEED_UP, 1.0)
	elif hover_amount > hover_target:
		hover_amount = maxf(hover_amount - delta * HOVER_SPEED_DOWN, 0.0)

	var y_offset: float = 0.0
	if is_selected:
		y_offset = SELECT_OFFSET
	else:
		y_offset = HOVER_OFFSET * hover_amount

	target_position = base_position + Vector2(0, y_offset)
	position = position.lerp(target_position, delta * 12.0)

	target_hover_glow = 1.0 if is_hovered else 0.0
	hover_glow = lerp(hover_glow, target_hover_glow, delta * 10.0)

	if hover_glow > 0.01 or is_scoring:
		queue_redraw()

## ========== 绘制 ==========

func _draw() -> void:
	if card_data == null:
		return

	var rect = Rect2(-CARD_WIDTH / 2, -CARD_HEIGHT / 2, CARD_WIDTH, CARD_HEIGHT)
	var suit_color = _get_suit_color()

	## 外发光
	if score_glow_intensity > 0.0:
		_draw_glow(rect, Color(1.0, 0.85, 0.3, score_glow_intensity * 0.6), 12.0)
	elif hover_glow > 0.05:
		_draw_glow(rect, Color(0.5, 0.7, 1.0, hover_glow * 0.3), 8.0)

	## 阴影
	var shadow_offset = Vector2(6, 8) if is_dragging else Vector2(3, 4)
	var shadow_alpha = 0.35 if is_dragging else 0.2
	_draw_rounded_rect(Rect2(rect.position + shadow_offset, rect.size), CORNER_RADIUS, Color(0, 0, 0, shadow_alpha))

	## 底色（圆角矩形 + 渐变）
	if is_scoring and score_glow_intensity > 0.3:
		_draw_rounded_rect(rect, CORNER_RADIUS, CARD_BG_SCORING)
	elif is_selected:
		_draw_rounded_gradient(rect, CORNER_RADIUS, CARD_BG_SELECTED_TOP, CARD_BG_SELECTED_BOTTOM)
	else:
		_draw_rounded_gradient(rect, CORNER_RADIUS, CARD_BG_TOP, CARD_BG_BOTTOM)

	## 内边线（细微的装饰线）
	var inner_margin = 6.0
	var inner_rect = Rect2(rect.position + Vector2(inner_margin, inner_margin), rect.size - Vector2(inner_margin * 2, inner_margin * 2))
	var inner_color = Color(suit_color.r, suit_color.g, suit_color.b, 0.08)
	_draw_rounded_rect_outline(inner_rect, CORNER_RADIUS - 2, inner_color, 0.5)

	## 边框
	var border_color: Color
	var border_width: float
	if is_scoring and score_glow_intensity > 0.3:
		border_color = BORDER_SCORING
		border_width = 3.5
	elif is_selected:
		border_color = BORDER_SELECTED
		border_width = 3.0
	elif is_dragging:
		border_color = BORDER_DRAG
		border_width = 2.5
	elif hover_glow > 0.1:
		border_color = BORDER_NORMAL.lerp(BORDER_HOVER, hover_glow)
		border_width = 1.5 + hover_glow
	else:
		border_color = BORDER_NORMAL
		border_width = 1.5
	_draw_rounded_rect_outline(rect, CORNER_RADIUS, border_color, border_width)

	## 角标（左上 + 右下翻转）
	_draw_corner_labels(suit_color)

	## 中心内容
	if card_data.rank >= CardData.Rank.JACK:
		_draw_face_card(rect, suit_color)
	else:
		_draw_number_card(rect, suit_color)

## ========== 角标绘制 ==========

func _draw_corner_labels(suit_color: Color) -> void:
	var rank_text = card_data.get_rank_text()
	var suit_symbol = card_data.get_suit_symbol()

	## 计分时花色颜色变亮
	var draw_color = suit_color
	if is_scoring and score_glow_intensity > 0.3:
		draw_color = suit_color.lerp(Color(0.9, 0.7, 0.15), score_glow_intensity * 0.4)

	## 左上角 - 数字
	draw_string(ThemeDB.fallback_font, Vector2(-CARD_WIDTH / 2 + 10, -CARD_HEIGHT / 2 + 28),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, draw_color)
	## 左上角 - 花色
	draw_string(ThemeDB.fallback_font, Vector2(-CARD_WIDTH / 2 + 10, -CARD_HEIGHT / 2 + 48),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)

	## 右下角 - 数字（翻转）
	draw_string(ThemeDB.fallback_font, Vector2(CARD_WIDTH / 2 - 30, CARD_HEIGHT / 2 - 16),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, draw_color)
	## 右下角 - 花色
	draw_string(ThemeDB.fallback_font, Vector2(CARD_WIDTH / 2 - 27, CARD_HEIGHT / 2 - 34),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)

## ========== 数字牌绘制 ==========

func _draw_number_card(rect: Rect2, suit_color: Color) -> void:
	var rank_val = card_data.rank
	var suit_symbol = card_data.get_suit_symbol()

	## A 特殊处理 - 中心大符号
	if rank_val == CardData.Rank.ACE:
		_draw_ace(rect, suit_color)
		return

	## 2-10 使用经典布局
	if SUIT_LAYOUTS.has(rank_val):
		var positions = SUIT_LAYOUTS[rank_val]
		var center = rect.get_center()
		var area_w = CARD_WIDTH - 40  # 去掉角标区域
		var area_h = CARD_HEIGHT - 50

		for pos in positions:
			var draw_pos = center + Vector2(pos.x * area_w, pos.y * area_h)
			## 下半部分的符号需要翻转（传统扑克牌样式）
			var is_flipped = pos.y > 0.05
			_draw_suit_symbol(draw_pos, suit_color, 22, is_flipped and rank_val >= 4)

## A 牌 - 大号居中花色符号 + 装饰
func _draw_ace(rect: Rect2, suit_color: Color) -> void:
	var center = rect.get_center()
	## 大号花色符号
	_draw_suit_symbol(center + Vector2(0, -2), suit_color, 44, false)
	## 装饰环
	var ring_color = Color(suit_color.r, suit_color.g, suit_color.b, 0.12)
	draw_arc(center + Vector2(0, -2), 36, 0, TAU, 48, ring_color, 1.0)
	draw_arc(center + Vector2(0, -2), 42, 0, TAU, 48, Color(ring_color.r, ring_color.g, ring_color.b, 0.06), 0.5)

## ========== 人物牌绘制 ==========

func _draw_face_card(rect: Rect2, suit_color: Color) -> void:
	var center = rect.get_center()
	var texture = _get_face_texture()

	if texture != null:
		## 有人物图片 - 居中绘制
		var tex_size = texture.get_size()
		var target_w = CARD_WIDTH - 28
		var target_h = CARD_HEIGHT - 58
		var scale_factor = minf(target_w / tex_size.x, target_h / tex_size.y)
		var draw_size = tex_size * scale_factor
		var draw_pos = center - draw_size / 2 + Vector2(0, 2)
		draw_texture_rect(texture, Rect2(draw_pos, draw_size), false)
		## 人物牌底部加花色小标
		_draw_suit_symbol(Vector2(center.x, rect.position.y + rect.size.y - 24), suit_color, 16, false)
	else:
		## 无图片时的备用绘制 - 精致的字母 + 花色装饰
		_draw_face_fallback(rect, suit_color)

## 人物牌备用绘制（无图片时）
func _draw_face_fallback(rect: Rect2, suit_color: Color) -> void:
	var center = rect.get_center()
	var rank_text = card_data.get_rank_text()
	var suit_symbol = card_data.get_suit_symbol()

	## 背景装饰框
	var deco_rect = Rect2(center.x - 38, center.y - 48, 76, 80)
	var deco_color = Color(suit_color.r, suit_color.g, suit_color.b, 0.06)
	_draw_rounded_rect(deco_rect, 4.0, deco_color)
	_draw_rounded_rect_outline(deco_rect, 4.0, Color(suit_color.r, suit_color.g, suit_color.b, 0.15), 1.0)

	## 大号字母
	draw_string(ThemeDB.fallback_font, Vector2(center.x - 18, center.y + 8),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 52, suit_color)

	## 四角花色装饰
	var offset = 28.0
	_draw_suit_symbol(center + Vector2(-offset, -offset - 10), suit_color, 14, false)
	_draw_suit_symbol(center + Vector2(offset, -offset - 10), suit_color, 14, false)
	_draw_suit_symbol(center + Vector2(-offset, offset + 18), suit_color, 14, true)
	_draw_suit_symbol(center + Vector2(offset, offset + 18), suit_color, 14, true)

## ========== 花色符号绘制 ==========

func _draw_suit_symbol(pos: Vector2, color: Color, size: float, flipped: bool) -> void:
	var suit_symbol = card_data.get_suit_symbol()
	var font_size = int(size)
	var offset = Vector2(-size * 0.3, size * 0.35)
	if flipped:
		## 简单模拟翻转：向下偏移
		offset.y = size * 0.35
	draw_string(ThemeDB.fallback_font, pos + offset, suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

## ========== 工具函数 ==========

func _get_suit_color() -> Color:
	match card_data.suit:
		CardData.Suit.HEARTS, CardData.Suit.DIAMONDS:
			if is_hovered and not is_selected:
				return SUIT_RED_LIGHT
			return SUIT_RED
		_:
			if is_hovered and not is_selected:
				return SUIT_BLACK_LIGHT
			return SUIT_BLACK

func _draw_glow(rect: Rect2, color: Color, spread: float) -> void:
	for i in range(3):
		var s = spread * (i + 1) / 3.0
		var alpha = color.a * (1.0 - float(i) / 3.0)
		_draw_rounded_rect(Rect2(rect.position - Vector2(s, s), rect.size + Vector2(s * 2, s * 2)),
			CORNER_RADIUS + s, Color(color.r, color.g, color.b, alpha))

func _draw_rounded_rect(rect: Rect2, radius: float, color: Color) -> void:
	## 用多个矩形和圆形模拟圆角矩形
	var r = minf(radius, minf(rect.size.x, rect.size.y) / 2.0)
	## 中间大矩形
	draw_rect(Rect2(rect.position.x + r, rect.position.y, rect.size.x - r * 2, rect.size.y), color)
	## 左右条
	draw_rect(Rect2(rect.position.x, rect.position.y + r, r, rect.size.y - r * 2), color)
	draw_rect(Rect2(rect.position.x + rect.size.x - r, rect.position.y + r, r, rect.size.y - r * 2), color)
	## 四个角的圆
	draw_circle(rect.position + Vector2(r, r), r, color)
	draw_circle(rect.position + Vector2(rect.size.x - r, r), r, color)
	draw_circle(rect.position + Vector2(r, rect.size.y - r), r, color)
	draw_circle(rect.position + Vector2(rect.size.x - r, rect.size.y - r), r, color)

func _draw_rounded_gradient(rect: Rect2, radius: float, top_color: Color, bottom_color: Color) -> void:
	## 分层绘制渐变
	var steps = 10
	var step_h = rect.size.y / steps
	for i in range(steps):
		var t = float(i) / (steps - 1)
		var color = top_color.lerp(bottom_color, t)
		var y = rect.position.y + i * step_h
		var h = step_h + 1  # +1 避免缝隙
		## 首行和末行裁剪到圆角内
		if i == 0:
			draw_rect(Rect2(rect.position.x + radius, y, rect.size.x - radius * 2, h), color)
		elif i == steps - 1:
			draw_rect(Rect2(rect.position.x + radius, y, rect.size.x - radius * 2, h), color)
		else:
			draw_rect(Rect2(rect.position.x, y, rect.size.x, h), color)
	## 覆盖四角圆
	draw_circle(rect.position + Vector2(radius, radius), radius, top_color)
	draw_circle(rect.position + Vector2(rect.size.x - radius, radius), radius, top_color)
	draw_circle(rect.position + Vector2(radius, rect.size.y - radius), radius, bottom_color)
	draw_circle(rect.position + Vector2(rect.size.x - radius, rect.size.y - radius), radius, bottom_color)

func _draw_rounded_rect_outline(rect: Rect2, radius: float, color: Color, width: float) -> void:
	var r = minf(radius, minf(rect.size.x, rect.size.y) / 2.0)
	## 上边
	draw_line(Vector2(rect.position.x + r, rect.position.y), Vector2(rect.position.x + rect.size.x - r, rect.position.y), color, width)
	## 下边
	draw_line(Vector2(rect.position.x + r, rect.position.y + rect.size.y), Vector2(rect.position.x + rect.size.x - r, rect.position.y + rect.size.y), color, width)
	## 左边
	draw_line(Vector2(rect.position.x, rect.position.y + r), Vector2(rect.position.x, rect.position.y + rect.size.y - r), color, width)
	## 右边
	draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y + r), Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y - r), color, width)
	## 四个圆角弧线
	draw_arc(rect.position + Vector2(r, r), r, PI, PI * 1.5, 12, color, width)
	draw_arc(rect.position + Vector2(rect.size.x - r, r), r, PI * 1.5, PI * 2.0, 12, color, width)
	draw_arc(rect.position + Vector2(r, rect.size.y - r), r, PI * 0.5, PI, 12, color, width)
	draw_arc(rect.position + Vector2(rect.size.x - r, rect.size.y - r), r, 0, PI * 0.5, 12, color, width)

## ========== 交互 ==========

func _on_mouse_entered() -> void:
	if is_animating or is_exiting:
		return
	is_hovered = true
	queue_redraw()
	card_hovered.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	queue_redraw()
	card_unhovered.emit(self)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_animating or is_exiting:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_mouse_down = true
			drag_confirmed = false
			mouse_press_pos = get_global_mouse_position()
		else:
			_handle_mouse_release()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_mouse_down or is_dragging:
			_handle_mouse_release()

func _handle_mouse_release() -> void:
	if not is_mouse_down and not is_dragging:
		return
	if not drag_confirmed:
		if is_mouse_down:
			toggle_select()
	else:
		is_dragging = false
		z_index = 0
		card_drag_ended.emit(self)
	is_mouse_down = false
	drag_confirmed = false

func toggle_select() -> void:
	is_selected = not is_selected
	queue_redraw()
	card_clicked.emit(self)
