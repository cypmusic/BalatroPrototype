## pause_menu.gd
## 暂停/标题菜单 V8 - 统一面板定位 + 垂直两端对齐 + 子面板自适应
extends Node2D

signal resume_game()
signal new_game()
signal quit_game()
signal continue_game()
signal return_to_title()
signal language_changed()

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

const MENU_W: float = 500.0
const MENU_H: float = 700.0
const BTN_W: float = 360.0
const BTN_H: float = 52.0
const BTN_SPACING: float = 64.0

## Title 模式面板 (居中偏下，窄长)
const TITLE_PANEL_W: float = 350.0
const TITLE_PANEL_H: float = 515.0
const TITLE_PANEL_BOTTOM_MARGIN: float = 290.0

## 收藏页大面板常量 (画册风格)
const COLL_W: float = 1700.0
const COLL_H: float = 950.0
const PREVIEW_W: float = 420.0

enum MenuMode { TITLE, PAUSE }
var mode: MenuMode = MenuMode.PAUSE

enum SubPanel { NONE, SETTINGS, COLLECTION, TUTORIAL }
var current_panel: SubPanel = SubPanel.NONE

## 收藏页分类标签
enum CollTab { BEASTS, CONSTELLATIONS, ARTIFACTS }
var coll_tab: CollTab = CollTab.BEASTS

## 异兽子标签 (-1=全部, 0-3=四象)
var beast_sx_tab: int = -1

## 预览面板状态
var _preview_panel: ColorRect = null
var _preview_tween: Tween = null
var _hovered_item_key: String = ""

var master_volume: float = 0.8
var sfx_volume: float = 0.8
var music_volume: float = 0.8
var joker_slot_ref = null

func _ready() -> void:
	visible = false
	z_index = 250
	process_mode = Node.PROCESS_MODE_ALWAYS

func open_as_title() -> void:
	mode = MenuMode.TITLE; visible = true; current_panel = SubPanel.NONE
	_build_main_menu()

func open_as_pause() -> void:
	mode = MenuMode.PAUSE; visible = true; current_panel = SubPanel.NONE
	get_tree().paused = true
	_build_main_menu()

func close_menu() -> void:
	visible = false
	if mode == MenuMode.PAUSE: get_tree().paused = false
	resume_game.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if visible:
			if current_panel != SubPanel.NONE:
				current_panel = SubPanel.NONE; _build_main_menu()
			elif mode == MenuMode.PAUSE:
				close_menu()
		else:
			## 标题画面时不弹出暂停菜单
			var ts = get_tree().root.get_node_or_null("Main/TitleScreen")
			if ts and ts.visible:
				return
			open_as_pause()
		get_viewport().set_input_as_handled()

## ========== 辅助 ==========

func _loc() -> Loc:
	return Loc.i()

func _t(key: String) -> String:
	return _loc().t(key)

func _make_label(text: String, pos: Vector2, font_size: int, color: Color,
		alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, min_w: float = 0) -> Label:
	var lbl = Label.new()
	lbl.text = text; lbl.position = pos
	if min_w > 0: lbl.custom_minimum_size = Vector2(min_w, 0)
	lbl.horizontal_alignment = alignment
	lbl.add_theme_color_override("font_color", color)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE  ## 防止标签拦截鼠标事件
	_loc().apply_font_to_label(lbl, font_size)
	return lbl

func _make_button(text: String, pos: Vector2, font_size: int,
		min_w: float, min_h: float, callback: Callable) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos
	btn.custom_minimum_size = Vector2(min_w, min_h)
	_loc().apply_font_to_button(btn, font_size)
	btn.pressed.connect(callback)
	return btn

## 获取当前模式下菜单面板的矩形区域
func _get_panel_rect() -> Rect2:
	if mode == MenuMode.PAUSE or current_panel != SubPanel.NONE:
		## 暂停模式 或 子面板（设置/收藏/教程）统一用居中大面板
		return Rect2(
			CENTER_X - MENU_W / 2.0,
			CENTER_Y - MENU_H / 2.0,
			MENU_W, MENU_H)
	else:
		## Title 主菜单：水平居中，靠下
		var px = CENTER_X - TITLE_PANEL_W / 2.0
		var py = SCREEN_H - TITLE_PANEL_H - TITLE_PANEL_BOTTOM_MARGIN
		return Rect2(px, py, TITLE_PANEL_W, TITLE_PANEL_H)

## ========== 主菜单 ==========

