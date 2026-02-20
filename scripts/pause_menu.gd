## pause_menu.gd
## 暂停/标题菜单 V5 - 回到主菜单 + 语言切换即时刷新
extends Node2D

signal resume_game()
signal new_game()
signal quit_game()
signal continue_game()
signal return_to_title()
signal language_changed()

const SCREEN_W: float = 3840.0
const SCREEN_H: float = 2160.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

const MENU_W: float = 1000.0
const MENU_H: float = 1400.0
const BTN_W: float = 720.0
const BTN_H: float = 104.0
const BTN_SPACING: float = 128.0

enum MenuMode { TITLE, PAUSE }
var mode: MenuMode = MenuMode.PAUSE

enum SubPanel { NONE, SETTINGS, COLLECTION, TUTORIAL }
var current_panel: SubPanel = SubPanel.NONE

## 收藏页分类标签
enum CollTab { BEASTS, CONSTELLATIONS, ARTIFACTS }
var coll_tab: CollTab = CollTab.BEASTS

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
			Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2 + 40),
			84, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, MENU_W))
		var line = ColorRect.new()
		line.position = Vector2(CENTER_X - 240, CENTER_Y - MENU_H/2 + 156)
		line.size = Vector2(480, 4)
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

	var start_y = CENTER_Y - MENU_H/2 + (220 if mode == MenuMode.PAUSE else 120)
	for i in range(buttons.size()):
		add_child(_make_button(buttons[i]["text"],
			Vector2(CENTER_X - BTN_W/2, start_y + i * BTN_SPACING),
			44, BTN_W, BTN_H, buttons[i]["callback"]))

	add_child(_make_label(GameConfig.VERSION_LABEL,
		Vector2(CENTER_X - MENU_W/2, CENTER_Y + MENU_H/2 - 80),
		24, Color(0.4, 0.4, 0.35), HORIZONTAL_ALIGNMENT_CENTER, MENU_W))

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

	var start_y = CENTER_Y - MENU_H/2 + 260
	var cats = [
		{"label": _t("Master Volume"), "value": master_volume},
		{"label": _t("SFX Volume"), "value": sfx_volume},
		{"label": _t("Music Volume"), "value": music_volume},
	]
	for ci in range(cats.size()):
		var y = start_y + ci * 160
		add_child(_make_label(cats[ci]["label"], Vector2(CENTER_X - 360, y), 36, Color(0.85, 0.85, 0.8)))

		var slider = HSlider.new()
		slider.min_value = 0.0; slider.max_value = 1.0; slider.step = 0.05
		slider.value = cats[ci]["value"]
		slider.position = Vector2(CENTER_X - 360, y + 56)
		slider.custom_minimum_size = Vector2(720, 40)
		var idx = ci
		slider.value_changed.connect(func(v): _on_volume_changed(idx, v))
		add_child(slider)

		var val_lbl = _make_label(str(int(cats[ci]["value"] * 100)) + "%",
			Vector2(CENTER_X + 400, y + 50), 32, Color(0.95, 0.85, 0.3))
		val_lbl.name = "VolLabel" + str(ci)
		add_child(val_lbl)

	var lang_y = start_y + 3 * 160
	add_child(_make_label(_t("Language"), Vector2(CENTER_X - 360, lang_y), 36, Color(0.85, 0.85, 0.8)))
	add_child(_make_button("  " + _loc().current_language + "  ▼",
		Vector2(CENTER_X - 360, lang_y + 56), 32, 400, 72, _cycle_language))

	add_child(_make_label(_t("Graphics settings coming soon..."),
		Vector2(CENTER_X - 360, start_y + 4 * 160), 28, Color(0.5, 0.5, 0.45)))
	_add_back_button()

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

## ========== 收藏 ==========

