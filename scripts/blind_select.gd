## blind_select.gd
## 盲注选择界面 V10 - 跳过奖励系统
extends Node2D

signal blind_selected(blind_type: int, boss_blind)
signal blind_skipped(skip_reward: String)  ## 跳过并带奖励类型

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0

const CARD_W: float = 260.0
const CARD_H: float = 350.0
const CARD_SPACING: float = 320.0
const CARDS_Y: float = 500.0

var ante: int = 1
var current_blind_index: int = 0
var current_boss: BlindData.BossBlind = null
var card_canvas: Node2D = null

func _t(key: String) -> String:
	return Loc.i().t(key)

func _apply_font(lbl: Label, size: int = -1) -> void:
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Loc.i().apply_font_to_label(lbl, size)

func _apply_font_btn(btn: Button, size: int = -1) -> void:
	Loc.i().apply_font_to_button(btn, size)

## 每个盲注的跳过奖励（Ante开始时随机生成）
var skip_rewards: Array = []  ## [small_reward, big_reward]

## 可能的跳过奖励
const REWARD_TYPES = [
	{"id": "tarot", "name": "Free Tarot", "emoji": "🔮", "desc": "Receive a random Tarot card"},
	{"id": "planet", "name": "Free Planet", "emoji": "🪐", "desc": "Receive a random Planet card"},
	{"id": "money", "name": "$3 Bonus", "emoji": "💰", "desc": "Receive $3"},
	{"id": "level_up", "name": "Level Up", "emoji": "⬆️", "desc": "Random hand type +1 level"},
]

func _ready() -> void:
	visible = false

func open_select(current_ante: int, blind_index: int, boss: BlindData.BossBlind) -> void:
	ante = current_ante
	current_blind_index = blind_index
	current_boss = boss
	## 每个 Ante 开始时生成跳过奖励
	if blind_index == 0:
		_generate_skip_rewards()
	visible = true
	_build_ui()

func _generate_skip_rewards() -> void:
	skip_rewards.clear()
	var pool = REWARD_TYPES.duplicate()
	pool.shuffle()
	skip_rewards.append(pool[0])  ## Small Blind skip reward
	skip_rewards.append(pool[1])  ## Big Blind skip reward

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()
	card_canvas = null

	var bg = ColorRect.new()
	bg.position = Vector2(0, 0)
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	bg.color = Color(0.04, 0.08, 0.06, 0.97)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var title = Label.new()
	title.text = _t("ANTE") + " " + str(ante)
	title.position = Vector2(0, 40)
	title.custom_minimum_size = Vector2(SCREEN_W, 0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_apply_font(title)
	add_child(title)

	var progress_text = ""
	for i in range(3):
		if i < current_blind_index:
			progress_text += "✓ "
		elif i == current_blind_index:
			progress_text += "► "
		else:
			progress_text += "○ "
	var progress = Label.new()
	progress.text = progress_text
	progress.position = Vector2(0, 100)
	progress.custom_minimum_size = Vector2(SCREEN_W, 0)
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_theme_font_size_override("font_size", 28)
	progress.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(progress)

	card_canvas = Node2D.new()
	card_canvas.name = "CardCanvas"
	add_child(card_canvas)

	var blinds_info = _get_blinds_info()
	var start_x = CENTER_X - CARD_SPACING

	for i in range(3):
		var x = start_x + i * CARD_SPACING
		var info = blinds_info[i]
		var is_current = (i == current_blind_index)
		var is_completed = (i < current_blind_index)
		_build_blind_card(x, info, is_current, is_completed)

	var current_info = blinds_info[current_blind_index]
	var btn_y = 760.0

	var play_btn = Button.new()
	play_btn.text = "   " + _t("Play") + " " + _t(current_info["name"]) + "   "
	play_btn.position = Vector2(CENTER_X - 150, btn_y)
	play_btn.custom_minimum_size = Vector2(300, 0)
	_apply_font_btn(play_btn, 24)
	play_btn.pressed.connect(_on_play_current)
	add_child(play_btn)

	## Skip 按钮 + 奖励提示（Boss 不可跳过）
	if current_blind_index < 2 and current_blind_index < skip_rewards.size():
		var reward = skip_rewards[current_blind_index]

		var skip_btn = Button.new()
		skip_btn.text = "   " + _t("Skip") + " →   "
		skip_btn.position = Vector2(CENTER_X - 80, btn_y + 50)
		skip_btn.custom_minimum_size = Vector2(160, 0)
		_apply_font_btn(skip_btn, 18)
		skip_btn.pressed.connect(_on_skip_current)
		add_child(skip_btn)

		## 跳过奖励标签
		var reward_label = Label.new()
		reward_label.text = reward["emoji"] + " " + _t("Skip reward") + ": " + _t(reward["name"])
		reward_label.position = Vector2(0, btn_y + 90)
		reward_label.custom_minimum_size = Vector2(SCREEN_W, 0)
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_apply_font(reward_label, 16)
		reward_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.95))
		add_child(reward_label)

		var reward_desc = Label.new()
		reward_desc.text = _t(reward["desc"])
		reward_desc.position = Vector2(0, btn_y + 112)
		reward_desc.custom_minimum_size = Vector2(SCREEN_W, 0)
		reward_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_apply_font(reward_desc, 13)
		reward_desc.add_theme_color_override("font_color", Color(0.45, 0.65, 0.75))
		add_child(reward_desc)