func _build_main_menu() -> void:
	_clear(); current_panel = SubPanel.NONE; _add_bg()
	var pr = _get_panel_rect()

	if mode == MenuMode.PAUSE:
		add_child(_make_label(_t("PAUSED"),
			Vector2(pr.position.x, pr.position.y + 20),
			42, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, pr.size.x))
		var line = ColorRect.new()
		line.position = Vector2(CENTER_X - 120, pr.position.y + 78)
		line.size = Vector2(240, 2)
		line.color = Color(0.95, 0.85, 0.3, 0.4)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)

	var buttons: Array
	if mode == MenuMode.TITLE:
		buttons = []
		if SaveManager.has_save():
			var info = SaveManager.get_save_info()
			var cont_label = "▶  " + _t("Continue") + " (Ante " + str(info.get("ante", 1)) + " · $" + str(info.get("money", 0)) + ")"
			buttons.append({"text": cont_label, "callback": _on_continue})
		buttons.append({"text": "▶  " + _t("New Game"), "callback": _on_new_game})
		buttons.append_array([
			{"text": "⚙  " + _t("Settings"), "callback": _open_settings},
			{"text": "🃏  " + _t("Collection"), "callback": _open_collection},
			{"text": "📖  " + _t("Tutorial"), "callback": _open_tutorial},
			{"text": "✕  " + _t("Quit Game"), "callback": _on_quit},
		])
	else:
		buttons = [
			{"text": "▶  " + _t("Continue"), "callback": close_menu},
			{"text": "⚙  " + _t("Settings"), "callback": _open_settings},
			{"text": "🃏  " + _t("Collection"), "callback": _open_collection},
			{"text": "📖  " + _t("Tutorial"), "callback": _open_tutorial},
			{"text": "🏠  " + _t("Return to Title"), "callback": _on_return_to_title},
			{"text": "✕  " + _t("Quit Game"), "callback": _on_quit},
		]

	## 按钮垂直居中在面板内
	var btn_count = buttons.size()
	var total_btn_h = btn_count * BTN_H + (btn_count - 1) * (BTN_SPACING - BTN_H)
	var panel_cx = pr.position.x + pr.size.x / 2.0
	var cur_btn_w = min(BTN_W, pr.size.x - 40)
	var start_y: float
	if mode == MenuMode.PAUSE:
		start_y = pr.position.y + 110
	else:
		start_y = pr.position.y + (pr.size.y - total_btn_h) / 2.0

	for i in range(btn_count):
		add_child(_make_button(buttons[i]["text"],
			Vector2(panel_cx - cur_btn_w / 2, start_y + i * BTN_SPACING),
			22, cur_btn_w, BTN_H, buttons[i]["callback"]))

	add_child(_make_label(GameConfig.VERSION_LABEL,
		Vector2(pr.position.x, pr.position.y + pr.size.y - 40),
		12, Color(0.4, 0.4, 0.35), HORIZONTAL_ALIGNMENT_CENTER, pr.size.x))

func _on_continue() -> void:
	visible = false; continue_game.emit()

func _on_new_game() -> void:
	SaveManager.delete_save()
	visible = false; new_game.emit()

func _on_return_to_title() -> void:
	get_tree().paused = false
	visible = false
	return_to_title.emit()

## ========== 设置 ==========

func _open_settings() -> void:
	_clear(); current_panel = SubPanel.SETTINGS; _add_bg()
	var pr = _get_panel_rect()
	_add_sub_header(_t("SETTINGS"), pr)

	## 内容区域：标题下方到返回按钮上方
	var content_top = pr.position.y + 100
	var content_bottom = pr.position.y + pr.size.y - 80
	var content_h = content_bottom - content_top

	var cats = [
		{"label": _t("Master Volume"), "value": master_volume},
		{"label": _t("SFX Volume"), "value": sfx_volume},
		{"label": _t("Music Volume"), "value": music_volume},
	]
	## 5 个项目：3个音量 + 语言 + 图形提示
	var item_count = 5
	var item_spacing = content_h / item_count

	for ci in range(cats.size()):
		var y = content_top + ci * item_spacing
		add_child(_make_label(cats[ci]["label"], Vector2(CENTER_X - 180, y), 18, Color(0.85, 0.85, 0.8)))

		var slider = HSlider.new()
		slider.min_value = 0.0; slider.max_value = 1.0; slider.step = 0.05
		slider.value = cats[ci]["value"]
		slider.position = Vector2(CENTER_X - 180, y + 25)
		slider.custom_minimum_size = Vector2(360, 20)
		var idx = ci
		slider.value_changed.connect(func(v): _on_volume_changed(idx, v))
		add_child(slider)

		var val_lbl = _make_label(str(int(cats[ci]["value"] * 100)) + "%",
			Vector2(CENTER_X + 200, y + 22), 16, Color(0.95, 0.85, 0.3))
		val_lbl.name = "VolLabel" + str(ci)
		add_child(val_lbl)

	var lang_y = content_top + 3 * item_spacing
	add_child(_make_label(_t("Language"), Vector2(CENTER_X - 180, lang_y), 18, Color(0.85, 0.85, 0.8)))
	var lang_btn = _make_button("  " + _loc().current_language + "  ▼",
		Vector2(CENTER_X - 180, lang_y + 25), 16, 200, 36, _cycle_language)
	lang_btn.z_index = 1  ## 确保在滑块之上
	add_child(lang_btn)

	add_child(_make_label(_t("Graphics settings coming soon..."),
		Vector2(CENTER_X - 180, content_top + 4 * item_spacing), 14, Color(0.5, 0.5, 0.45)))
	_add_back_button(pr)

func _on_volume_changed(index: int, value: float) -> void:
	match index:
		0:
			master_volume = value
			_set_bus_volume("Master", value)
		1:
			sfx_volume = value
			_set_bus_volume("SFX", value)
		2:
			music_volume = value
			_set_bus_volume("Music", value)
	var lbl = get_node_or_null("VolLabel" + str(index))
	if lbl: lbl.text = str(int(value * 100)) + "%"

func _set_bus_volume(bus_name: String, linear: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		## 如果找不到指定总线，尝试使用 Master
		if bus_name != "Master":
			bus_idx = AudioServer.get_bus_index("Master")
		if bus_idx < 0:
			bus_idx = 0  ## 回退到第一个总线
	if linear <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))

func _cycle_language() -> void:
	var langs = ["English", "中文"]
	var idx = langs.find(_loc().current_language)
	_loc().current_language = langs[(idx + 1) % langs.size()]
	## 直接设置全局字体
	var loc = Loc.i()
	var theme = get_tree().root.theme
	if theme == null:
		theme = Theme.new()
		get_tree().root.theme = theme
	if loc.current_language == "中文" and loc.cn_font:
		theme.set_default_font(loc.cn_font)
	else:
		theme.set_default_font(null)
	## 通知 main.gd 刷新所有 UI
	language_changed.emit()
	_open_settings()

## ========== 收藏 (画册风格 V2) ==========

var _SX_ORDER = [
	CardLore.SiXiang.AZURE_DRAGON,
	CardLore.SiXiang.VERMILLION_BIRD,
	CardLore.SiXiang.WHITE_TIGER,
	CardLore.SiXiang.BLACK_TORTOISE,
]

