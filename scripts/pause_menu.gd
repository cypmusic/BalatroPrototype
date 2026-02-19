## pause_menu.gd
## 暂停/标题菜单 V5 - 回到主菜单 + 语言切换即时刷新
extends Node2D

signal resume_game()
signal new_game()
signal quit_game()
signal continue_game()
signal return_to_title()
signal language_changed()

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1280.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

const MENU_W: float = 500.0
const MENU_H: float = 700.0
const BTN_W: float = 360.0
const BTN_H: float = 52.0
const BTN_SPACING: float = 64.0

enum MenuMode { TITLE, PAUSE }
var mode: MenuMode = MenuMode.PAUSE

enum SubPanel { NONE, SETTINGS, COLLECTION, TUTORIAL }
var current_panel: SubPanel = SubPanel.NONE

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

## ========== 主菜单 ==========

func _build_main_menu() -> void:
	_clear(); current_panel = SubPanel.NONE; _add_bg()

	if mode == MenuMode.PAUSE:
		add_child(_make_label(_t("PAUSED"),
			Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2 + 20),
			42, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, MENU_W))
		var line = ColorRect.new()
		line.position = Vector2(CENTER_X - 120, CENTER_Y - MENU_H/2 + 78)
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

	var start_y = CENTER_Y - MENU_H/2 + (110 if mode == MenuMode.PAUSE else 60)
	for i in range(buttons.size()):
		add_child(_make_button(buttons[i]["text"],
			Vector2(CENTER_X - BTN_W/2, start_y + i * BTN_SPACING),
			22, BTN_W, BTN_H, buttons[i]["callback"]))

	add_child(_make_label(GameConfig.VERSION_LABEL,
		Vector2(CENTER_X - MENU_W/2, CENTER_Y + MENU_H/2 - 40),
		12, Color(0.4, 0.4, 0.35), HORIZONTAL_ALIGNMENT_CENTER, MENU_W))

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
	_add_sub_header(_t("SETTINGS"))

	var start_y = CENTER_Y - MENU_H/2 + 130
	var cats = [
		{"label": _t("Master Volume"), "value": master_volume},
		{"label": _t("SFX Volume"), "value": sfx_volume},
		{"label": _t("Music Volume"), "value": music_volume},
	]
	for ci in range(cats.size()):
		var y = start_y + ci * 80
		add_child(_make_label(cats[ci]["label"], Vector2(CENTER_X - 180, y), 18, Color(0.85, 0.85, 0.8)))

		var slider = HSlider.new()
		slider.min_value = 0.0; slider.max_value = 1.0; slider.step = 0.05
		slider.value = cats[ci]["value"]
		slider.position = Vector2(CENTER_X - 180, y + 28)
		slider.custom_minimum_size = Vector2(360, 20)
		var idx = ci
		slider.value_changed.connect(func(v): _on_volume_changed(idx, v))
		add_child(slider)

		var val_lbl = _make_label(str(int(cats[ci]["value"] * 100)) + "%",
			Vector2(CENTER_X + 200, y + 25), 16, Color(0.95, 0.85, 0.3))
		val_lbl.name = "VolLabel" + str(ci)
		add_child(val_lbl)

	var lang_y = start_y + 3 * 80
	add_child(_make_label(_t("Language"), Vector2(CENTER_X - 180, lang_y), 18, Color(0.85, 0.85, 0.8)))
	add_child(_make_button("  " + _loc().current_language + "  ▼",
		Vector2(CENTER_X - 180, lang_y + 28), 16, 200, 36, _cycle_language))

	add_child(_make_label(_t("Graphics settings coming soon..."),
		Vector2(CENTER_X - 180, start_y + 4 * 80), 14, Color(0.5, 0.5, 0.45)))
	_add_back_button()

func _on_volume_changed(index: int, value: float) -> void:
	match index:
		0: master_volume = value
		1: sfx_volume = value
		2: music_volume = value
	var lbl = get_node_or_null("VolLabel" + str(index))
	if lbl: lbl.text = str(int(value * 100)) + "%"

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

## ========== 收藏 ==========