func _open_collection() -> void:
	_clear(); current_panel = SubPanel.COLLECTION; _add_bg()
	_add_sub_header(_t("COLLECTION"))

	## — 分类标签按钮 —
	var tab_y = CENTER_Y - MENU_H/2 + 180
	var tabs = [
		{"label": "🐉 " + _t("Beast Cards"), "tab": CollTab.BEASTS, "color": Color(0.3, 0.9, 0.4)},
		{"label": "⭐ " + _t("Constellation Cards"), "tab": CollTab.CONSTELLATIONS, "color": Color(0.2, 0.55, 0.85)},
		{"label": "🔮 " + _t("Artifact Cards"), "tab": CollTab.ARTIFACTS, "color": Color(0.7, 0.35, 0.75)},
	]
	var tab_w = 280.0
	var tab_total = tabs.size() * tab_w + (tabs.size() - 1) * 16
	var tab_start_x = CENTER_X - tab_total / 2.0
	for i in range(tabs.size()):
		var tx = tab_start_x + i * (tab_w + 16)
		var is_active = (tabs[i]["tab"] == coll_tab)
		var btn = Button.new()
		btn.text = tabs[i]["label"]
		btn.position = Vector2(tx, tab_y)
		btn.custom_minimum_size = Vector2(tab_w, 56)
		_loc().apply_font_to_button(btn, 22)
		if is_active:
			btn.add_theme_color_override("font_color", tabs[i]["color"])
		else:
			btn.add_theme_color_override("font_color", Color(0.45, 0.45, 0.4))
		var tab_val = tabs[i]["tab"]
		btn.pressed.connect(func(): _switch_coll_tab(tab_val))
		add_child(btn)

	## — 滚动内容区域 —
	var content_y = tab_y + 72
	var content_h = MENU_H - (content_y - (CENTER_Y - MENU_H/2)) - 130  ## 留空给返回按钮
	var panel_left = CENTER_X - MENU_W/2 + 20
	var panel_inner_w = MENU_W - 40

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(panel_left, content_y)
	scroll.size = Vector2(panel_inner_w, content_h)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(panel_inner_w - 20, 0)
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	## — 填充当前分类的卡牌 —
	match coll_tab:
		CollTab.BEASTS:
			_fill_beast_cards(vbox, panel_inner_w - 20)
		CollTab.CONSTELLATIONS:
			_fill_constellation_cards(vbox, panel_inner_w - 20)
		CollTab.ARTIFACTS:
			_fill_artifact_cards(vbox, panel_inner_w - 20)

	_add_back_button()

func _switch_coll_tab(tab: CollTab) -> void:
	coll_tab = tab
	_open_collection()

func _fill_beast_cards(parent: Control, width: float) -> void:
	var all_jokers = JokerDatabase.get_all_jokers()
	var owned_ids: Array = []
	if joker_slot_ref:
		for j in joker_slot_ref.get_owned_jokers(): owned_ids.append(j.id)

	## 按稀有度分组
	var groups = {"Common": [], "Uncommon": [], "Rare": [], "Legendary": []}
	for joker in all_jokers:
		var rname = joker.get_rarity_name()
		if groups.has(rname):
			groups[rname].append(joker)
		else:
			groups["Common"].append(joker)

	var rarity_colors = {
		"Common": Color(0.3, 0.9, 0.4),
		"Uncommon": Color(0.3, 0.6, 0.95),
		"Rare": Color(0.9, 0.3, 0.3),
		"Legendary": Color(0.95, 0.8, 0.2),
	}
	var rarity_labels = {
		"Common": _t("Common"), "Uncommon": _t("Uncommon"),
		"Rare": _t("Rare"), "Legendary": _t("Legendary"),
	}

	for rarity in ["Common", "Uncommon", "Rare", "Legendary"]:
		var cards = groups[rarity]
		if cards.is_empty(): continue
		## 稀有度标题
		var header = Label.new()
		header.text = "── " + rarity_labels[rarity] + " (" + str(cards.size()) + ") ──"
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.custom_minimum_size = Vector2(width, 0)
		header.add_theme_font_size_override("font_size", 22)
		header.add_theme_color_override("font_color", rarity_colors[rarity])
		_loc().apply_font_to_label(header)
		parent.add_child(header)

		## 卡牌网格
		for joker in cards:
			var c = Color(0.85, 0.85, 0.8) if joker.id in owned_ids else Color(0.35, 0.35, 0.3)
			var lbl = Label.new()
			lbl.text = joker.emoji + " " + _t(joker.joker_name)
			lbl.add_theme_font_size_override("font_size", 20)
			lbl.add_theme_color_override("font_color", c)
			_loc().apply_font_to_label(lbl)
			parent.add_child(lbl)