var _RARITY_COLORS = {
	0: Color(0.3, 0.9, 0.4),   ## Common - 绿
	1: Color(0.3, 0.6, 0.95),  ## Uncommon - 蓝
	2: Color(0.9, 0.3, 0.3),   ## Rare - 红
	3: Color(0.95, 0.8, 0.2),  ## Legendary - 金
}
var _RARITY_NAMES = {0: "Common", 1: "Uncommon", 2: "Rare", 3: "Legendary"}
var _RARITY_EMOJIS = {0: "🟢", 1: "🔵", 2: "🟣", 3: "🟡"}

## — 布局计算 —
func _get_coll_layout() -> Dictionary:
	var panel_left = CENTER_X - COLL_W / 2.0
	var panel_top = CENTER_Y - COLL_H / 2.0
	var inner_pad = 25.0
	var header_h = 65.0
	var tab_bar_h = 45.0
	var footer_h = 55.0
	var content_top = panel_top + header_h + tab_bar_h
	var content_bottom = panel_top + COLL_H - footer_h
	var content_left = panel_left + inner_pad
	var content_right = panel_left + COLL_W - inner_pad
	var grid_w = (content_right - content_left) * 0.58
	var preview_left = content_left + grid_w + 20
	var preview_w = content_right - preview_left
	return {
		"panel_left": panel_left, "panel_top": panel_top,
		"content_top": content_top, "content_bottom": content_bottom,
		"content_left": content_left, "grid_w": grid_w,
		"preview_left": preview_left, "preview_top": content_top,
		"preview_w": preview_w, "preview_h": content_bottom - content_top,
		"tab_y": panel_top + header_h,
	}

## — 收藏页入口 —
func _open_collection() -> void:
	_clear(); current_panel = SubPanel.COLLECTION
	_preview_panel = null; _hovered_item_key = ""
	_add_coll_bg()
	_add_coll_header(_t("COLLECTION"))
	var layout = _get_coll_layout()

	## 一级标签
	var tabs = [
		{"label": "🐉 " + _t("Beast Cards"), "tab": CollTab.BEASTS, "color": Color(0.3, 0.9, 0.4)},
		{"label": "⭐ " + _t("Constellation Cards"), "tab": CollTab.CONSTELLATIONS, "color": Color(0.2, 0.55, 0.85)},
		{"label": "🔮 " + _t("Artifact Cards"), "tab": CollTab.ARTIFACTS, "color": Color(0.7, 0.35, 0.75)},
	]
	var tab_w = 220.0; var tab_gap = 14.0
	var tab_total = tabs.size() * tab_w + (tabs.size() - 1) * tab_gap
	var tab_start_x = layout["content_left"]
	for i in range(tabs.size()):
		var tx = tab_start_x + i * (tab_w + tab_gap)
		var is_active = (tabs[i]["tab"] == coll_tab)
		var btn = Button.new()
		btn.text = tabs[i]["label"]
		btn.position = Vector2(tx, layout["tab_y"])
		btn.custom_minimum_size = Vector2(tab_w, 34)
		_loc().apply_font_to_button(btn, 15)
		if is_active:
			btn.add_theme_color_override("font_color", tabs[i]["color"])
		else:
			btn.add_theme_color_override("font_color", Color(0.45, 0.45, 0.4))
		var tab_val = tabs[i]["tab"]
		btn.pressed.connect(func(): _switch_coll_tab(tab_val))
		add_child(btn)

	## 预览面板
	_build_preview_panel(layout)

	## 异兽子标签 + 网格
	match coll_tab:
		CollTab.BEASTS:
			_build_beast_sub_tabs(layout)
			_fill_beast_grid_v2(layout)
		CollTab.CONSTELLATIONS:
			_fill_constellation_grid_v2(layout)
		CollTab.ARTIFACTS:
			_fill_artifact_grid_v2(layout)

	_add_coll_back_button()

func _switch_coll_tab(tab: CollTab) -> void:
	coll_tab = tab
	beast_sx_tab = -1  ## 切换主标签时重置子标签
	_open_collection()

## ---------- 收藏页大面板 ----------

func _add_coll_bg() -> void:
	var overlay = ColorRect.new()
	overlay.position = Vector2.ZERO; overlay.size = Vector2(SCREEN_W, SCREEN_H)
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var px = CENTER_X - COLL_W / 2.0
	var py = CENTER_Y - COLL_H / 2.0
	var panel = ColorRect.new()
	panel.position = Vector2(px, py); panel.size = Vector2(COLL_W, COLL_H)
	panel.color = Color(0.05, 0.07, 0.06, 0.96)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var bw = 2.0; var bc = Color(0.95, 0.85, 0.3, 0.35)
	for edge in [
		[Vector2(px, py), Vector2(COLL_W, bw)],
		[Vector2(px, py + COLL_H - bw), Vector2(COLL_W, bw)],
		[Vector2(px, py), Vector2(bw, COLL_H)],
		[Vector2(px + COLL_W - bw, py), Vector2(bw, COLL_H)],
	]:
		var b = ColorRect.new()
		b.position = edge[0]; b.size = edge[1]; b.color = bc
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(b)