func _get_blinds_info() -> Array:
	return [
		{"type": BlindData.BlindType.SMALL_BLIND, "name": "Small Blind", "emoji": "🔵",
		 "color": Color(0.25, 0.45, 0.8), "desc": "Standard game"},
		{"type": BlindData.BlindType.BIG_BLIND, "name": "Big Blind", "emoji": "🟠",
		 "color": Color(0.8, 0.55, 0.15), "desc": "1.5× score target"},
		{"type": BlindData.BlindType.BOSS_BLIND, "name": current_boss.name if current_boss else "Boss",
		 "emoji": current_boss.emoji if current_boss else "💀",
		 "color": Color(0.8, 0.2, 0.2),
		 "desc": current_boss.description if current_boss else "???"},
	]

func _build_blind_card(x: float, info: Dictionary, is_current: bool, is_completed: bool) -> void:
	var target = BlindData.get_blind_target(ante, info["type"])
	var reward = BlindData.get_blind_reward(info["type"])

	var alpha = 1.0 if is_current else (0.4 if is_completed else 0.6)
	var bg_color = Color(0.1, 0.13, 0.17, alpha)
	if is_completed:
		bg_color = Color(0.08, 0.15, 0.08, 0.5)

	var bg = ColorRect.new()
	bg.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2)
	bg.size = Vector2(CARD_W, CARD_H)
	bg.color = bg_color
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_canvas.add_child(bg)

	var border_color = info["color"]
	if is_completed:
		border_color = Color(0.3, 0.6, 0.3, 0.6)
	elif not is_current:
		border_color = Color(border_color.r, border_color.g, border_color.b, 0.5)

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
		border.color = border_color
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_canvas.add_child(border)

	var txt_alpha = 1.0 if is_current else (0.5 if is_completed else 0.6)

	if is_completed:
		var check = Label.new()
		check.text = "✓"
		check.position = Vector2(x - CARD_W / 2, CARDS_Y - 40)
		check.custom_minimum_size = Vector2(CARD_W, 0)
		check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		check.add_theme_font_size_override("font_size", 60)
		check.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3, 0.7))
		check.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_canvas.add_child(check)
		return

	var emoji_lbl = Label.new()
	emoji_lbl.text = info["emoji"]
	emoji_lbl.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 20)
	emoji_lbl.custom_minimum_size = Vector2(CARD_W, 0)
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.add_theme_font_size_override("font_size", 50)
	emoji_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_canvas.add_child(emoji_lbl)

	var name_lbl = Label.new()
	name_lbl.text = _t(info["name"])
	name_lbl.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 100)
	name_lbl.custom_minimum_size = Vector2(CARD_W, 0)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.9, txt_alpha))
	_apply_font(name_lbl, 22)
	card_canvas.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = _t(info["desc"])
	desc_lbl.position = Vector2(x - CARD_W / 2 + 10, CARDS_Y - CARD_H / 2 + 130)
	desc_lbl.custom_minimum_size = Vector2(CARD_W - 20, 0)
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.6, txt_alpha))
	_apply_font(desc_lbl, 14)
	card_canvas.add_child(desc_lbl)

	var target_title = Label.new()
	target_title.text = _t("Target")
	target_title.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 180)
	target_title.custom_minimum_size = Vector2(CARD_W, 0)
	target_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_title.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45, txt_alpha))
	_apply_font(target_title, 14)
	card_canvas.add_child(target_title)

	var target_lbl = Label.new()
	target_lbl.text = str(target)
	target_lbl.position = Vector2(x - CARD_W / 2, CARDS_Y - CARD_H / 2 + 200)
	target_lbl.custom_minimum_size = Vector2(CARD_W, 0)
	target_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_lbl.add_theme_font_size_override("font_size", 36)
	target_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tc = Color(0.9, 0.3, 0.3, txt_alpha) if is_current else Color(0.7, 0.4, 0.4, txt_alpha)
	target_lbl.add_theme_color_override("font_color", tc)
	card_canvas.add_child(target_lbl)

	var reward_lbl = Label.new()
	reward_lbl.text = _t("Reward") + ": $" + str(reward)
	reward_lbl.position = Vector2(x - CARD_W / 2 + 10, CARDS_Y - CARD_H / 2 + 270)
	reward_lbl.custom_minimum_size = Vector2(CARD_W - 20, 0)
	reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_lbl.add_theme_font_size_override("font_size", 16)
	reward_lbl.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2, txt_alpha))
	_apply_font(reward_lbl, 16)
	card_canvas.add_child(reward_lbl)

	## 在非Boss盲注卡片底部显示跳过奖励预览
	if info["type"] != BlindData.BlindType.BOSS_BLIND:
		var skip_idx = 0 if info["type"] == BlindData.BlindType.SMALL_BLIND else 1
		if skip_idx < skip_rewards.size():
			var sr = skip_rewards[skip_idx]
			var skip_lbl = Label.new()
			skip_lbl.text = _t("Skip") + ": " + sr["emoji"] + " " + _t(sr["name"])
			skip_lbl.position = Vector2(x - CARD_W / 2 + 10, CARDS_Y - CARD_H / 2 + 305)
			skip_lbl.custom_minimum_size = Vector2(CARD_W - 20, 0)
			skip_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			skip_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.95, txt_alpha * 0.8))
			_apply_font(skip_lbl, 13)
			card_canvas.add_child(skip_lbl)

