## score_display.gd
## 计分面板 V5 - 显示等级信息、增强计分动画 (4K ×2)
extends Node2D

var hand_name_label: Label
var level_label: Label
var chips_label: Label
var mult_label: Label
var score_label: Label
var round_score_label: Label
var level_up_label: Label  ## 升级提示

var round_score: int = 0
var target_score: int = 300

## 数字滚动动画
var display_round_score: float = 0.0
var target_round_score: float = 0.0
var is_rolling: bool = false

## 升级提示动画
var level_up_timer: float = 0.0
var showing_level_up: bool = false

const PANEL_X: float = 160.0
const PANEL_Y: float = 300.0

func _ready() -> void:
	_setup_labels()
	_update_display_idle()

func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font: lbl.add_theme_font_override("font", font)

func _process(delta: float) -> void:
	## 分数滚动
	if is_rolling:
		var roll_speed = maxf(abs(target_round_score - display_round_score) * 5.0, 50.0)
		if display_round_score < target_round_score:
			display_round_score = minf(display_round_score + roll_speed * delta, target_round_score)
		else:
			display_round_score = target_round_score
			is_rolling = false

		round_score_label.text = str(int(display_round_score))

		var pulse = abs(sin(Time.get_ticks_msec() * 0.01))
		var rolling_color = Color(0.4, 0.7, 0.95).lerp(Color(0.8, 0.9, 1.0), pulse * 0.5)
		round_score_label.add_theme_color_override("font_color", rolling_color)

		if display_round_score >= target_score:
			round_score_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))

	## 升级提示淡出
	if showing_level_up:
		level_up_timer += delta
		if level_up_timer > 2.5:
			showing_level_up = false
			level_up_label.visible = false
		else:
			## 前0.5秒淡入，后面淡出
			var alpha: float
			if level_up_timer < 0.3:
				alpha = level_up_timer / 0.3
			elif level_up_timer > 1.8:
				alpha = 1.0 - (level_up_timer - 1.8) / 0.7
			else:
				alpha = 1.0
			level_up_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4, alpha))

func _setup_labels() -> void:
	## TARGET
	var target_title = Label.new()
	target_title.text = Loc.i().t("TARGET")
	target_title.position = Vector2(PANEL_X, PANEL_Y)
	target_title.add_theme_font_size_override("font_size", 36)
	target_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(target_title)
	add_child(target_title)

	var target_value = Label.new()
	target_value.name = "TargetValue"
	target_value.text = str(target_score)
	target_value.position = Vector2(PANEL_X, PANEL_Y + 56)
	target_value.add_theme_font_size_override("font_size", 80)
	target_value.add_theme_color_override("font_color", Color(0.95, 0.3, 0.3))
	_f(target_value)
	add_child(target_value)

	## ROUND SCORE
	var score_title = Label.new()
	score_title.text = Loc.i().t("ROUND SCORE")
	score_title.position = Vector2(PANEL_X, PANEL_Y + 180)
	score_title.add_theme_font_size_override("font_size", 36)
	score_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(score_title)
	add_child(score_title)

	round_score_label = Label.new()
	round_score_label.name = "RoundScore"
	round_score_label.text = "0"
	round_score_label.position = Vector2(PANEL_X, PANEL_Y + 236)
	round_score_label.add_theme_font_size_override("font_size", 80)
	round_score_label.add_theme_color_override("font_color", Color(0.4, 0.7, 0.95))
	_f(round_score_label)
	add_child(round_score_label)

	## 牌型名称
	hand_name_label = Label.new()
	hand_name_label.name = "HandName"
	hand_name_label.text = ""
	hand_name_label.position = Vector2(PANEL_X, PANEL_Y + 400)
	hand_name_label.add_theme_font_size_override("font_size", 56)
	hand_name_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_f(hand_name_label)
	add_child(hand_name_label)

	## 等级标签
	level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = ""
	level_label.position = Vector2(PANEL_X, PANEL_Y + 464)
	level_label.add_theme_font_size_override("font_size", 32)
	level_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.6))
	_f(level_label)
	add_child(level_label)

	## Chips
	chips_label = Label.new()
	chips_label.name = "Chips"
	chips_label.text = ""
	chips_label.position = Vector2(PANEL_X, PANEL_Y + 520)
	chips_label.add_theme_font_size_override("font_size", 44)
	chips_label.add_theme_color_override("font_color", Color(0.3, 0.6, 0.9))
	_f(chips_label)
	add_child(chips_label)

	## Mult
	mult_label = Label.new()
	mult_label.name = "Mult"
	mult_label.text = ""
	mult_label.position = Vector2(PANEL_X, PANEL_Y + 584)
	mult_label.add_theme_font_size_override("font_size", 44)
	mult_label.add_theme_color_override("font_color", Color(0.9, 0.35, 0.3))
	_f(mult_label)
	add_child(mult_label)

	## 得分公式
	score_label = Label.new()
	score_label.name = "Score"
	score_label.text = ""
	score_label.position = Vector2(PANEL_X, PANEL_Y + 664)
	score_label.add_theme_font_size_override("font_size", 60)
	score_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.9))
	_f(score_label)
	add_child(score_label)

	## 升级提示
	level_up_label = Label.new()
	level_up_label.name = "LevelUp"
	level_up_label.text = ""
	level_up_label.position = Vector2(PANEL_X, PANEL_Y + 750)
	level_up_label.add_theme_font_size_override("font_size", 40)
	level_up_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	level_up_label.visible = false
	_f(level_up_label)
	add_child(level_up_label)

