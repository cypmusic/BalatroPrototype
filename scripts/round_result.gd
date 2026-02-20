## round_result.gd
## 回合结果界面 - 胜利/失败遮罩
extends Node2D

signal go_to_shop()
signal restart_game()

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0

var is_victory: bool = false
var score: int = 0
var target: int = 0
var income: int = 0
var blind_name: String = ""

func _t(key: String) -> String: return Loc.i().t(key)
func _af(lbl: Label, s: int = -1) -> void:
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Loc.i().apply_font_to_label(lbl, s)
func _afb(btn: Button, s: int = -1) -> void: Loc.i().apply_font_to_button(btn, s)

func _ready() -> void:
	visible = false

func show_victory(round_score: int, target_score: int, earned_income: int, current_blind: String) -> void:
	is_victory = true
	score = round_score
	target = target_score
	income = earned_income
	blind_name = current_blind
	visible = true
	_build_ui()

func show_defeat(round_score: int, target_score: int, current_blind: String) -> void:
	is_victory = false
	score = round_score
	target = target_score
	income = 0
	blind_name = current_blind
	visible = true
	_build_ui()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	## 全屏背景
	var bg = ColorRect.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	bg.color = Color(0.03, 0.06, 0.04, 0.95)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	if is_victory:
		_build_victory()
	else:
		_build_defeat()

func _build_victory() -> void:
	var title = Label.new()
	title.text = _t("BLIND DEFEATED!")
	title.position = Vector2(0, 200)
	title.custom_minimum_size = Vector2(SCREEN_W, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.3, 0.95, 0.4))
	_af(title, 56); add_child(title)

	var blind_lbl = Label.new()
	blind_lbl.text = _t(blind_name)
	blind_lbl.position = Vector2(0, 275)
	blind_lbl.custom_minimum_size = Vector2(SCREEN_W, 0)
	blind_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	blind_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	_af(blind_lbl, 24); add_child(blind_lbl)

	var score_lbl = Label.new()
	score_lbl.text = str(score) + " / " + str(target)
	score_lbl.position = Vector2(0, 340)
	score_lbl.custom_minimum_size = Vector2(SCREEN_W, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.95))
	_af(score_lbl, 40); add_child(score_lbl)

	var income_title = Label.new()
	income_title.text = _t("EARNINGS")
	income_title.position = Vector2(0, 430)
	income_title.custom_minimum_size = Vector2(SCREEN_W, 0)
	income_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	income_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_af(income_title, 22); add_child(income_title)

	var income_lbl = Label.new()
	income_lbl.text = "+ $" + str(income)
	income_lbl.position = Vector2(0, 465)
	income_lbl.custom_minimum_size = Vector2(SCREEN_W, 0)
	income_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	income_lbl.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	_af(income_lbl, 48); add_child(income_lbl)

	var shop_btn = Button.new()
	shop_btn.text = _t("Go to Shop")
	shop_btn.custom_minimum_size = Vector2(220, 50)
	shop_btn.position = Vector2(CENTER_X - 110, 580)
	shop_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_afb(shop_btn, 28)
	shop_btn.pressed.connect(_on_go_to_shop)
	add_child(shop_btn)

func _build_defeat() -> void:
	var title = Label.new()
	title.text = _t("GAME OVER")
	title.position = Vector2(0, 250)
	title.custom_minimum_size = Vector2(SCREEN_W, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.9, 0.25, 0.25))
	_af(title, 56); add_child(title)

	var blind_lbl = Label.new()
	blind_lbl.text = _t(blind_name)
	blind_lbl.position = Vector2(0, 325)
	blind_lbl.custom_minimum_size = Vector2(SCREEN_W, 0)
	blind_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	blind_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	_af(blind_lbl, 24); add_child(blind_lbl)

	var score_lbl = Label.new()
	score_lbl.text = str(score) + " / " + str(target)
	score_lbl.position = Vector2(0, 390)
	score_lbl.custom_minimum_size = Vector2(SCREEN_W, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))
	_af(score_lbl, 40); add_child(score_lbl)

	var restart_btn = Button.new()
	restart_btn.text = _t("Try Again")
	restart_btn.custom_minimum_size = Vector2(220, 50)
	restart_btn.position = Vector2(CENTER_X - 110, 500)
	restart_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_afb(restart_btn, 28)
	restart_btn.pressed.connect(_on_restart)
	add_child(restart_btn)

func _on_go_to_shop() -> void:
	visible = false
	go_to_shop.emit()

func _on_restart() -> void:
	visible = false
	restart_game.emit()
