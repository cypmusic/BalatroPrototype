## hand_preview.gd
## 手牌预览提示 V6 - 取消打牌升级显示（升级仅通过星球牌）
extends Node2D

var type_label: Label
var level_info_label: Label
var preview_chips: Label
var preview_mult: Label
var preview_score: Label
var bg_panel: ColorRect

const PANEL_WIDTH: float = 600.0
const PANEL_HEIGHT: float = 320.0

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
	type_label.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 16)
	type_label.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_font_size_override("font_size", 52)
	type_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_f(type_label)
	add_child(type_label)

	## 等级信息
	level_info_label = Label.new()
	level_info_label.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 84)
	level_info_label.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	level_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_info_label.add_theme_font_size_override("font_size", 28)
	level_info_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_f(level_info_label)
	add_child(level_info_label)

	## Chips + Mult（合为一行居中显示）
	preview_chips = Label.new()
	preview_chips.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 136)
	preview_chips.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	preview_chips.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_chips.add_theme_font_size_override("font_size", 36)
	preview_chips.add_theme_color_override("font_color", Color(0.4, 0.65, 0.95))
	_f(preview_chips)
	add_child(preview_chips)

	## Mult（隐藏，数据通过 preview_chips 合并显示）
	preview_mult = Label.new()
	preview_mult.visible = false
	add_child(preview_mult)

	## 预计总分
	preview_score = Label.new()
	preview_score.position = Vector2(-PANEL_WIDTH / 2, -PANEL_HEIGHT / 2 + 210)
	preview_score.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	preview_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_score.add_theme_font_size_override("font_size", 60)
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

	## 等级信息（只显示等级，不再显示"X次后升级"）
	var level = result.get("level", 1)
	level_info_label.text = "Lv." + str(level)

	preview_chips.text = Loc.i().t("Chips") + ": " + str(result["total_chips"]) + "     ×" + str(result["total_mult"])
	preview_score.text = str(result["total_chips"]) + " × " + str(result["total_mult"]) + " = " + str(result["final_score"])

func hide_preview() -> void:
	visible = false