func show_score(result: Dictionary) -> void:
	## 牌型名称
	hand_name_label.text = Loc.i().t(result["hand_name"])

	## 等级信息
	var level = result.get("level", 1)
	var level_bonus_chips = result.get("level_bonus_chips", 0)
	var level_bonus_mult = result.get("level_bonus_mult", 0)
	if level > 1:
		level_label.text = "Lv." + str(level) + " (+" + str(level_bonus_chips) + " " + Loc.i().t("Chips") + ", +" + str(level_bonus_mult) + " " + Loc.i().t("Mult") + ")"
	else:
		level_label.text = "Lv.1"

	## Chips 和 Mult
	chips_label.text = Loc.i().t("Chips") + ": " + str(result["total_chips"])
	mult_label.text = Loc.i().t("Mult") + ": ×" + str(result["total_mult"])

	## 得分公式
	var this_score: int = result["final_score"]
	score_label.text = str(result["total_chips"]) + " × " + str(result["total_mult"]) + " = " + str(this_score)

	## 滚动动画
	round_score += this_score
	target_round_score = float(round_score)
	is_rolling = true

func show_level_up(hand_name: String, new_level: int) -> void:
	level_up_label.text = "⬆ " + Loc.i().t(hand_name) + " → Lv." + str(new_level) + "!"
	level_up_label.visible = true
	showing_level_up = true
	level_up_timer = 0.0

func _update_display_idle() -> void:
	if hand_name_label:
		hand_name_label.text = Loc.i().t("Select cards and Play")

func set_target(new_target: int) -> void:
	target_score = new_target
	var target_node = get_node_or_null("TargetValue")
	if target_node:
		target_node.text = str(target_score)

func reset_round() -> void:
	round_score = 0
	display_round_score = 0.0
	target_round_score = 0.0
	is_rolling = false
	if round_score_label:
		round_score_label.text = "0"
		round_score_label.add_theme_color_override("font_color", Color(0.4, 0.7, 0.95))
	if hand_name_label:
		hand_name_label.text = Loc.i().t("Select cards and Play")
	if level_label:
		level_label.text = ""
	if chips_label:
		chips_label.text = ""
	if mult_label:
		mult_label.text = ""
	if score_label:
		score_label.text = ""
	if level_up_label:
		level_up_label.visible = false
