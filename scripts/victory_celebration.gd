## victory_celebration.gd
## 通关庆祝动画 V2 - 中文字体修复 + Congratulations 缩放 + 彩带金币掉落
extends Node2D

signal celebration_done()

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

var is_active: bool = false
var elapsed: float = 0.0
var particles: Array = []
var particle_layer: Node2D = null
var title_label: Label = null
var sub_label: Label = null
var emoji_label: Label = null
var click_label: Label = null

const CONFETTI_COLORS = [
	Color(0.95, 0.2, 0.3), Color(0.2, 0.6, 0.95), Color(0.95, 0.85, 0.2),
	Color(0.3, 0.9, 0.4), Color(0.8, 0.3, 0.9), Color(0.95, 0.5, 0.15),
	Color(0.2, 0.9, 0.85), Color(0.95, 0.4, 0.6),
]

## 字体辅助
func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font:
		lbl.add_theme_font_override("font", font)

func _ready() -> void:
	visible = false
	z_index = 100

func start_celebration() -> void:
	is_active = true
	visible = true
	elapsed = 0.0
	particles.clear()
	_build_ui()
	_spawn_confetti_wave(100)
	_spawn_coins(15)

func stop_celebration() -> void:
	is_active = false
	visible = false
	particles.clear()
	for child in get_children():
		child.queue_free()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	## 黑色半透明背景
	var bg = ColorRect.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	bg.color = Color(0.0, 0.0, 0.0, 0.75)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	## 粒子绘制层
	particle_layer = Node2D.new()
	particle_layer.name = "ParticleLayer"
	particle_layer.z_index = 1
	add_child(particle_layer)

	## 🏆 Emoji
	emoji_label = Label.new()
	emoji_label.text = "🏆"
	emoji_label.position = Vector2(0, CENTER_Y - 220)
	emoji_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.add_theme_font_size_override("font_size", 80)
	emoji_label.z_index = 2
	emoji_label.modulate.a = 0.0
	emoji_label.scale = Vector2(0.01, 0.01)
	emoji_label.pivot_offset = Vector2(SCREEN_W / 2, 50)
	add_child(emoji_label)

	## CONGRATULATIONS 标题
	title_label = Label.new()
	title_label.text = Loc.i().t("CONGRATULATIONS!")
	title_label.position = Vector2(0, CENTER_Y - 100)
	title_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.2))
	title_label.z_index = 2
	title_label.modulate.a = 0.0
	title_label.scale = Vector2(0.01, 0.01)
	title_label.pivot_offset = Vector2(SCREEN_W / 2, 40)
	_f(title_label)
	if Loc.i().current_language == "中文":
		title_label.position.x = 30
	add_child(title_label)

	## 副标题
	sub_label = Label.new()
	sub_label.text = Loc.i().t("All 8 Antes Cleared!")
	sub_label.position = Vector2(0, CENTER_Y + 20)
	sub_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_font_size_override("font_size", 32)
	sub_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	sub_label.z_index = 2
	sub_label.modulate.a = 0.0
	_f(sub_label)
	if Loc.i().current_language == "中文":
		sub_label.position.x = 10
	add_child(sub_label)

	## 点击继续提示
	click_label = Label.new()
	click_label.text = Loc.i().t("Click anywhere to continue...")
	click_label.position = Vector2(0, CENTER_Y + 200)
	click_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	click_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	click_label.add_theme_font_size_override("font_size", 20)
	click_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	click_label.z_index = 2
	click_label.modulate.a = 0.0
	_f(click_label)
	add_child(click_label)