func _add_coll_header(text: String) -> void:
	var py = CENTER_Y - COLL_H / 2.0
	add_child(_make_label(text, Vector2(CENTER_X - COLL_W / 2.0, py + 14),
		36, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, COLL_W))
	var line = ColorRect.new()
	line.position = Vector2(CENTER_X - 150, py + 54)
	line.size = Vector2(300, 2); line.color = Color(0.95, 0.85, 0.3, 0.3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

func _add_coll_back_button() -> void:
	var by = CENTER_Y + COLL_H / 2.0 - 50
	var btn = _make_button("  ← " + _t("Back") + "  ",
		Vector2(CENTER_X - 90, by), 18, 180, 40,
		func(): _build_main_menu())
	btn.z_index = 10
	add_child(btn)

## ---------- 预览面板系统 ----------

func _build_preview_panel(layout: Dictionary) -> void:
	var pw = layout["preview_w"]
	var ph = layout["preview_h"]
	var px = layout["preview_left"]
	var py = layout["preview_top"]

	## 预览面板背景
	_preview_panel = ColorRect.new()
	_preview_panel.position = Vector2(px, py)
	_preview_panel.size = Vector2(pw, ph)
	_preview_panel.color = Color(0.04, 0.06, 0.05, 0.85)
	_preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.z_index = 5
	add_child(_preview_panel)

	## 预览面板细边框
	var bw = 1.5; var bc = Color(0.95, 0.85, 0.3, 0.25)
	for edge in [
		[Vector2(0, 0), Vector2(pw, bw)],
		[Vector2(0, ph - bw), Vector2(pw, bw)],
		[Vector2(0, 0), Vector2(bw, ph)],
		[Vector2(pw - bw, 0), Vector2(bw, ph)],
	]:
		var b = ColorRect.new()
		b.position = edge[0]; b.size = edge[1]; b.color = bc
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_preview_panel.add_child(b)

	_set_preview_default()

func _set_preview_default() -> void:
	if not _preview_panel or not is_instance_valid(_preview_panel):
		return
	## 清除内容（保留边框，边框是前4个子节点）
	var children = _preview_panel.get_children()
	for i in range(children.size()):
		if i >= 4:  ## 前4个是边框
			children[i].queue_free()

	var pw = _preview_panel.size.x
	var ph = _preview_panel.size.y

	## 占位提示
	var icon_lbl = Label.new()
	icon_lbl.text = "📖"
	icon_lbl.position = Vector2(0, ph / 2.0 - 60)
	icon_lbl.custom_minimum_size = Vector2(pw, 0)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 48)
	icon_lbl.modulate.a = 0.3
	icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(icon_lbl)

	var hint_lbl = _make_label(_t("Hover over an item..."),
		Vector2(0, ph / 2.0 + 10), 14, Color(0.5, 0.5, 0.45),
		HORIZONTAL_ALIGNMENT_CENTER, pw)
	hint_lbl.modulate.a = 0.5
	_preview_panel.add_child(hint_lbl)
	_hovered_item_key = ""

func _set_preview_content(rows: Array) -> void:
	if not _preview_panel or not is_instance_valid(_preview_panel):
		return
	## 清除旧内容（保留边框）
	var children = _preview_panel.get_children()
	for i in range(children.size()):
		if i >= 4:
			children[i].queue_free()

	var pw = _preview_panel.size.x
	var pad_x = 16.0
	var label_w = 95.0
	var value_w = pw - label_w - pad_x * 2 - 8
	var row_y = 16.0

	## 创建内容容器 (用于 fade-in 动画)
	var container = Control.new()
	container.position = Vector2.ZERO
	container.size = _preview_panel.size
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.modulate.a = 0.0
	_preview_panel.add_child(container)

	for r in rows:
		var is_header = r.get("header", false)
		var is_divider = r.get("divider", false)

		if is_divider:
			var div = ColorRect.new()
			div.position = Vector2(pad_x, row_y)
			div.size = Vector2(pw - pad_x * 2, 1)
			div.color = Color(0.95, 0.85, 0.3, 0.15)
			div.mouse_filter = Control.MOUSE_FILTER_IGNORE
			container.add_child(div)
			row_y += 6
			continue

		if is_header:
			var h_lbl = Label.new()
			h_lbl.text = r.get("value", "")
			h_lbl.position = Vector2(pad_x, row_y)
			h_lbl.custom_minimum_size = Vector2(pw - pad_x * 2, 0)
			h_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			h_lbl.add_theme_color_override("font_color", r.get("color", Color(0.95, 0.85, 0.3)))
			_loc().apply_font_to_label(h_lbl, r.get("size", 18))
			h_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			container.add_child(h_lbl)
			row_y += r.get("size", 18) + 8
			continue

		## 普通键值行
		var k_lbl = Label.new()
		k_lbl.text = r.get("label", "")
		k_lbl.position = Vector2(pad_x, row_y)
		k_lbl.custom_minimum_size = Vector2(label_w, 0)
		k_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.5))
		_loc().apply_font_to_label(k_lbl, r.get("label_size", 12))
		k_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(k_lbl)

		var v_lbl = Label.new()
		v_lbl.text = r.get("value", "")
		v_lbl.position = Vector2(pad_x + label_w + 8, row_y)
		v_lbl.custom_minimum_size = Vector2(value_w, 0)
		v_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v_lbl.add_theme_color_override("font_color", r.get("color", Color(0.85, 0.85, 0.8)))
		_loc().apply_font_to_label(v_lbl, r.get("size", 12))
		v_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(v_lbl)

		## 估算行高
		var text_len = r.get("value", "").length()
		var approx_chars = int(value_w / 8)
		var line_count = maxi(1, ceili(float(text_len) / approx_chars))
		row_y += line_count * 16 + 5

	## Fade-in 动画
	if _preview_tween and _preview_tween.is_valid():
		_preview_tween.kill()
	_preview_tween = create_tween()
	_preview_tween.tween_property(container, "modulate:a", 1.0, 0.15)

## — 单元格悬停回调 —
func _on_cell_hover(item_key: String, rows: Array) -> void:
	if _hovered_item_key == item_key:
		return  ## 避免重复刷新
	_hovered_item_key = item_key
	_set_preview_content(rows)

func _on_cell_unhover(item_key: String) -> void:
	## 只有当离开的是当前预览的项目时才重置
	if _hovered_item_key == item_key:
		_hovered_item_key = ""
		## 短暂延迟，防止快速移动时闪烁
		await get_tree().create_timer(0.08).timeout
		if _hovered_item_key == "":
			_set_preview_default()