func _fill_constellation_cards(parent: Control, width: float) -> void:
	var all_planets = PlanetDatabase.get_all_planets()
	## 按四象分组（每7张一组）
	var groups = [
		{"name": _t("Azure Dragon (East)"), "emoji": "🐉", "color": Color(0.2, 0.7, 0.4), "cards": []},
		{"name": _t("White Tiger (West)"), "emoji": "🐯", "color": Color(0.8, 0.8, 0.8), "cards": []},
		{"name": _t("Vermillion Bird (South)"), "emoji": "🐦", "color": Color(0.9, 0.3, 0.3), "cards": []},
		{"name": _t("Black Tortoise (North)"), "emoji": "🐢", "color": Color(0.3, 0.4, 0.7), "cards": []},
	]
	for i in range(all_planets.size()):
		var group_idx = i / 7
		if group_idx < groups.size():
			groups[group_idx]["cards"].append(all_planets[i])

	for group in groups:
		if group["cards"].is_empty(): continue
		var header = Label.new()
		header.text = group["emoji"] + " " + group["name"] + " (" + str(group["cards"].size()) + ")"
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.custom_minimum_size = Vector2(width, 0)
		header.add_theme_font_size_override("font_size", 22)
		header.add_theme_color_override("font_color", group["color"])
		_loc().apply_font_to_label(header)
		parent.add_child(header)

		for planet in group["cards"]:
			var hand_name = _t(PokerHand.get_hand_name(planet.hand_type))
			var lbl = Label.new()
			lbl.text = planet.emoji + " " + _t(planet.planet_name) + "  →  " + hand_name
			lbl.add_theme_font_size_override("font_size", 20)
			lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.7))
			_loc().apply_font_to_label(lbl)
			parent.add_child(lbl)

func _fill_artifact_cards(parent: Control, width: float) -> void:
	var all_tarots = TarotDatabase.get_all_tarots()
	## 按类型分组
	var relics: Array = []
	var formations: Array = []
	for t in all_tarots:
		if t.artifact_type == TarotData.ArtifactType.RELIC:
			relics.append(t)
		else:
			formations.append(t)

	var sections = [
		{"name": _t("Relics"), "emoji": "⚱️", "color": Color(0.7, 0.35, 0.75), "cards": relics},
		{"name": _t("Formations"), "emoji": "⚔️", "color": Color(0.85, 0.25, 0.25), "cards": formations},
	]
	for section in sections:
		if section["cards"].is_empty(): continue
		var header = Label.new()
		header.text = section["emoji"] + " " + section["name"] + " (" + str(section["cards"].size()) + ")"
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.custom_minimum_size = Vector2(width, 0)
		header.add_theme_font_size_override("font_size", 22)
		header.add_theme_color_override("font_color", section["color"])
		_loc().apply_font_to_label(header)
		parent.add_child(header)

		for tarot in section["cards"]:
			var lbl = Label.new()
			lbl.text = tarot.emoji + " " + _t(tarot.tarot_name) + " - " + _t(tarot.description)
			lbl.add_theme_font_size_override("font_size", 18)
			lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.7))
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl.custom_minimum_size = Vector2(width, 0)
			_loc().apply_font_to_label(lbl)
			parent.add_child(lbl)

## ========== 教程 ==========

func _open_tutorial() -> void:
	_clear(); current_panel = SubPanel.TUTORIAL; _add_bg()
	_add_sub_header(_t("HOW TO PLAY"))
	var sy = CENTER_Y - MENU_H/2 + 260
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
	for i in range(tuts.size()):
		var y = sy + i * 96
		add_child(_make_label(tuts[i][0], Vector2(CENTER_X - 440, y), 32, Color(0.95, 0.85, 0.3)))
		add_child(_make_label(tuts[i][1], Vector2(CENTER_X - 440, y + 44), 24, Color(0.65, 0.65, 0.6)))
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

	var bw = 4.0; var bc = Color(0.95, 0.85, 0.3, 0.3)
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
	add_child(_make_label(text, Vector2(CENTER_X - MENU_W/2, CENTER_Y - MENU_H/2 + 40),
		72, Color(0.95, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, MENU_W))
	var line = ColorRect.new()
	line.position = Vector2(CENTER_X - 200, CENTER_Y - MENU_H/2 + 136)
	line.size = Vector2(400, 4); line.color = Color(0.95, 0.85, 0.3, 0.3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(line)

func _add_back_button() -> void:
	add_child(_make_button("  ← " + _t("Back") + "  ",
		Vector2(CENTER_X - 160, CENTER_Y + MENU_H/2 - 120), 36, 320, 84,
		func(): _build_main_menu()))
