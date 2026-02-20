## vortex_transition.gd
## 黑洞漩涡过渡动画 - 吸收屏幕元素 → 黑屏 → 像素渐入
extends Node2D

signal transition_midpoint()  ## 黑屏时触发（此时切换场景内容）
signal transition_complete()  ## 完全结束

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

## 阶段
enum Phase { IDLE, VORTEX_IN, BLACK_HOLD, PIXEL_OUT }
var phase: int = Phase.IDLE
var timer: float = 0.0

## 时间参数
const VORTEX_DURATION: float = 1.2    ## 漩涡吸入时间
const BLACK_HOLD_DURATION: float = 0.3  ## 黑屏停留
const PIXEL_OUT_DURATION: float = 0.8   ## 像素渐出时间

## 漩涡粒子
var particles: Array = []
const PARTICLE_COUNT: int = 120
const DEBRIS_COUNT: int = 60

## 黑屏遮罩
var black_overlay: ColorRect = null
var vortex_container: Node2D = null

## 像素化网格
var pixel_grid: Array = []
const GRID_COLS: int = 32
const GRID_ROWS: int = 20

func _ready() -> void:
	z_index = 500
	visible = false

func start_transition() -> void:
	visible = true
	phase = Phase.VORTEX_IN
	timer = 0.0
	_create_vortex()

func _create_vortex() -> void:
	## 清理
	for child in get_children():
		child.queue_free()
	particles.clear()
	pixel_grid.clear()

	vortex_container = Node2D.new()
	vortex_container.name = "VortexContainer"
	add_child(vortex_container)

	## 黑屏遮罩（初始透明）
	black_overlay = ColorRect.new()
	black_overlay.position = Vector2(0, 0)
	black_overlay.size = Vector2(SCREEN_W, SCREEN_H)
	black_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_overlay.z_index = 1
	add_child(black_overlay)

	## 生成漩涡粒子 - 从屏幕各处开始
	for i in range(PARTICLE_COUNT):
		var p = _create_particle()
		particles.append(p)

	## 生成碎片粒子 - 更小，模拟被撕裂的元素
	for i in range(DEBRIS_COUNT):
		var d = _create_debris()
		particles.append(d)

func _create_particle() -> Dictionary:
	## 随机分布在屏幕边缘和中间区域
	var angle = randf() * TAU
	var dist = randf_range(200.0, 900.0)
	var start_pos = Vector2(CENTER_X + cos(angle) * dist, CENTER_Y + sin(angle) * dist)

	## 花色符号或方块
	var symbols = ["♠", "♥", "♦", "♣", "■", "▪", "●", "◆", "★"]
	var colors = [
		Color(0.55, 0.6, 0.75, 0.9),   ## 蓝灰
		Color(0.95, 0.3, 0.35, 0.9),    ## 红
		Color(0.95, 0.7, 0.25, 0.9),    ## 金
		Color(0.35, 0.8, 0.5, 0.9),     ## 绿
		Color(0.7, 0.4, 0.8, 0.9),      ## 紫
		Color(0.3, 0.85, 0.9, 0.9),     ## 青
	]

	var lbl = Label.new()
	lbl.text = symbols[randi() % symbols.size()]
	lbl.position = start_pos
	lbl.add_theme_font_size_override("font_size", randi_range(14, 42))
	lbl.add_theme_color_override("font_color", colors[randi() % colors.size()])
	lbl.pivot_offset = Vector2(10, 10)
	vortex_container.add_child(lbl)

	return {
		"node": lbl,
		"start_pos": start_pos,
		"angle_offset": randf() * TAU,
		"orbit_speed": randf_range(3.0, 8.0),
		"pull_speed": randf_range(0.3, 1.0),
		"spin_speed": randf_range(-5.0, 5.0),
		"size": lbl.get_theme_font_size("font_size"),
	}

func _create_debris() -> Dictionary:
	var angle = randf() * TAU
	var dist = randf_range(100.0, 700.0)
	var start_pos = Vector2(CENTER_X + cos(angle) * dist, CENTER_Y + sin(angle) * dist)

	var rect = ColorRect.new()
	var s = randf_range(2, 8)
	rect.size = Vector2(s, s)
	rect.position = start_pos
	var brightness = randf_range(0.3, 0.9)
	rect.color = Color(brightness, brightness * 0.8, brightness * 0.6, 0.8)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vortex_container.add_child(rect)

	return {
		"node": rect,
		"start_pos": start_pos,
		"angle_offset": randf() * TAU,
		"orbit_speed": randf_range(4.0, 12.0),
		"pull_speed": randf_range(0.4, 1.2),
		"spin_speed": 0.0,
		"size": s,
	}