func _open_collection() -> void:
	_clear(); current_panel = SubPanel.COLLECTION; _add_bg()
	_add_sub_header(_t("COLLECTION"))
	var sy = CENTER_Y - MENU_H/2 + 130

	add_child(_make_label("🃏  " + _t("Joker Cards"), Vector2(CENTER_X - 200, sy), 22, Color(0.3, 0.9, 0.4)))
	var all_jokers = JokerDatabase.get_all_jokers()
	var owned_ids: Array = []
	if joker_slot_ref:
		for j in joker_slot_ref.get_owned_jokers(): owned_ids.append(j.id)
	var col = 0; var row = 0
	for joker in all_jokers:
		var c = Color(0.9, 0.9, 0.85) if joker.id in owned_ids else Color(0.35, 0.35, 0.3)
		add_child(_make_label(joker.emoji + " " + joker.joker_name,
			Vector2(CENTER_X - 210 + col * 105, sy + 35 + row * 26), 12, c))
		col += 1
		if col >= 4: col = 0; row += 1

	var py = sy + 35 + (row + 2) * 26
	add_child(_make_label("🪐  " + _t("Planet Cards"), Vector2(CENTER_X - 200, py), 22, Color(0.2, 0.55, 0.85)))
	col = 0; row = 0
	for planet in PlanetDatabase.get_all_planets():
		add_child(_make_label(planet.emoji + " " + planet.planet_name,
			Vector2(CENTER_X - 210 + col * 140, py + 32 + row * 24), 12, Color(0.75, 0.75, 0.7)))
		col += 1
		if col >= 3: col = 0; row += 1

	var ty = py + 32 + (row + 2) * 24
	add_child(_make_label("🔮  " + _t("Tarot Cards"), Vector2(CENTER_X - 200, ty), 22, Color(0.7, 0.35, 0.75)))
	col = 0; row = 0
	for tarot in TarotDatabase.get_all_tarots():
		add_child(_make_label(tarot.emoji + " " + tarot.tarot_name,
			Vector2(CENTER_X - 210 + col * 140, ty + 32 + row * 24), 12, Color(0.75, 0.75, 0.7)))
		col += 1
		if col >= 3: col = 0; row += 1
	_add_back_button()

## ========== 教程 ==========

func _open_tutorial() -> void:
	_clear(); current_panel = SubPanel.TUTORIAL; _add_bg()
	_add_sub_header(_t("HOW TO PLAY"))
	var sy = CENTER_Y - MENU_H/2 + 130
	var tuts = [
		["🎯 " + _t("Goal"), _t("Reach the target score before running out of hands.")],
		["🃏 " + _t("Hands"), _t("Select up to 5 cards to play poker hands.")],
		["📊 " + _t("Scoring"), _t("Chips × Mult = Score. Better hands = more points.")],
		["🗑️ " + _t("Discard"), _t("Discard unwanted cards to draw new ones.")],
		["🤡 " + _t("Jokers"), _t("Buy Jokers in the shop for permanent bonuses.")],
		["🪐 " + _t("Planets"), _t("Planet cards level up hand types permanently.")],
		["🔮 " + _t("Tarots"), _t("Tarot cards modify your hand cards.")],
		["🏪 " + _t("Shop"), _t("After each round, buy Jokers and consumables.")],
		["⚔️ " + _t("Blinds"), _t("Small → Big → Boss. Skip for rewards.")],
		["🏆 " + _t("Victory"), _t("Clear all 8 Antes to win!")],
	]
	for i in range(tuts.size()):
		var y = sy + i * 48
		add_child(_make_label(tuts[i][0], Vector2(CENTER_X - 220, y), 16, Color(0.95, 0.85, 0.3)))
		add_child(_make_label(tuts[i][1], Vector2(CENTER_X - 220, y + 22), 12, Color(0.65, 0.65, 0.6)))
	_add_back_button()

func _on_quit() -> void:
	get_tree().paused = false; get_tree().quit()

## ========== 工具 ==========

func _clear() -> void:
	for child in get_children(): child.queue_free()

func _add_bg() -> void:
	var overlay = ColorRect.new()
	overlay.position = Vector2(0, 0); overlay.size = Vector2(SCREEN_W, SCREEN_H)
	overlay.color = Color(0, 0, 0, 0.7 if mode == MenuMode.PAUSE else 0.45)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var panel = ColorRect.new()
	panel.position = Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2)
	panel.size = Vector2(MENU_W, MENU_H)
	panel.color = Color(0.06, 0.09, 0.07, 0.95)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var bw = 2.0; var bc = Color(0.95, 0.85, 0.3, 0.3)
	for edge in [
		[Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2), Vector2(MENU_W, bw)],
		[Vector2(CENTER_X - MENU_W/2, CENTER_Y + MENU_H/2 - bw), Vector2(MENU_W, bw)],
		[Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2), Vector2(bw, MENU_H)],
		[Vector2(CENTER_X + MENU_W/2 - bw, CENTER_Y - MENU_H/2), Vector2(bw, MENU_H)],
	]:
		var border = ColorRect.new()
		border.position = edge[0]; border.size = edge[1]; border.color = bc
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)

func _add_sub_header(text: String) -> void:
	add_child(_make_label(text, Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2 + 20),
		36, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, MENU_W))
	var line = ColorRect.new()
	line.position = Vector2(CENTER_X - 100, CENTER_Y - MENU_H/2 + 68)
	line.size = Vector2(200, 2); line.color = Color(0.95, 0.85, 0.3, 0.3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

func _add_back_button() -> void:
	add_child(_make_button("  ← " + _t("Back") + "  ",
		Vector2(CENTER_X - 80, CENTER_Y + MENU_H/2 - 60), 18, 160, 42,
		func(): _build_main_menu()))
