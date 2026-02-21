## boss_beat_ui.gd
## Boss战节拍计时器UI V0.086 — 显示节拍指示器 + 计时条 + 判定反馈
extends Node2D

## ========== 布局常量 ==========
const BAR_X: float = 400.0         ## 计时条左边缘X
const BAR_Y: float = 1010.0        ## 计时条Y
const BAR_W: float = 1120.0        ## 计时条宽度
const BAR_H: float = 12.0          ## 计时条高度
const BEAT_DOT_Y: float = 990.0    ## 拍点Y
const BPM_LABEL_Y: float = 978.0   ## BPM标签Y
const BONUS_INFO_Y: float = 1030.0 ## Bonus信息Y

## 判定反馈
var grade_text: String = ""
var grade_color: Color = Color.WHITE
var grade_timer: float = 0.0
const GRADE_DISPLAY_TIME: float = 1.5

## 警告闪烁（最后4小节）
var warning_flash: float = 0.0

## 节拍时钟引用（由 main.gd 注入）
var bc: BeatClockSystem = null

func _ready() -> void:
	visible = false
	z_index = 30

func show_ui() -> void:
	visible = true

func hide_ui() -> void:
	visible = false
	grade_text = ""
	grade_timer = 0.0

## 显示判定反馈
func show_grade(grade: String, bonus_score: int) -> void:
	match grade:
		"Perfect":
			grade_text = Loc.i().t("Perfect") + "! +" + str(bonus_score)
			grade_color = Color(0.95, 0.85, 0.3)
		"Great":
			grade_text = Loc.i().t("Great") + "! +" + str(bonus_score)
			grade_color = Color(0.75, 0.8, 0.9)
		"Good":
			grade_text = Loc.i().t("Good") + " +" + str(bonus_score)
			grade_color = Color(0.8, 0.65, 0.4)
		_:
			grade_text = Loc.i().t("Miss")
			grade_color = Color(0.5, 0.5, 0.5)
	grade_timer = GRADE_DISPLAY_TIME

func _process(delta: float) -> void:
	if not visible:
		return
	if grade_timer > 0:
		grade_timer -= delta
	queue_redraw()

func _draw() -> void:
	if not visible or bc == null:
		return
	if not bc.is_active or not bc.is_boss_round:
		return

	var GC = GameConfig

	## ─── BPM 标签 ───
	var bpm_text = str(int(bc.current_bpm)) + " BPM"
	draw_string(ThemeDB.fallback_font,
		Vector2(BAR_X, BPM_LABEL_Y),
		bpm_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
		Color(0.6, 0.6, 0.55))

	## ─── 计时进度条 ───
	var progress = bc.get_timer_progress()
	var is_warning = bc.bars_remaining <= 4

	## 背景
	draw_rect(Rect2(BAR_X, BAR_Y, BAR_W, BAR_H), Color(0.12, 0.12, 0.12))

	## 进度填充
	var fill_color: Color
	if is_warning:
		## 红色闪烁
		warning_flash += get_process_delta_time() * 6.0
		var flash = 0.7 + sin(warning_flash) * 0.3
		fill_color = Color(0.9, 0.2, 0.2, flash)
	else:
		fill_color = Color(0.3, 0.85, 0.4).lerp(Color(0.9, 0.6, 0.2), progress)

	var fill_w = BAR_W * clampf(1.0 - progress, 0.0, 1.0)
	draw_rect(Rect2(BAR_X, BAR_Y, fill_w, BAR_H), fill_color)

	## 边框
	draw_rect(Rect2(BAR_X, BAR_Y, BAR_W, BAR_H),
		Color(0.4, 0.4, 0.4), false, 1.0)

	## 剩余小节数
	var bars_text = str(bc.bars_remaining) + "/" + str(BeatClockSystem.PLAY_TIMER_BARS)
	var bars_color = Color(0.9, 0.3, 0.3) if is_warning else Color(0.6, 0.6, 0.55)
	draw_string(ThemeDB.fallback_font,
		Vector2(BAR_X + BAR_W + 12, BAR_Y + 10),
		bars_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, bars_color)

	## ─── 拍点指示器（4个点 = 1小节内4拍）───
	@warning_ignore("unused_variable")
	var beat_spacing = BAR_W / 16.0  ## 16小节对应16段(保留供后续拍线绘制)
	var current_beat = bc.current_beat
	var beat_progress = bc.get_beat_progress()

	for i in range(4):
		var dot_x = BAR_X + 30 + i * 80
		var is_strong = (i == 0 or i == 2)  ## 强拍: 第1和第3拍
		var dot_size: float = 6.0 if is_strong else 4.0
		var dot_color: Color

		if i == current_beat:
			## 当前拍 — 高亮 + 缩放脉冲
			var scale_pulse = 1.0 + beat_progress * 0.4
			dot_size *= scale_pulse
			dot_color = Color(0.95, 0.85, 0.3) if is_strong else Color(0.7, 0.8, 0.9)
		elif i < current_beat:
			## 已过拍 — 暗色
			dot_color = Color(0.3, 0.3, 0.3)
		else:
			## 未到拍
			dot_color = Color(0.5, 0.5, 0.5) if is_strong else Color(0.35, 0.35, 0.35)

		draw_circle(Vector2(dot_x, BEAT_DOT_Y), dot_size, dot_color)

		## 强拍标记
		if is_strong and i == current_beat:
			draw_circle(Vector2(dot_x, BEAT_DOT_Y), dot_size + 3, Color(dot_color.r, dot_color.g, dot_color.b, 0.2))

	## ─── Bonus池信息 ───
	var bonus_text = "Bonus: " + str(bc.total_bonus_earned) + " / " + str(bc.bonus_pool)
	draw_string(ThemeDB.fallback_font,
		Vector2(BAR_X, BONUS_INFO_Y),
		bonus_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
		Color(0.7, 0.65, 0.5))

	## 每手上限
	var cap_text = Loc.i().t("Per hand cap") + ": " + str(bc.get_per_hand_bonus_cap())
	draw_string(ThemeDB.fallback_font,
		Vector2(BAR_X + 250, BONUS_INFO_Y),
		cap_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
		Color(0.6, 0.6, 0.55))

	## ─── 判定反馈文字 ───
	if grade_timer > 0 and grade_text != "":
		var alpha = clampf(grade_timer / 0.5, 0.0, 1.0)
		## 从屏幕中间偏上弹出
		var center_x = GC.CENTER_X
		var y_offset = -20.0 * (1.0 - grade_timer / GRADE_DISPLAY_TIME)
		var text_y = 450.0 + y_offset
		var font_size = 36 if grade_timer > GRADE_DISPLAY_TIME - 0.3 else 28

		draw_string(ThemeDB.fallback_font,
			Vector2(center_x - 150, text_y),
			grade_text, HORIZONTAL_ALIGNMENT_CENTER, 300, font_size,
			Color(grade_color.r, grade_color.g, grade_color.b, alpha))