func _process(delta: float) -> void:
	if phase == Phase.IDLE:
		return

	timer += delta

	match phase:
		Phase.VORTEX_IN:
			_process_vortex(delta)
		Phase.BLACK_HOLD:
			_process_black_hold(delta)
		Phase.PIXEL_OUT:
			_process_pixel_out(delta)

func _process_vortex(delta: float) -> void:
	var t = clampf(timer / VORTEX_DURATION, 0.0, 1.0)
	## 使用 ease-in 加速吸入
	var pull_progress = t * t * t

	## 黑屏渐入（后半段加速）
	var black_alpha = clampf((t - 0.3) / 0.7, 0.0, 1.0)
	black_alpha = black_alpha * black_alpha
	black_overlay.color.a = black_alpha

	## 更新每个粒子
	for p in particles:
		if not is_instance_valid(p["node"]):
			continue
		var node = p["node"]

		## 计算当前到中心的距离
		var to_center = Vector2(CENTER_X, CENTER_Y) - p["start_pos"]
		var current_dist = to_center.length() * (1.0 - pull_progress * p["pull_speed"])
		current_dist = maxf(current_dist, 0.0)

		## 螺旋轨道
		var orbit_angle = p["angle_offset"] + timer * p["orbit_speed"] * (1.0 + pull_progress * 3.0)
		var pos = Vector2(CENTER_X + cos(orbit_angle) * current_dist,
						  CENTER_Y + sin(orbit_angle) * current_dist)
		node.position = pos

		## 旋转
		if node is Label:
			node.rotation = timer * p["spin_speed"] * (1.0 + pull_progress * 2.0)

		## 缩放（越近越小）
		var scale_factor = clampf(current_dist / 300.0, 0.05, 1.5)
		node.scale = Vector2(scale_factor, scale_factor)

		## 透明度
		var alpha = clampf(1.0 - pull_progress * 0.8, 0.0, 1.0)
		node.modulate.a = alpha

	if t >= 1.0:
		## 清除漩涡粒子
		if vortex_container:
			vortex_container.queue_free()
			vortex_container = null
		particles.clear()
		black_overlay.color.a = 1.0
		phase = Phase.BLACK_HOLD
		timer = 0.0
		transition_midpoint.emit()

func _process_black_hold(_delta: float) -> void:
	if timer >= BLACK_HOLD_DURATION:
		phase = Phase.PIXEL_OUT
		timer = 0.0
		_create_pixel_grid()

func _create_pixel_grid() -> void:
	## 创建像素方格遮罩 - 将逐个消失露出下方画面
	var cell_w = SCREEN_W / GRID_COLS
	var cell_h = SCREEN_H / GRID_ROWS

	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var rect = ColorRect.new()
			rect.position = Vector2(col * cell_w, row * cell_h)
			rect.size = Vector2(cell_w + 1, cell_h + 1)  ## +1 防间隙
			rect.color = Color(0.0, 0.0, 0.0, 1.0)
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect.z_index = 2
			add_child(rect)

			## 从中心向外扩散消失 - 计算到中心的距离
			var cx = (col + 0.5) / GRID_COLS - 0.5
			var cy = (row + 0.5) / GRID_ROWS - 0.5
			var dist = sqrt(cx * cx + cy * cy) / 0.707  ## 归一化到 0~1

			## 加入随机偏移增加有机感
			var delay = dist * 0.7 + randf() * 0.15

			pixel_grid.append({
				"node": rect,
				"delay": delay,
				"fade_dur": 0.2 + randf() * 0.15,
			})

func _process_pixel_out(_delta: float) -> void:
	var t = timer
	var all_done = true

	## 先淡去黑色遮罩
	if black_overlay:
		black_overlay.color.a = clampf(1.0 - t * 3.0, 0.0, 1.0)

	## 像素方格逐个消失
	for cell in pixel_grid:
		if not is_instance_valid(cell["node"]):
			continue
		var ct = t - cell["delay"]
		if ct < 0:
			all_done = false
			continue
		var fade_t = clampf(ct / cell["fade_dur"], 0.0, 1.0)
		cell["node"].color.a = 1.0 - fade_t
		if fade_t < 1.0:
			all_done = false
		else:
			cell["node"].queue_free()

	if all_done or t > PIXEL_OUT_DURATION + 0.5:
		_cleanup()
		phase = Phase.IDLE
		visible = false
		transition_complete.emit()

func _cleanup() -> void:
	for cell in pixel_grid:
		if is_instance_valid(cell["node"]):
			cell["node"].queue_free()
	pixel_grid.clear()
	if black_overlay and is_instance_valid(black_overlay):
		black_overlay.queue_free()
		black_overlay = null
	if vortex_container and is_instance_valid(vortex_container):
		vortex_container.queue_free()
		vortex_container = null
