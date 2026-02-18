## hand_preview.gd
## 手牌预览提示 V5 - 显示等级信息
extends Node2D

var type_label: Label
var level_info_label: Label
var preview_chips: Label
var preview_mult: Label
var preview_score: Label
var bg_panel: ColorRect

const PANEL_WIDTH: float = 300.0
const PANEL_HEIGHT: float = 160.0

func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font: lbl.add_theme_font_override("font", font)

func _ready() -> void:
	_setup_panel()

func _setup_panel() -> void:
	## 半透明背景
	bg_panel = ColorRect.new()
	bg_panel.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2)
	bg_panel.size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	bg_panel.color = Color(0.05, 0.1, 0.08, 0.88)
	add_child(bg_panel)

	## 牌型名称
	type_label = Label.new()
	type_label.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 8)
	type_label.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_font_size_override("font_size", 26)
	type_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_f(type_label)
	add_child(type_label)

	## 等级信息
	level_info_label = Label.new()
	level_info_label.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 42)
	level_info_label.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	level_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_info_label.add_theme_font_size_override("font_size", 14)
	level_info_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(level_info_label)
	add_child(level_info_label)

	## Chips
	preview_chips = Label.new()
	preview_chips.position = Vector2(-PANEL_WIDTH / 2 + 25, -PANEL_HEIGHT / 2 + 68)
	preview_chips.add_theme_font_size_override("font_size", 18)
	preview_chips.add_theme_color_override("font_color", Color(0.4, 0.65, 0.95))
	_f(preview_chips)
	add_child(preview_chips)

	## Mult
	preview_mult = Label.new()
	preview_mult.position = Vector2(-PANEL_WIDTH / 2 + 170, -PANEL_HEIGHT / 2 + 68)
	preview_mult.add_theme_font_size_override("font_size", 18)
	preview_mult.add_theme_color_override("font_color", Color(0.95, 0.4, 0.35))
	_f(preview_mult)
	add_child(preview_mult)

	## 预计总分
	preview_score = Label.new()
	preview_score.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 105)
	preview_score.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	preview_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_score.add_theme_font_size_override("font_size", 30)
	preview_score.add_theme_color_override("font_color", Color(0.95, 0.95, 0.9))
	_f(preview_score)
	add_child(preview_score)

	visible = false

func update_preview(result: Dictionary) -> void:
	if result.is_empty():
		visible = false
		return

	visible = true
	type_label.text = Loc.i().t(result["hand_name"])

	## 等级信息
	var level = result.get("level", 1)
	var level_info = HandLevel.get_level_info(result["hand_type"])
	if level > 1:
		level_info_label.text = "Lv." + str(level) + " · " + str(level_info["plays_to_next"]) + " " + Loc.i().t("plays to next level")
	else:
		level_info_label.text = "Lv.1 · " + str(level_info["plays_to_next"]) + " " + Loc.i().t("plays to next level")

	preview_chips.text = Loc.i().t("Chips") + ": " + str(result["total_chips"])
	preview_mult.text = "×" + str(result["total_mult"])
	preview_score.text = str(result["total_chips"]) + " × " + str(result["total_mult"]) + " = " + str(result["final_score"])

func hide_preview() -> void:
	visible = false
