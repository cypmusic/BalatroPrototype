## title_screen.gd
## 开场菜单 V2 - 全部使用节点（Label/ColorRect），不用 _draw()
extends Node2D

signal start_game()
signal open_title_menu()  ## 点击 Start Game 后打开标题菜单

const SCREEN_W: float = 3840.0
const SCREEN_H: float = 2160.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

var elapsed: float = 0.0
var is_active: bool = true

## 飘落花色
var suit_nodes: Array = []
const SUIT_SYMBOLS = ["♠", "♥", "♦", "♣"]
const SUIT_COLORS_MAP = {
	"♠": Color(0.55, 0.6, 0.75, 0.4),
	"♥": Color(0.95, 0.3, 0.35, 0.4),
	"♦": Color(0.95, 0.7, 0.25, 0.4),
	"♣": Color(0.35, 0.8, 0.5, 0.4),
}

## 扇形牌
var fan_card_nodes: Array = []
const FAN_CARD_COUNT: int = 5
const FAN_CARD_W: float = 200.0
const FAN_CARD_H: float = 280.0
const FAN_SPREAD: float = 12.0
const FAN_CENTER_Y: float = CENTER_Y + 40.0

## UI
var title_label: Label = null
var sub_label: Label = null
var start_button: Button = null
var version_label: Label = null
var suit_container: Node2D = null
var card_container: Node2D = null

## 过渡
var is_transitioning: bool = false
var transition_timer: float = 0.0
const TRANSITION_DURATION: float = 0.8

## 背景音乐
var bgm_player: AudioStreamPlayer = null

func _ready() -> void:
	z_index = 200
	_build_ui()
	_build_fan_cards()
	_spawn_initial_suits()
	_start_bgm()

func _start_bgm() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGM"
	var stream = load("res://audio/title_bgm.mp3")
	if stream:
		## 代码设置循环（无需在 Import 面板操作）
		if stream is AudioStreamMP3:
			stream.loop = true
		bgm_player.stream = stream
		bgm_player.volume_db = -5.0
		bgm_player.bus = "Master"
		add_child(bgm_player)
		bgm_player.play()

func stop_bgm() -> void:
	if bgm_player and bgm_player.playing:
		bgm_player.stop()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	bg.color = Color(0.02, 0.05, 0.03)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	suit_container = Node2D.new()
	suit_container.name = "SuitContainer"
	suit_container.z_index = 0
	add_child(suit_container)

	card_container = Node2D.new()
	card_container.name = "CardContainer"
	card_container.z_index = 1
	add_child(card_container)

	title_label = Label.new()
	title_label.text = "BALATRO"
	title_label.position = Vector2(0, 240)
	title_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 192)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.3))
	title_label.z_index = 5
	title_label.modulate.a = 0.0
	add_child(title_label)

	sub_label = Label.new()
	sub_label.text = "P R O T O T Y P E"
	sub_label.position = Vector2(0, 470)
	sub_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_font_size_override("font_size", 40)
	sub_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.55))
	sub_label.z_index = 5
	sub_label.modulate.a = 0.0
	add_child(sub_label)

	start_button = Button.new()
	start_button.text = "    ♠  Start Game  ♠    "
	start_button.custom_minimum_size = Vector2(640, 120)
	start_button.position = Vector2(CENTER_X - 320, CENTER_Y + 560)
	start_button.add_theme_font_size_override("font_size", 56)
	start_button.z_index = 10
	start_button.modulate.a = 0.0
	start_button.pressed.connect(_on_start_pressed)
	add_child(start_button)

	version_label = Label.new()
	version_label.text = GameConfig.VERSION_LABEL
	version_label.position = Vector2(0, SCREEN_H - 100)
	version_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.add_theme_font_size_override("font_size", 28)
	version_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.3))
	version_label.z_index = 5
	version_label.modulate.a = 0.0
	add_child(version_label)

## ========== 扇形牌（5张真实扑克牌）==========