func _on_play_current() -> void:
	var blind_type: BlindData.BlindType
	match current_blind_index:
		0: blind_type = BlindData.BlindType.SMALL_BLIND
		1: blind_type = BlindData.BlindType.BIG_BLIND
		2: blind_type = BlindData.BlindType.BOSS_BLIND
		_: blind_type = BlindData.BlindType.SMALL_BLIND

	var boss = current_boss if blind_type == BlindData.BlindType.BOSS_BLIND else null
	visible = false
	blind_selected.emit(blind_type, boss)

func _on_skip_current() -> void:
	var reward_id = ""
	var reward_info = null
	if current_blind_index < skip_rewards.size():
		reward_info = skip_rewards[current_blind_index]
		reward_id = reward_info["id"]
	if reward_info:
		_play_skip_reward_animation(reward_info, reward_id)
	else:
		visible = false
		blind_skipped.emit(reward_id)

## ========== 跳过奖励动画 ==========

var anim_active: bool = false
var anim_timer: float = 0.0
var anim_reward_info: Dictionary = {}
var anim_reward_id: String = ""
var anim_confetti: Array = []
const ANIM_DURATION: float = 3.5

func _play_skip_reward_animation(reward_info: Dictionary, reward_id: String) -> void:
	anim_reward_info = reward_info
	anim_reward_id = reward_id
	anim_active = true
	anim_timer = 0.0
	## 清除盲注界面的所有子节点，让 _draw 动画完全可见
	for child in get_children():
		child.queue_free()
	card_canvas = null
	## 生成彩带粒子
	anim_confetti.clear()
	for i in range(80):
		var confetti = {
			"pos": Vector2(randf_range(100, SCREEN_W - 100), randf_range(-200, -50)),
			"vel": Vector2(randf_range(-80, 80), randf_range(150, 400)),
			"rot": randf() * TAU,
			"rot_speed": randf_range(-5, 5),
			"color": [
				Color(1.0, 0.3, 0.3), Color(0.3, 0.8, 1.0), Color(1.0, 0.85, 0.2),
				Color(0.4, 1.0, 0.4), Color(1.0, 0.5, 0.8), Color(0.6, 0.4, 1.0)
			][randi() % 6],
			"size": Vector2(randf_range(4, 12), randf_range(8, 20)),
			"delay": randf_range(0, 0.5),
		}
		anim_confetti.append(confetti)

