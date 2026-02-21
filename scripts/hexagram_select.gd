## hexagram_select.gd
## 64卦路线选择界面 V0.086 — 变爻分岔路线 + 四象归属
## 在每个 Ante 开始时显示，玩家从2-3个卦象中选择
extends Node2D

signal hexagram_selected(kingwen: int)

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0

const CARD_W: float = 280.0
const CARD_H: float = 400.0
const CARD_SPACING: float = 340.0
const CARDS_Y: float = 520.0

## 当前路线状态
var route_history: Array[int] = []  ## 已选卦的文王序
var current_step: int = 0           ## 当前步骤 (0-7)
var branches: Array[int] = []       ## 当前可选分岔

## 六爻变化动画
var selected_kingwen: int = -1
var anim_active: bool = false
var anim_timer: float = 0.0
const ANIM_DURATION: float = 2.0

func _t(key: String) -> String:
	return Loc.i().t(key)

func _apply_font(lbl: Label, size: int = -1) -> void:
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Loc.i().apply_font_to_label(lbl, size)

func _ready() -> void:
	visible = false

## 开始新的路线选择（整局游戏开始时）
func start_new_route() -> void:
	route_history.clear()
	current_step = 0
	selected_kingwen = -1
	anim_active = false
	_generate_branches()
	visible = true
	_build_ui()

## 进入下一步选择（Ante推进时）
func advance_step() -> void:
	current_step = route_history.size()
	if current_step >= 8:
		return
	selected_kingwen = -1
	anim_active = false
	_generate_branches()
	visible = true
	_build_ui()

## 生成当前步骤的分岔选项
func _generate_branches() -> void:
	if current_step == 0:
		## 第一步：从难度1的8个卦中随机选2-3个
		var tier1 = HexagramDatabase.get_hexagrams_by_difficulty(1)
		tier1.shuffle()
		branches = []
		for i in range(mini(3, tier1.size())):
			branches.append(tier1[i])
	else:
		## 后续步骤：从上一个卦的变爻邻居中筛选
		var prev = route_history[current_step - 1]
		branches = HexagramDatabase.get_route_branches(prev, true, true, 2, 3)
		## 确保至少有2个选项
		if branches.size() < 2:
			var target_diff = mini(current_step + 1, 8)
			var pool = HexagramDatabase.get_hexagrams_by_difficulty(target_diff)
			pool.shuffle()
			for kw in pool:
				if not branches.has(kw):
					branches.append(kw)
				if branches.size() >= 2:
					break