func _process(delta: float) -> void:
	if not is_active:
		return
	elapsed += delta

	## === 标题缩放动画 ===
	## Emoji: 0-0.6秒 弹入
	if elapsed < 0.6:
		var t = elapsed / 0.6
		var ease_t = 1.0 - pow(1.0 - t, 4.0)  ## ease out quart
		emoji_label.scale = Vector2(ease_t, ease_t)
		emoji_label.modulate.a = clampf(t * 2.5, 0.0, 1.0)
	elif elapsed < 0.9:
		## 过冲回弹
		var t = (elapsed - 0.6) / 0.3
		var bounce = 1.0 + sin(t * PI) * 0.12
		emoji_label.scale = Vector2(bounce, bounce)
		emoji_label.modulate.a = 1.0
	else:
		emoji_label.scale = Vector2(1.0, 1.0)
		emoji_label.modulate.a = 1.0

	## Title: 0.3-1.0秒 弹入
	if elapsed > 0.3:
		var te = elapsed - 0.3
		if te < 0.7:
			var t = te / 0.7
			var ease_t = 1.0 - pow(1.0 - t, 4.0)
			title_label.scale = Vector2(ease_t, ease_t)
			title_label.modulate.a = clampf(t * 2.0, 0.0, 1.0)
		elif te < 1.1:
			var t = (te - 0.7) / 0.4
			var bounce = 1.0 + sin(t * PI) * 0.08
			title_label.scale = Vector2(bounce, bounce)
			title_label.modulate.a = 1.0
		else:
			title_label.scale = Vector2(1.0, 1.0)
			title_label.modulate.a = 1.0

			## 金色脉冲
			var pulse = 0.9 + sin(elapsed * 2.0) * 0.1
			title_label.add_theme_color_override("font_color",
				Color(0.95 * pulse, 0.85 * pulse, 0.2))

	## Sub title: 1.2秒淡入
	if elapsed > 1.2:
		sub_label.modulate.a = clampf((elapsed - 1.2) * 2.0, 0.0, 1.0)

	## Click hint: 3秒后闪烁
	if elapsed > 3.0:
		click_label.modulate.a = 0.4 + sin(elapsed * 2.5) * 0.4

	## === 持续生成粒子 ===
	if elapsed < 6.0:
		if randi() % 2 == 0:
			_spawn_confetti_wave(2)
		if randi() % 8 == 0:
			_spawn_coins(2)

	## === 更新粒子 ===
	var to_remove: Array = []
	for i in range(particles.size()):
		var p = particles[i]
		p["life"] -= delta
		p["pos"] += p["vel"] * delta
		p["vel"].y += p.get("gravity", 100.0) * delta
		if p.get("is_confetti", false):
			p["pos"].x += sin(elapsed * 3.0 + p.get("phase", 0.0)) * 25.0 * delta
			p["rot"] = p.get("rot", 0.0) + p.get("rot_speed", 0.0) * delta
		if p["life"] <= 0 or p["pos"].y > SCREEN_H + 50:
			to_remove.append(i)
	to_remove.reverse()
	for idx in to_remove:
		particles.remove_at(idx)

	queue_redraw()

func _draw() -> void:
	if not is_active:
		return
	for p in particles:
		var alpha = clampf(p["life"] / p["max_life"], 0.0, 1.0)
		var c = p["color"]
		c.a = alpha
		if p.get("is_coin", false):
			draw_circle(p["pos"], p["size"], c)
			draw_circle(p["pos"] + Vector2(-1.5, -1.5), p["size"] * 0.35, Color(1, 1, 0.85, alpha * 0.5))
		elif p.get("is_confetti", false):
			var s = p["size"]
			var rot = p.get("rot", 0.0)
			var sx = (abs(cos(rot)) * 1.8 + 0.5) * s
			var sy = (abs(sin(rot)) * 0.8 + 0.5) * s
			draw_rect(Rect2(p["pos"].x - sx/2, p["pos"].y - sy/2, sx, sy), c)
		else:
			var s = p["size"]
			draw_rect(Rect2(p["pos"].x - s/2, p["pos"].y - s/2, s, s), c)

func _spawn_confetti_wave(count: int) -> void:
	for i in range(count):
		particles.append({
			"pos": Vector2(randf_range(-50, SCREEN_W + 50), randf_range(-200, -10)),
			"vel": Vector2(randf_range(-50, 50), randf_range(60, 180)),
			"color": CONFETTI_COLORS[randi() % CONFETTI_COLORS.size()],
			"life": randf_range(5.0, 9.0), "max_life": 9.0,
			"size": randf_range(4.0, 10.0), "gravity": randf_range(30.0, 80.0),
			"is_confetti": true, "phase": randf() * TAU,
			"rot": randf() * TAU, "rot_speed": randf_range(-4.0, 4.0),
		})

func _spawn_coins(count: int) -> void:
	for i in range(count):
		particles.append({
			"pos": Vector2(randf_range(200, SCREEN_W - 200), randf_range(-150, -20)),
			"vel": Vector2(randf_range(-20, 20), randf_range(50, 120)),
			"color": Color(0.95, 0.8, 0.2),
			"life": randf_range(5.0, 8.0), "max_life": 8.0,
			"size": randf_range(6.0, 14.0), "gravity": randf_range(60.0, 120.0),
			"is_coin": true,
		})

func _unhandled_input(event: InputEvent) -> void:
	if not is_active: return
	if elapsed > 2.0 and event is InputEventMouseButton and event.pressed:
		_finish()

func _finish() -> void:
	is_active = false
	visible = false
	particles.clear()
	celebration_done.emit()