func _build_fan_cards() -> void:
	var ranks = ["A", "K", "Q", "J", "10"]
	var suits = ["♠", "♥", "♦", "♣", "♠"]
	var suit_colors = [
		Color(0.12, 0.12, 0.15),
		Color(0.85, 0.15, 0.15),
		Color(0.85, 0.15, 0.15),
		Color(0.12, 0.12, 0.15),
		Color(0.12, 0.12, 0.15),
	]

	for i in range(FAN_CARD_COUNT):
		var target_angle = (i - (FAN_CARD_COUNT - 1) / 2.0) * FAN_SPREAD

		## 旋转支点（牌底部中心）
		var pivot = Node2D.new()
		pivot.position = Vector2(CENTER_X, FAN_CENTER_Y + FAN_CARD_H * 0.4)
		pivot.z_index = i
		card_container.add_child(pivot)

		## 牌面背景
		var card_bg = ColorRect.new()
		card_bg.position = Vector2(-FAN_CARD_W / 2, -FAN_CARD_H)
		card_bg.size = Vector2(FAN_CARD_W, FAN_CARD_H)
		card_bg.color = Color(0.92, 0.9, 0.85)
		card_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pivot.add_child(card_bg)

		## 内边框
		var inner = ColorRect.new()
		inner.position = Vector2(-FAN_CARD_W / 2 + 4, -FAN_CARD_H + 4)
		inner.size = Vector2(FAN_CARD_W - 8, FAN_CARD_H - 8)
		inner.color = Color(0.97, 0.96, 0.93)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pivot.add_child(inner)

		## 中央大花色
		var center_suit = Label.new()
		center_suit.text = suits[i]
		center_suit.position = Vector2(-FAN_CARD_W / 2, -FAN_CARD_H + 76)
		center_suit.custom_minimum_size = Vector2(FAN_CARD_W, 0)
		center_suit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		center_suit.add_theme_font_size_override("font_size", 88)
		center_suit.add_theme_color_override("font_color", suit_colors[i])
		pivot.add_child(center_suit)

		## 左上 Rank
		var rank_lbl = Label.new()
		rank_lbl.text = ranks[i]
		rank_lbl.position = Vector2(-FAN_CARD_W / 2 + 16, -FAN_CARD_H + 10)
		rank_lbl.add_theme_font_size_override("font_size", 32)
		rank_lbl.add_theme_color_override("font_color", suit_colors[i])
		pivot.add_child(rank_lbl)

		## 左上小花色
		var small_suit = Label.new()
		small_suit.text = suits[i]
		small_suit.position = Vector2(-FAN_CARD_W / 2 + 16, -FAN_CARD_H + 44)
		small_suit.add_theme_font_size_override("font_size", 24)
		small_suit.add_theme_color_override("font_color", suit_colors[i])
		pivot.add_child(small_suit)

		## 右下 Rank（倒转）
		var rank_lbl2 = Label.new()
		rank_lbl2.text = ranks[i]
		rank_lbl2.position = Vector2(FAN_CARD_W / 2 - 48, -40)
		rank_lbl2.add_theme_font_size_override("font_size", 32)
		rank_lbl2.add_theme_color_override("font_color", suit_colors[i])
		pivot.add_child(rank_lbl2)

		## 初始隐藏
		pivot.modulate.a = 0.0
		pivot.rotation = 0.0

		fan_card_nodes.append({
			"node": pivot,
			"target_angle": deg_to_rad(target_angle),
			"delay": 1.2 + i * 0.12,
			"start_y": FAN_CENTER_Y + FAN_CARD_H * 0.4 + 500.0,
			"end_y": FAN_CENTER_Y + FAN_CARD_H * 0.4,
		})

## ========== 飘落花色 ==========

func _spawn_suit_label(scatter: bool = false) -> void:
	var idx = randi() % 4
	var symbol = SUIT_SYMBOLS[idx]
	var lbl = Label.new()
	lbl.text = symbol
	var font_size = randi_range(44, 100)
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", SUIT_COLORS_MAP[symbol])
	lbl.position = Vector2(
		randf_range(60, SCREEN_W - 160),
		randf_range(-200, SCREEN_H - 200) if scatter else randf_range(-240, -60)
	)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	suit_container.add_child(lbl)

	suit_nodes.append({
		"node": lbl,
		"vel": Vector2(randf_range(-10, 10), randf_range(30, 65)),
		"phase": randf() * TAU,
		"rot_speed": randf_range(-0.3, 0.3),
	})