## 获取当前路线的四象计数
func get_sixiang_counts() -> Dictionary:
	var counts := {
		HexagramDatabase.SiXiang.QINGLONG: 0,
		HexagramDatabase.SiXiang.ZHUQUE: 0,
		HexagramDatabase.SiXiang.BAIHU: 0,
		HexagramDatabase.SiXiang.XUANWU: 0,
	}
	for kw in route_history:
		var sx = HexagramDatabase.get_sixiang(kw)
		counts[sx] += 1
	return counts

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	## 背景
	var bg = ColorRect.new()
	bg.position = Vector2.ZERO
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	bg.color = Color(0.03, 0.06, 0.08, 0.97)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	## 标题
	var diff = current_step + 1
	var diff_name = HexagramDatabase.get_difficulty_name(diff)
	var title = Label.new()
	title.text = _t("Choose Hexagram") + " — " + _t("Step") + " " + str(diff) + "/8"
	title.position = Vector2(0, 30)
	title.custom_minimum_size = Vector2(SCREEN_W, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_apply_font(title)
	add_child(title)

	## 难度等级名称
	var diff_label = Label.new()
	diff_label.text = _t(diff_name)
	diff_label.position = Vector2(0, 80)
	diff_label.custom_minimum_size = Vector2(SCREEN_W, 0)
	diff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diff_label.add_theme_font_size_override("font_size", 20)
	diff_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	_apply_font(diff_label)
	add_child(diff_label)

	## 路线进度条
	_build_progress_bar()

	## 四象计数
	_build_sixiang_counter()

	## 卦象选择卡牌
	var count = branches.size()
	var total_w = (count - 1) * CARD_SPACING
	var start_x = CENTER_X - total_w / 2.0

	for i in range(count):
		var x = start_x + i * CARD_SPACING
		var kw = branches[i]
		_build_hexagram_card(x, kw, i)

## 路线进度条（显示已选的卦 + 当前步骤）
func _build_progress_bar() -> void:
	var bar_y = 130.0
	var dot_spacing = 90.0
	var bar_start_x = CENTER_X - 3.5 * dot_spacing

	for i in range(8):
		var x = bar_start_x + i * dot_spacing
		var is_completed = i < current_step
		var is_current = i == current_step

		## 连接线
		if i > 0:
			var line = ColorRect.new()
			line.position = Vector2(x - dot_spacing + 16, bar_y + 12)
			line.size = Vector2(dot_spacing - 32, 3)
			line.color = Color(0.3, 0.5, 0.3, 0.8) if is_completed or is_current else Color(0.2, 0.2, 0.2, 0.5)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(line)

		if is_completed:
			## 已选卦 — 显示卦名和四象颜色
			var kw = route_history[i]
			var data = HexagramDatabase.get_hexagram(kw)
			var sx_color = HexagramDatabase.get_sixiang_color(kw)

			var dot = ColorRect.new()
			dot.position = Vector2(x - 14, bar_y)
			dot.size = Vector2(28, 28)
			dot.color = sx_color
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(dot)

			var name_lbl = Label.new()
			name_lbl.text = _t(data.get("name", "?"))
			name_lbl.position = Vector2(x - 30, bar_y + 32)
			name_lbl.custom_minimum_size = Vector2(60, 0)
			name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_lbl.add_theme_font_size_override("font_size", 14)
			name_lbl.add_theme_color_override("font_color", sx_color)
			name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_apply_font(name_lbl, 14)
			add_child(name_lbl)
		elif is_current:
			## 当前步骤 — 闪烁指示
			var dot = ColorRect.new()
			dot.position = Vector2(x - 16, bar_y - 2)
			dot.size = Vector2(32, 32)
			dot.color = Color(0.95, 0.85, 0.4, 0.9)
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(dot)

			var lbl = Label.new()
			lbl.text = "?"
			lbl.position = Vector2(x - 30, bar_y + 32)
			lbl.custom_minimum_size = Vector2(60, 0)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 14)
			lbl.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
			lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(lbl)
		else:
			## 未来步骤 — 灰色空心
			var dot = ColorRect.new()
			dot.position = Vector2(x - 10, bar_y + 4)
			dot.size = Vector2(20, 20)
			dot.color = Color(0.15, 0.15, 0.15, 0.6)
			dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(dot)

## 四象计数（显示在右上角）
func _build_sixiang_counter() -> void:
	var counts = get_sixiang_counts()
	var sx_list = [
		HexagramDatabase.SiXiang.QINGLONG,
		HexagramDatabase.SiXiang.ZHUQUE,
		HexagramDatabase.SiXiang.BAIHU,
		HexagramDatabase.SiXiang.XUANWU,
	]
	var base_x = SCREEN_W - 200.0
	var base_y = 30.0

	for i in range(4):
		var sx = sx_list[i]
		var color = HexagramDatabase.SIXIANG_COLORS[sx]
		var sx_name = HexagramDatabase.SIXIANG_NAMES[sx]
		var emoji = HexagramDatabase.SIXIANG_EMOJIS[sx]
		var count = counts[sx]

		var lbl = Label.new()
		lbl.text = emoji + " " + _t(sx_name) + ": " + str(count)
		lbl.position = Vector2(base_x, base_y + i * 26)
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_color", color)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_font(lbl, 16)
		add_child(lbl)