func _process(delta: float) -> void:
	if not anim_active:
		return
	anim_timer += delta
	## 更新彩带
	for c in anim_confetti:
		if anim_timer > c["delay"]:
			c["pos"] += c["vel"] * delta
			c["vel"].x += randf_range(-20, 20) * delta
			c["rot"] += c["rot_speed"] * delta
	queue_redraw()
	## 动画结束
	if anim_timer >= ANIM_DURATION:
		anim_active = false
		anim_confetti.clear()
		visible = false
		blind_skipped.emit(anim_reward_id)

func _draw() -> void:
	if not anim_active:
		return

	## 暗色遮罩覆盖盲注背景
	var mask_alpha = clampf(anim_timer / 0.3, 0.0, 0.85)
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0.02, 0.04, 0.06, mask_alpha))

	## 奖励卡牌缩放动画：从0缩放到1.5倍大盲注卡牌尺寸
	var scale_progress = clampf(anim_timer / 0.6, 0.0, 1.0)
	## ease out back 弹性缓动
	var t = 1.0 - pow(1.0 - scale_progress, 3.0)
	if scale_progress < 1.0:
		t = t * (1.0 + 0.3 * sin(t * PI))

	var target_w = CARD_W * 1.5
	var target_h = CARD_H * 1.5
	var card_w = target_w * t
	var card_h = target_h * t

	if card_w > 2 and card_h > 2:
		var cx = CENTER_X
		var cy = 450.0
		var card_rect = Rect2(cx - card_w / 2, cy - card_h / 2, card_w, card_h)

		## 卡牌背景
		draw_rect(card_rect, Color(0.12, 0.15, 0.2, 0.95))

		## 边框
		var border_color = Color(0.5, 0.8, 0.95)
		var bw = 3.0
		draw_rect(Rect2(card_rect.position, Vector2(card_rect.size.x, bw)), border_color)
		draw_rect(Rect2(card_rect.position + Vector2(0, card_rect.size.y - bw), Vector2(card_rect.size.x, bw)), border_color)
		draw_rect(Rect2(card_rect.position, Vector2(bw, card_rect.size.y)), border_color)
		draw_rect(Rect2(card_rect.position + Vector2(card_rect.size.x - bw, 0), Vector2(bw, card_rect.size.y)), border_color)

		## 奖励内容（仅在缩放完成后淡入）
		var text_alpha = clampf((anim_timer - 0.4) / 0.3, 0.0, 1.0)
		if text_alpha > 0.01:
			var font = Loc.i().cn_font
			var emoji = anim_reward_info.get("emoji", "🎁")
			var reward_name = _t(anim_reward_info.get("name", "Reward"))
			var reward_desc = _t(anim_reward_info.get("desc", ""))

			## Emoji
			_draw_centered_text(emoji, cx, cy - card_h * 0.2, 50, Color(1, 1, 1, text_alpha), font)
			## 名称
			_draw_centered_text(reward_name, cx, cy + card_h * 0.05, 26, Color(0.95, 0.85, 0.4, text_alpha), font)
			## 描述
			_draw_centered_text(reward_desc, cx, cy + card_h * 0.2, 16, Color(0.7, 0.7, 0.65, text_alpha), font)
			## 跳过奖励标签
			_draw_centered_text(_t("Skip reward") + "!", cx, cy - card_h * 0.38, 18, Color(0.5, 0.8, 0.95, text_alpha), font)

	## 绘制彩带
	for c in anim_confetti:
		if anim_timer > c["delay"]:
			var alpha = clampf(1.0 - (anim_timer - ANIM_DURATION + 0.5) / 0.5, 0.0, 1.0)
			var col = Color(c["color"].r, c["color"].g, c["color"].b, alpha * 0.9)
			var sz = c["size"]
			draw_rect(Rect2(c["pos"] - sz / 2, sz), col)

func _draw_centered_text(text: String, cx: float, cy: float, size: int, color: Color, font_res) -> void:
	var f = font_res if font_res else ThemeDB.fallback_font
	if f == null:
		return
	var tw = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(f, Vector2(cx - tw / 2, cy + size * 0.4), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