## ---------- 异兽子标签 ----------

func _build_beast_sub_tabs(layout: Dictionary) -> void:
	var sub_y = layout["content_top"] - 3
	var sx_tabs = [{"label": "🔮 " + _t("All"), "idx": -1, "color": Color(0.85, 0.85, 0.8)}]
	for si in range(4):
		var info = CardLore.get_si_xiang_info(_SX_ORDER[si])
		var name_text = _t(info["name_cn"]) if _loc().current_language == "中文" else info["name_en"]
		sx_tabs.append({"label": info["emoji"] + " " + name_text, "idx": si, "color": info["color"]})

	var stab_w = 140.0; var stab_gap = 8.0
	var stab_x = layout["content_left"]
	for i in range(sx_tabs.size()):
		var is_active = (sx_tabs[i]["idx"] == beast_sx_tab)
		var btn = Button.new()
		btn.text = sx_tabs[i]["label"]
		btn.position = Vector2(stab_x + i * (stab_w + stab_gap), sub_y)
		btn.custom_minimum_size = Vector2(stab_w, 28)
		_loc().apply_font_to_button(btn, 12)
		if is_active:
			btn.add_theme_color_override("font_color", sx_tabs[i]["color"])
		else:
			btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.38))
		var idx_val = sx_tabs[i]["idx"]
		btn.pressed.connect(func(): _switch_beast_sx_tab(idx_val))
		add_child(btn)

func _switch_beast_sx_tab(idx: int) -> void:
	beast_sx_tab = idx
	_open_collection()

## ---------- 异兽网格 V2 ----------

func _fill_beast_grid_v2(layout: Dictionary) -> void:
	var all_jokers = JokerDatabase.get_all_jokers()

	## 按四象分组
	var sx_groups: Dictionary = {}
	for sx in _SX_ORDER:
		sx_groups[sx] = []
	for joker in all_jokers:
		var lore = CardLore.get_beast_lore(joker.id)
		sx_groups[lore["si_xiang"]].append(joker)

	var x0 = layout["content_left"]
	var y0 = layout["content_top"] + 30  ## 子标签下方
	var grid_w = layout["grid_w"]
	var y_bottom = layout["content_bottom"]

	if beast_sx_tab >= 0 and beast_sx_tab < 4:
		## 单组模式：显示指定四象
		var sx = _SX_ORDER[beast_sx_tab]
		var info = CardLore.get_si_xiang_info(sx)
		var beasts = sx_groups[sx]
		var cols = 4
		var cell_w = grid_w / cols
		var available_h = y_bottom - y0 - 30
		var row_count = ceili(float(beasts.size()) / cols)
		var cell_h = minf(available_h / row_count, 50.0) if row_count > 0 else 40.0
		cell_h = maxf(cell_h, 32.0)

		## 组标题
		var hdr_text = info["emoji"] + " " + (_t(info["name_cn"]) if _loc().current_language == "中文" else info["name_en"]) + " " + info["suit_cn"] + " (" + str(beasts.size()) + ")"
		add_child(_make_label(hdr_text, Vector2(x0, y0), 18, info["color"],
			HORIZONTAL_ALIGNMENT_LEFT, grid_w))
		var cur_y = y0 + 28

		for bi in range(beasts.size()):
			var joker = beasts[bi]
			var col = bi % cols
			var row = bi / cols
			var lx = x0 + col * cell_w
			var ly = cur_y + row * cell_h
			_add_beast_cell(joker, Vector2(lx, ly), cell_w, cell_h, 14)
	else:
		## 全部模式：4组紧凑排列
		var cols = 6
		var cell_w = grid_w / cols
		var hdr_h = 24.0
		var box_pad = 5.0
		var group_gap = 8.0

		var total_rows = 0
		for sx in _SX_ORDER:
			total_rows += ceili(float(sx_groups[sx].size()) / cols)
		var total_fixed = 4 * (hdr_h + box_pad * 2) + 3 * group_gap
		var remaining = (y_bottom - y0) - total_fixed
		var cell_h = remaining / total_rows if total_rows > 0 else 28.0
		cell_h = clampf(cell_h, 26.0, 42.0)

		var cur_y = y0
		for sx in _SX_ORDER:
			var info = CardLore.get_si_xiang_info(sx)
			var beasts = sx_groups[sx]
			var row_count = ceili(float(beasts.size()) / cols)
			var box_h = hdr_h + row_count * cell_h + box_pad * 2
			var border_color = Color(info["color"], 0.35)

			_draw_section_box(Vector2(x0 - box_pad, cur_y), Vector2(grid_w + box_pad * 2, box_h), border_color)

			var hdr_text = info["emoji"] + " " + (_t(info["name_cn"]) if _loc().current_language == "中文" else info["name_en"]) + " " + info["suit_cn"]
			add_child(_make_label(hdr_text, Vector2(x0 - box_pad, cur_y + 3), 14, info["color"],
				HORIZONTAL_ALIGNMENT_CENTER, grid_w + box_pad * 2))
			cur_y += hdr_h

			for bi in range(beasts.size()):
				var joker = beasts[bi]
				var col = bi % cols
				var row = bi / cols
				var lx = x0 + col * cell_w
				var ly = cur_y + row * cell_h
				_add_beast_cell(joker, Vector2(lx, ly), cell_w, cell_h, 12)

			cur_y += row_count * cell_h + box_pad + group_gap