## 构建单个卦象选择卡牌
func _build_hexagram_card(x: float, kingwen: int, _index: int) -> void:
	var data = HexagramDatabase.get_hexagram(kingwen)
	if data.is_empty():
		return

	var sx_color = HexagramDatabase.get_sixiang_color(kingwen)
	var trigrams = HexagramDatabase.get_trigram_names(kingwen)

	## 卡牌背景
	var bg = ColorRect.new()
	bg.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2)
	bg.size = Vector2(CARD_W, CARD_H)
	bg.color = Color(0.08, 0.1, 0.14, 0.95)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	## 四象色边框
	var bw = 3.0
	for edge in [
		[Vector2(x - CARD_W/2, CARDS_Y - CARD_H/2), Vector2(CARD_W, bw)],
		[Vector2(x - CARD_W/2, CARDS_Y + CARD_H/2 - bw), Vector2(CARD_W, bw)],
		[Vector2(x - CARD_W/2, CARDS_Y - CARD_H/2), Vector2(bw, CARD_H)],
		[Vector2(x + CARD_W/2 - bw, CARDS_Y - CARD_H/2), Vector2(bw, CARD_H)],
	]:
		var border = ColorRect.new()
		border.position = edge[0]
		border.size = edge[1]
		border.color = sx_color
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)

	## 四象标签（左上角）
	var sx_emoji = HexagramDatabase.get_sixiang_emoji(kingwen)
	var sx_name = HexagramDatabase.get_sixiang_name(kingwen)
	var sx_lbl = Label.new()
	sx_lbl.text = sx_emoji + " " + _t(sx_name)
	sx_lbl.position = Vector2(x - CARD_W / 2 + 10, CARDS_Y - CARD_H / 2 + 8)
	sx_lbl.add_theme_font_size_override("font_size", 14)
	sx_lbl.add_theme_color_override("font_color", sx_color)
	sx_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(sx_lbl, 14)
	add_child(sx_lbl)

	## 难度标签（右上角）
	var diff_lbl = Label.new()
	diff_lbl.text = "D" + str(data["difficulty"])
	diff_lbl.position = Vector2(x + CARD_W / 2 - 40, CARDS_Y - CARD_H / 2 + 8)
	diff_lbl.add_theme_font_size_override("font_size", 14)
	diff_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
	diff_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(diff_lbl)

	## 上/下卦名
	var trigram_lbl = Label.new()
	trigram_lbl.text = trigrams["upper"] + " / " + trigrams["lower"]
	trigram_lbl.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 40)
	trigram_lbl.custom_minimum_size = Vector2(CARD_W, 0)
	trigram_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trigram_lbl.add_theme_font_size_override("font_size", 16)
	trigram_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	trigram_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(trigram_lbl, 16)
	add_child(trigram_lbl)

	## 六爻显示
	var yao_str = HexagramDatabase.get_yao_string(kingwen)
	var yao_y = CARDS_Y - CARD_H / 2 + 65
	for i in range(6):
		var yao_char = yao_str[i]
		var yao_lbl = Label.new()
		yao_lbl.text = yao_char
		yao_lbl.position = Vector2(x - CARD_W / 2, yao_y + i * 18)
		yao_lbl.custom_minimum_size = Vector2(CARD_W, 0)
		yao_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		yao_lbl.add_theme_font_size_override("font_size", 16)
		var yao_color = Color(0.9, 0.7, 0.2) if yao_char == "⚊" else Color(0.3, 0.4, 0.6)
		yao_lbl.add_theme_color_override("font_color", yao_color)
		yao_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(yao_lbl)

	## 卦名（大字）
	var name_lbl = Label.new()
	name_lbl.text = _t(data["name"])
	name_lbl.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 185)
	name_lbl.custom_minimum_size = Vector2(CARD_W, 0)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 36)
	name_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.9))
	_apply_font(name_lbl)
	add_child(name_lbl)

	## 卦德关键词
	var keyword_lbl = Label.new()
	keyword_lbl.text = "「" + _t(data["keyword"]) + "」"
	keyword_lbl.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 230)
	keyword_lbl.custom_minimum_size = Vector2(CARD_W, 0)
	keyword_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keyword_lbl.add_theme_font_size_override("font_size", 18)
	keyword_lbl.add_theme_color_override("font_color", sx_color)
	keyword_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(keyword_lbl, 18)
	add_child(keyword_lbl)

	## 分隔线
	var sep = ColorRect.new()
	sep.position = Vector2(x - CARD_W / 2 + 20, CARDS_Y - CARD_H / 2 + 260)
	sep.size = Vector2(CARD_W - 40, 1)
	sep.color = Color(0.3, 0.3, 0.3, 0.5)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sep)

	## 游戏效果
	var effect_lbl = Label.new()
	effect_lbl.text = _t(data["effect_desc"])
	effect_lbl.position = Vector2(x - CARD_W / 2 + 15, CARDS_Y - CARD_H / 2 + 272)
	effect_lbl.custom_minimum_size = Vector2(CARD_W - 30, 0)
	effect_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_lbl.add_theme_font_size_override("font_size", 15)
	effect_lbl.add_theme_color_override("font_color", Color(0.85, 0.75, 0.5))
	effect_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_font(effect_lbl, 15)
	add_child(effect_lbl)

	## 选择按钮
	var btn = Button.new()
	btn.text = "   " + _t("Select") + "   "
	btn.position = Vector2(x - 70, CARDS_Y + CARD_H / 2 + 15)
	btn.custom_minimum_size = Vector2(140, 0)
	Loc.i().apply_font_to_button(btn, 18)
	btn.pressed.connect(_on_select_hexagram.bind(kingwen))
	add_child(btn)