func _spawn_initial_suits() -> void:
	for i in range(30):
		_spawn_suit_label(true)

## ========== 每帧更新 ==========

func _process(delta: float) -> void:
	if not is_active and not is_transitioning:
		return
	elapsed += delta

	## 过渡
	if is_transitioning:
		transition_timer += delta
		var t = clampf(transition_timer / TRANSITION_DURATION, 0.0, 1.0)
		var ease_t = t * t
		modulate.a = 1.0 - ease_t
		position.y = -ease_t * 200.0
		## 音乐淡出
		if bgm_player and bgm_player.playing:
			bgm_player.volume_db = lerpf(-5.0, -40.0, ease_t)
		if t >= 1.0:
			is_transitioning = false
			is_active = false
			visible = false
			modulate.a = 1.0
			position.y = 0.0
			stop_bgm()
			start_game.emit()
		return

	## 标题滑入
	if elapsed < 0.8:
		var t = elapsed / 0.8
		var ease_t = 1.0 - pow(1.0 - t, 3.0)
		title_label.modulate.a = clampf(t * 1.5, 0.0, 1.0)
		title_label.position.y = lerpf(80, 240, ease_t)
	else:
		title_label.modulate.a = 1.0
		title_label.position.y = 240
		var pulse = 0.92 + sin(elapsed * 1.5) * 0.08
		title_label.add_theme_color_override("font_color",
			Color(0.95 * pulse, 0.85 * pulse, 0.3 * pulse))

	## 副标题淡入
	if elapsed > 0.6:
		sub_label.modulate.a = clampf((elapsed - 0.6) * 1.5, 0.0, 1.0)

	## 按钮呼吸
	if elapsed > 2.0:
		start_button.modulate.a = clampf((elapsed - 2.0) * 1.2, 0.0, 1.0)
		start_button.position.y = CENTER_Y + 560 + sin(elapsed * 2.0) * 8.0

	## 版本号
	if elapsed > 2.5:
		version_label.modulate.a = clampf((elapsed - 2.5), 0.0, 0.5)

	## 扇形牌展开
	for card in fan_card_nodes:
		var node: Node2D = card["node"]
		if elapsed > card["delay"]:
			var ct = clampf((elapsed - card["delay"]) / 0.6, 0.0, 1.0)
			var ease_ct = 1.0 - pow(1.0 - ct, 3.0)
			node.modulate.a = clampf(ct * 2.5, 0.0, 1.0)
			node.rotation = lerpf(0.0, card["target_angle"], ease_ct)
			node.position.y = lerpf(card["start_y"], card["end_y"], ease_ct)

	## 持续生成花色
	if randi() % 5 == 0:
		_spawn_suit_label()

	## 更新花色位置
	var to_remove: Array = []
	for i in range(suit_nodes.size()):
		var data = suit_nodes[i]
		var node: Label = data["node"]
		if not is_instance_valid(node):
			to_remove.append(i)
			continue
		node.position += data["vel"] * delta
		node.position.x += sin(elapsed * 0.7 + data["phase"]) * 15.0 * delta
		node.rotation += data["rot_speed"] * delta
		if node.position.y > SCREEN_H + 50:
			to_remove.append(i)
			node.queue_free()
	to_remove.reverse()
	for idx in to_remove:
		suit_nodes.remove_at(idx)

func _on_start_pressed() -> void:
	if is_transitioning: return
	## 不直接开始游戏，而是打开标题菜单
	start_button.modulate.a = 0.0
	open_title_menu.emit()

## 被 main.gd 调用，真正开始游戏时的过渡动画
func transition_out() -> void:
	is_transitioning = true
	transition_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or is_transitioning: return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			if elapsed > 2.0:
				_on_start_pressed()