func _add_beast_cell(joker: JokerData, pos: Vector2, cell_w: float, cell_h: float, font_sz: int) -> void:
	var c = _RARITY_COLORS.get(joker.rarity, Color(0.7, 0.7, 0.7))
	var lbl = Label.new()
	lbl.text = joker.emoji + " " + _t(joker.joker_name)
	lbl.position = pos
	lbl.custom_minimum_size = Vector2(cell_w - 4, cell_h - 2)
	lbl.add_theme_color_override("font_color", c)
	_loc().apply_font_to_label(lbl, font_sz)
	lbl.mouse_filter = Control.MOUSE_FILTER_STOP

	var j_ref = joker
	var original_c = c
	lbl.mouse_entered.connect(func():
		lbl.add_theme_color_override("font_color", Color(minf(original_c.r * 1.3, 1.0), minf(original_c.g * 1.3, 1.0), minf(original_c.b * 1.3, 1.0)))
		_on_cell_hover("beast_" + j_ref.id, _build_beast_preview_rows(j_ref))
	)
	lbl.mouse_exited.connect(func():
		lbl.add_theme_color_override("font_color", original_c)
		_on_cell_unhover("beast_" + j_ref.id)
	)
	add_child(lbl)

func _build_beast_preview_rows(joker: JokerData) -> Array:
	var lore = CardLore.get_beast_lore(joker.id)
	var sx_info = CardLore.get_si_xiang_info(lore["si_xiang"])
	var lang = _loc().current_language
	var is_cn = (lang == "中文")

	var cat_emoji = CardLore.get_category_emoji(lore["category"])
	var cat_name = CardLore.get_category_name(lore["category"], lang)
	var display_name = _t(joker.joker_name)

	return [
		{"header": true, "value": joker.emoji + " " + display_name, "color": _RARITY_COLORS.get(joker.rarity, Color.WHITE), "size": 20},
		{"divider": true},
		{"label": _t("Si Xiang"), "value": sx_info["emoji"] + " " + (sx_info["name_cn"] + sx_info["suit_cn"] + " (" + sx_info["element_cn"] + ")" if is_cn else sx_info["name_en"]), "color": sx_info["color"]},
		{"label": _t("Rarity"), "value": _RARITY_EMOJIS.get(joker.rarity, "") + " " + _t(_RARITY_NAMES.get(joker.rarity, "?")), "color": _RARITY_COLORS.get(joker.rarity, Color.WHITE)},
		{"label": _t("Effect Type"), "value": cat_emoji + " " + cat_name},
		{"divider": true},
		{"label": _t("Lore"), "value": lore["lore_cn"] if is_cn else lore["lore_en"], "size": 11},
		{"divider": true},
		{"label": _t("Description"), "value": _t(joker.description) if is_cn else joker.description, "size": 12},
	]

## ---------- 星宿网格 V2 ----------

func _fill_constellation_grid_v2(layout: Dictionary) -> void:
	var all_planets = PlanetDatabase.get_all_planets()

	## 数据库顺序：青龙7 + 玄武7 + 白虎7 + 朱雀7
	var sx_map = [
		{"sx": CardLore.SiXiang.AZURE_DRAGON, "start": 0},
		{"sx": CardLore.SiXiang.BLACK_TORTOISE, "start": 7},
		{"sx": CardLore.SiXiang.WHITE_TIGER, "start": 14},
		{"sx": CardLore.SiXiang.VERMILLION_BIRD, "start": 21},
	]

	var x0 = layout["content_left"]
	var y0 = layout["content_top"]
	var grid_w = layout["grid_w"]
	var y_bottom = layout["content_bottom"]

	var cols = 7
	var label_w = 110.0
	var cell_w = (grid_w - label_w) / cols
	var box_pad = 6.0

	var group_count = sx_map.size()
	var available_h = y_bottom - y0
	var group_total_h = available_h / group_count
	var row_h = group_total_h - box_pad * 2 - 6
	row_h = maxf(row_h, 34.0)
	var box_h = row_h + box_pad * 2

	var cur_y = y0

	for gi in range(group_count):
		var group = sx_map[gi]
		var info = CardLore.get_si_xiang_info(group["sx"])
		var border_color = Color(info["color"], 0.3)

		_draw_section_box(Vector2(x0 - box_pad, cur_y), Vector2(grid_w + box_pad * 2, box_h), border_color)

		## 四象标签
		add_child(_make_label(
			info["emoji"] + " " + (_t(info["name_cn"]) if _loc().current_language == "中文" else info["name_en"]),
			Vector2(x0, cur_y + box_pad), 14, info["color"],
			HORIZONTAL_ALIGNMENT_CENTER, label_w))

		## 7个星宿
		for ci in range(7):
			var pi = group["start"] + ci
			if pi >= all_planets.size(): break
			var planet = all_planets[pi]
			var hand_name = _t(PokerHand.get_hand_name(planet.hand_type))
			var lx = x0 + label_w + ci * cell_w

			## 星宿名
			var lbl = Label.new()
			lbl.text = planet.emoji + " " + _t(planet.planet_name)
			lbl.position = Vector2(lx, cur_y + box_pad)
			lbl.custom_minimum_size = Vector2(cell_w - 4, row_h / 2.0)
			lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.7))
			_loc().apply_font_to_label(lbl, 13)
			lbl.mouse_filter = Control.MOUSE_FILTER_STOP

			var p_ref = planet
			var p_sx = group["sx"]
			var original_c = Color(0.75, 0.75, 0.7)
			lbl.mouse_entered.connect(func():
				lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.9))
				_on_cell_hover("planet_" + p_ref.id, _build_constellation_preview_rows(p_ref, p_sx))
			)
			lbl.mouse_exited.connect(func():
				lbl.add_theme_color_override("font_color", original_c)
				_on_cell_unhover("planet_" + p_ref.id)
			)
			add_child(lbl)

			## 牌型名
			var sub = Label.new()
			sub.text = "→ " + hand_name
			sub.position = Vector2(lx + 6, cur_y + box_pad + 17)
			sub.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
			_loc().apply_font_to_label(sub, 10)
			sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(sub)

		cur_y += group_total_h