func _on_select_hexagram(kingwen: int) -> void:
	if anim_active:
		return
	selected_kingwen = kingwen
	route_history.append(kingwen)
	current_step += 1

	## 播放选择动画
	anim_active = true
	anim_timer = 0.0
	queue_redraw()

func _process(delta: float) -> void:
	if not anim_active:
		return
	anim_timer += delta
	queue_redraw()
	if anim_timer >= ANIM_DURATION:
		anim_active = false
		visible = false
		hexagram_selected.emit(selected_kingwen)

func _draw() -> void:
	if not anim_active or selected_kingwen < 0:
		return

	var data = HexagramDatabase.get_hexagram(selected_kingwen)
	if data.is_empty():
		return

	## 遮罩
	var mask_alpha = clampf(anim_timer / 0.3, 0.0, 0.92)
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0.02, 0.04, 0.06, mask_alpha))

	var sx_color = HexagramDatabase.get_sixiang_color(selected_kingwen)
	var font = Loc.i().cn_font

	## 卦名放大出现
	var scale_t = clampf(anim_timer / 0.5, 0.0, 1.0)
	var ease_t = 1.0 - pow(1.0 - scale_t, 3.0)

	if ease_t > 0.01:
		var name_size = int(80 * ease_t)
		var text_alpha = clampf(anim_timer / 0.4, 0.0, 1.0)
		_draw_centered_text(_t(data["name"]), CENTER_X, 380, name_size,
			Color(sx_color.r, sx_color.g, sx_color.b, text_alpha), font)

	## 关键词淡入
	var kw_alpha = clampf((anim_timer - 0.4) / 0.3, 0.0, 1.0)
	if kw_alpha > 0.01:
		_draw_centered_text("「" + _t(data["keyword"]) + "」", CENTER_X, 480, 24,
			Color(0.9, 0.85, 0.6, kw_alpha), font)

	## 效果描述淡入
	var eff_alpha = clampf((anim_timer - 0.7) / 0.3, 0.0, 1.0)
	if eff_alpha > 0.01:
		_draw_centered_text(_t(data["effect_desc"]), CENTER_X, 540, 20,
			Color(0.85, 0.75, 0.5, eff_alpha), font)

	## 四象归属
	var sx_alpha = clampf((anim_timer - 1.0) / 0.3, 0.0, 1.0)
	if sx_alpha > 0.01:
		var sx_emoji = HexagramDatabase.get_sixiang_emoji(selected_kingwen)
		var sx_name = HexagramDatabase.get_sixiang_name(selected_kingwen)
		_draw_centered_text(sx_emoji + " " + _t(sx_name), CENTER_X, 600, 18,
			Color(sx_color.r, sx_color.g, sx_color.b, sx_alpha), font)

func _draw_centered_text(text: String, cx: float, cy: float, size: int, color: Color, font_res) -> void:
	var f = font_res if font_res else ThemeDB.fallback_font
	if f == null:
		return
	var tw = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(f, Vector2(cx - tw / 2, cy + size * 0.4), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

## 获取完整路线历史
func get_route() -> Array[int]:
	return route_history

## 获取当前卦象的效果ID
func get_current_effect_id() -> String:
	if route_history.is_empty():
		return ""
	var last = route_history[-1]
	var data = HexagramDatabase.get_hexagram(last)
	return data.get("effect_id", "")

## 重置路线（新游戏）
func reset() -> void:
	route_history.clear()
	current_step = 0
	branches.clear()
	selected_kingwen = -1
	anim_active = false
	visible = false
