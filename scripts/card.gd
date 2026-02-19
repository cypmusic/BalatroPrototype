## card.gd
## 单张卡牌 V6.2 - 新增退场动画（飞向弃牌堆）
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
var is_exiting: bool = false  ## 退场动画中

## 卡牌视觉参数
const CARD_WIDTH: float = 140.0
const CARD_HEIGHT: float = 195.0
const HOVER_OFFSET: float = -35.0
const SELECT_OFFSET: float = -35.0

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

## 退场动画：飞向目标位置（弃牌堆），完成后发信号
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
		## ease-in 缓动（加速飞走）
		var t = exit_progress * exit_progress
		position = exit_start_pos.lerp(exit_target_pos, t)
		## 缩小效果
		var s = 1.0 - exit_progress * 0.4
		scale = Vector2(s, s)
		## 逐渐透明
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

func _draw() -> void:
	if card_data == null:
		return

	var rect = Rect2(-CARD_WIDTH / 2, -CARD_HEIGHT / 2, CARD_WIDTH, CARD_HEIGHT)

	## 光效
	if score_glow_intensity > 0.0:
		_draw_glow(rect, Color(1.0, 0.85, 0.3, score_glow_intensity * 0.6), 12.0)
	elif hover_glow > 0.05:
		_draw_glow(rect, Color(0.5, 0.7, 1.0, hover_glow * 0.3), 8.0)

	## 阴影
	var shadow_offset = Vector2(8, 8) if is_dragging else Vector2(4, 4)
	var shadow_alpha = 0.4 if is_dragging else 0.25
	draw_rect(Rect2(rect.position + shadow_offset, rect.size), Color(0, 0, 0, shadow_alpha))

	## 底色
	if is_scoring and score_glow_intensity > 0.3:
		var glow_color = Color(1.0, 0.97, 0.85).lerp(Color(1.0, 0.9, 0.6), score_glow_intensity)
		draw_rect(rect, glow_color)
	elif is_selected:
		_draw_gradient_rect(rect, Color(0.92, 0.95, 1.0), Color(0.85, 0.9, 0.98))
	else:
		_draw_gradient_rect(rect, Color(1.0, 1.0, 1.0), Color(0.95, 0.95, 0.93))

	## 边框
	var border_color: Color
	var border_width: float
	if is_scoring and score_glow_intensity > 0.3:
		border_color = Color(0.95, 0.75, 0.2)
		border_width = 4.0
	elif is_selected:
		border_color = Color(0.3, 0.5, 0.9)
		border_width = 3.5
	elif is_dragging:
		border_color = Color(0.5, 0.7, 1.0)
		border_width = 3.0
	else:
		border_color = Color(0.55, 0.55, 0.55)
		border_width = 1.5
	draw_rect(rect, border_color, false, border_width)

	## 花色和数字
	var suit_color = card_data.get_suit_color()
	if is_scoring and score_glow_intensity > 0.5:
		suit_color = suit_color.lerp(Color(0.8, 0.6, 0.1), score_glow_intensity * 0.5)
	var rank_text = card_data.get_rank_text()
	var suit_symbol = card_data.get_suit_symbol()

	draw_string(ThemeDB.fallback_font, Vector2(-CARD_WIDTH / 2 + 12, -CARD_HEIGHT / 2 + 32),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, suit_color)
	draw_string(ThemeDB.fallback_font, Vector2(-CARD_WIDTH / 2 + 12, -CARD_HEIGHT / 2 + 56),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, suit_color)
	draw_string(ThemeDB.fallback_font, Vector2(-18, 15),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 50, suit_color)
	draw_string(ThemeDB.fallback_font, Vector2(CARD_WIDTH / 2 - 35, CARD_HEIGHT / 2 - 12),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, suit_color)
	draw_string(ThemeDB.fallback_font, Vector2(CARD_WIDTH / 2 - 32, CARD_HEIGHT / 2 - 32),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, suit_color)

func _draw_glow(rect: Rect2, color: Color, spread: float) -> void:
	for i in range(3):
		var s = spread * (i + 1) / 3.0
		var alpha = color.a * (1.0 - float(i) / 3.0)
		draw_rect(Rect2(rect.position - Vector2(s, s), rect.size + Vector2(s * 2, s * 2)),
			Color(color.r, color.g, color.b, alpha))

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var steps = 8
	var step_height = rect.size.y / steps
	for i in range(steps):
		var t = float(i) / (steps - 1)
		draw_rect(Rect2(rect.position.x, rect.position.y + i * step_height, rect.size.x, step_height + 1),
			top_color.lerp(bottom_color, t))

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

## 全局输入监听：无论鼠标在哪里松开，都能结束拖拽
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_mouse_down or is_dragging:
			_handle_mouse_release()

func _handle_mouse_release() -> void:
	if not is_mouse_down and not is_dragging:
		return
	if not drag_confirmed:
		## 鼠标没离开过卡牌 = 点击
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