func _build_constellation_preview_rows(planet: PlanetData, sx: CardLore.SiXiang) -> Array:
	var lang = _loc().current_language
	var is_cn = (lang == "中文")
	var sx_info = CardLore.get_si_xiang_info(sx)
	var hand_name = _t(PokerHand.get_hand_name(planet.hand_type))
	var level_info = HandLevel.get_level_info(planet.hand_type)
	var level_str = "Lv." + str(level_info.get("level", 1))

	return [
		{"header": true, "value": planet.emoji + " " + _t(planet.planet_name), "color": sx_info["color"], "size": 20},
		{"divider": true},
		{"label": _t("Si Xiang"), "value": sx_info["emoji"] + " " + (sx_info["name_cn"] + sx_info["suit_cn"] if is_cn else sx_info["name_en"]), "color": sx_info["color"]},
		{"label": _t("Hand Type"), "value": hand_name},
		{"label": _t("Current Level"), "value": level_str, "color": Color(0.95, 0.85, 0.3)},
		{"label": _t("Upgrade"), "value": "+" + str(planet.level_chips) + " Chips, +" + str(planet.level_mult) + " Mult"},
		{"divider": true},
		{"label": _t("Description"), "value": _t(planet.description) if is_cn else planet.description, "size": 12},
	]

## ---------- 法宝网格 V2 ----------

func _fill_artifact_grid_v2(layout: Dictionary) -> void:
	var all_tarots = TarotDatabase.get_all_tarots()
	var relics: Array = []
	var formations: Array = []
	for t in all_tarots:
		if t.artifact_type == TarotData.ArtifactType.RELIC:
			relics.append(t)
		else:
			formations.append(t)

	var x0 = layout["content_left"]
	var y0 = layout["content_top"]
	var grid_w = layout["grid_w"]
	var y_bottom = layout["content_bottom"]

	var available_h = y_bottom - y0
	var box_pad = 6.0
	var gap_between = 15.0

	var relic_cols = 4
	var relic_rows = ceili(float(relics.size()) / relic_cols)
	var form_cols = 4
	var form_rows = ceili(float(formations.size()) / form_cols)

	var total_data_rows = relic_rows + form_rows
	var fixed_h = 2 * (28.0 + box_pad * 2) + gap_between
	var remaining_h = available_h - fixed_h
	var cell_h = remaining_h / total_data_rows if total_data_rows > 0 else 32.0
	cell_h = clampf(cell_h, 28.0, 50.0)

	var relic_cell_w = grid_w / relic_cols
	var form_cell_w = grid_w / form_cols

	var cur_y = y0

	## — 神器 —
	var relic_box_h = 28.0 + relic_rows * cell_h + box_pad * 2
	_draw_section_box(Vector2(x0 - box_pad, cur_y), Vector2(grid_w + box_pad * 2, relic_box_h), Color(0.7, 0.35, 0.75, 0.3))

	add_child(_make_label("⚱️ " + _t("Relics") + " (" + str(relics.size()) + ")",
		Vector2(x0 - box_pad, cur_y + 5), 16, Color(0.7, 0.35, 0.75),
		HORIZONTAL_ALIGNMENT_CENTER, grid_w + box_pad * 2))
	cur_y += 28

	for i in range(relics.size()):
		var tarot = relics[i]
		var col = i % relic_cols
		var row = i / relic_cols
		var lx = x0 + col * relic_cell_w
		var ly = cur_y + row * cell_h
		_add_artifact_cell(tarot, Vector2(lx, ly), relic_cell_w, cell_h, Color(0.7, 0.35, 0.75))

	cur_y += relic_rows * cell_h + box_pad + gap_between

	## — 阵法 —
	var form_box_h = 28.0 + form_rows * cell_h + box_pad * 2
	_draw_section_box(Vector2(x0 - box_pad, cur_y), Vector2(grid_w + box_pad * 2, form_box_h), Color(0.85, 0.25, 0.25, 0.3))

	add_child(_make_label("⚔️ " + _t("Formations") + " (" + str(formations.size()) + ")",
		Vector2(x0 - box_pad, cur_y + 5), 16, Color(0.85, 0.25, 0.25),
		HORIZONTAL_ALIGNMENT_CENTER, grid_w + box_pad * 2))
	cur_y += 28

	for i in range(formations.size()):
		var tarot = formations[i]
		var col = i % form_cols
		var row = i / form_cols
		var lx = x0 + col * form_cell_w
		var ly = cur_y + row * cell_h
		_add_artifact_cell(tarot, Vector2(lx, ly), form_cell_w, cell_h, Color(0.85, 0.25, 0.25))

func _add_artifact_cell(tarot: TarotData, pos: Vector2, cell_w: float, cell_h: float, base_color: Color) -> void:
	var lbl = Label.new()
	lbl.text = tarot.emoji + " " + _t(tarot.tarot_name)
	lbl.position = pos
	lbl.custom_minimum_size = Vector2(cell_w - 4, cell_h - 2)
	lbl.add_theme_color_override("font_color", base_color)
	_loc().apply_font_to_label(lbl, 13)
	lbl.mouse_filter = Control.MOUSE_FILTER_STOP

	var t_ref = tarot
	var original_c = base_color
	lbl.mouse_entered.connect(func():
		lbl.add_theme_color_override("font_color", Color(minf(original_c.r * 1.3, 1.0), minf(original_c.g * 1.3, 1.0), minf(original_c.b * 1.3, 1.0)))
		_on_cell_hover("artifact_" + t_ref.id, _build_artifact_preview_rows(t_ref))
	)
	lbl.mouse_exited.connect(func():
		lbl.add_theme_color_override("font_color", original_c)
		_on_cell_unhover("artifact_" + t_ref.id)
	)
	add_child(lbl)

func _build_artifact_preview_rows(tarot: TarotData) -> Array:
	var is_cn = (_loc().current_language == "中文")
	var type_name = _t("Relic") if tarot.artifact_type == TarotData.ArtifactType.RELIC else _t("Formation")
	var type_color = tarot.get_rarity_color()

	var rows: Array = [
		{"header": true, "value": tarot.emoji + " " + _t(tarot.tarot_name), "color": type_color, "size": 20},
		{"divider": true},
		{"label": _t("Type"), "value": type_name, "color": type_color},
		{"label": _t("Cost"), "value": "$" + str(tarot.cost), "color": Color(0.95, 0.8, 0.2)},
		{"divider": true},
		{"label": _t("Description"), "value": _t(tarot.description) if is_cn else tarot.description, "size": 12},
	]
	if tarot.needs_selection:
		rows.insert(4, {"label": _t("Selection"), "value": str(tarot.min_select) + "~" + str(tarot.max_select) + " " + _t("cards")})
	return rows

## ========== 教程 ==========

func _open_tutorial() -> void:
	_clear(); current_panel = SubPanel.TUTORIAL; _add_bg()
	var pr = _get_panel_rect()
	_add_sub_header(_t("HOW TO PLAY"), pr)

	var content_top = pr.position.y + 100
	var content_bottom = pr.position.y + pr.size.y - 80
	var content_h = content_bottom - content_top

	var tuts = [
		["🎯 " + _t("Goal"), _t("Reach the target score before running out of hands.")],
		["🃏 " + _t("Hands"), _t("Select up to 6 cards to play poker hands.")],
		["📊 " + _t("Scoring"), _t("Chips × Mult = Score. Better hands = more points.")],
		["🗑️ " + _t("Discard"), _t("Discard unwanted cards to draw new ones.")],
		["🐉 " + _t("Beasts"), _t("Buy Beasts in the shop for permanent bonuses.")],
		["⭐ " + _t("Constellations"), _t("Constellation cards level up hand types permanently.")],
		["🔮 " + _t("Artifacts"), _t("Artifact cards modify your hand cards.")],
		["🏪 " + _t("Shop"), _t("After each round, buy Beasts and consumables.")],
		["⚔️ " + _t("Blinds"), _t("Small → Big → Boss. Skip for rewards.")],
		["🏆 " + _t("Victory"), _t("Clear all 8 Antes to win!")],
	]
	var item_spacing = content_h / tuts.size()
	for i in range(tuts.size()):
		var y = content_top + i * item_spacing
		add_child(_make_label(tuts[i][0], Vector2(CENTER_X - 220, y), 16, Color(0.95, 0.85, 0.3)))
		add_child(_make_label(tuts[i][1], Vector2(CENTER_X - 220, y + 20), 12, Color(0.65, 0.65, 0.6)))
	_add_back_button(pr)

func _on_quit() -> void:
	get_tree().paused = false; get_tree().quit()

## ========== 工具 ==========

## 绘制分组边框矩形 (半透明背景 + 彩色细边框)
func _draw_section_box(pos: Vector2, box_size: Vector2, border_color: Color) -> void:
	## 半透明背景
	var bg = ColorRect.new()
	bg.position = pos; bg.size = box_size
	bg.color = Color(border_color.r, border_color.g, border_color.b, 0.06)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	## 四边细边框
	var bw = 1.0
	for edge in [
		[Vector2(pos.x, pos.y), Vector2(box_size.x, bw)],                           ## top
		[Vector2(pos.x, pos.y + box_size.y - bw), Vector2(box_size.x, bw)],         ## bottom
		[Vector2(pos.x, pos.y), Vector2(bw, box_size.y)],                            ## left
		[Vector2(pos.x + box_size.x - bw, pos.y), Vector2(bw, box_size.y)],         ## right
	]:
		var b = ColorRect.new()
		b.position = edge[0]; b.size = edge[1]; b.color = border_color
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(b)

func _clear() -> void:
	_preview_panel = null
	_hovered_item_key = ""
	if _preview_tween and _preview_tween.is_valid():
		_preview_tween.kill()
	_preview_tween = null
	for child in get_children(): child.queue_free()

func _add_bg() -> void:
	var overlay = ColorRect.new()
	overlay.position = Vector2(0, 0); overlay.size = Vector2(SCREEN_W, SCREEN_H)
	overlay.color = Color(0, 0, 0, 0.7 if mode == MenuMode.PAUSE else 0.35)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var pr = _get_panel_rect()
	var panel = ColorRect.new()
	panel.position = pr.position
	panel.size = pr.size
	panel.color = Color(0.06, 0.09, 0.07, 0.92)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var bw = 2.0; var bc = Color(0.95, 0.85, 0.3, 0.3)
	for edge in [
		[Vector2(pr.position.x, pr.position.y), Vector2(pr.size.x, bw)],
		[Vector2(pr.position.x, pr.position.y + pr.size.y - bw), Vector2(pr.size.x, bw)],
		[Vector2(pr.position.x, pr.position.y), Vector2(bw, pr.size.y)],
		[Vector2(pr.position.x + pr.size.x - bw, pr.position.y), Vector2(bw, pr.size.y)],
	]:
		var border = ColorRect.new()
		border.position = edge[0]; border.size = edge[1]; border.color = bc
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)

## 子面板标题（自适应面板位置）
func _add_sub_header(text: String, pr: Rect2) -> void:
	add_child(_make_label(text, Vector2(pr.position.x, pr.position.y + 20),
		36, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, pr.size.x))
	var line = ColorRect.new()
	line.position = Vector2(CENTER_X - 100, pr.position.y + 68)
	line.size = Vector2(200, 2); line.color = Color(0.95, 0.85, 0.3, 0.3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

## 返回按钮（自适应面板位置）
func _add_back_button(pr: Rect2) -> void:
	var btn = _make_button("  ← " + _t("Back") + "  ",
		Vector2(CENTER_X - 80, pr.position.y + pr.size.y - 60), 18, 160, 42,
		func(): _build_main_menu())
	btn.z_index = 10  ## 确保在滑块/其他控件之上，防止被遮挡
	add_child(btn)
