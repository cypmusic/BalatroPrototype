## neon_shop_sign.gd
## 霓虹灯 SHOP 招牌 V2 - 颜色循环 + 闪烁 + 发光 + 霓虹边框
extends Node2D

var timer: float = 0.0
var flicker_timer: float = 0.0
var flicker_state: bool = true
var letter_phases: Array = [0.0, 0.7, 1.4, 2.1]

var neon_colors: Array = [
	Color(1.0, 0.2, 0.4),    ## 粉红
	Color(0.2, 0.6, 1.0),    ## 蓝色
	Color(0.1, 1.0, 0.5),    ## 绿色
	Color(1.0, 0.8, 0.1),    ## 黄色
	Color(0.8, 0.2, 1.0),    ## 紫色
	Color(1.0, 0.4, 0.1),    ## 橙色
	Color(0.1, 0.9, 0.9),    ## 青色
]

var letters: Dictionary = {
	"S": [
		"_###_",
		"#___#",
		"#____",
		"_###_",
		"____#",
		"#___#",
		"_###_",
	],
	"H": [
		"#___#",
		"#___#",
		"#___#",
		"#####",
		"#___#",
		"#___#",
		"#___#",
	],
	"O": [
		"_###_",
		"#___#",
		"#___#",
		"#___#",
		"#___#",
		"#___#",
		"_###_",
	],
	"P": [
		"####_",
		"#___#",
		"#___#",
		"####_",
		"#____",
		"#____",
		"#____",
	],
}

const PIXEL_SIZE: float = 5.0
const LETTER_SPACING: float = 42.0
const SIGN_Y: float = 0.0

## 边框参数
const FRAME_PAD_X: float = 25.0
const FRAME_PAD_TOP: float = 15.0
const FRAME_PAD_BOTTOM: float = 12.0
const TUBE_WIDTH: float = 3.0

func _process(delta: float) -> void:
	timer += delta * 0.8
	flicker_timer += delta
	if flicker_timer > randf_range(0.05, 0.15):
		flicker_timer = 0.0
		flicker_state = not flicker_state if randf() < 0.08 else true
	queue_redraw()

func _draw() -> void:
	var word = "SHOP"
	var letter_w = 5 * PIXEL_SIZE  ## 每个字母实际像素宽度
	var total_w = (word.length() - 1) * LETTER_SPACING + letter_w
	var start_x = -total_w / 2.0
	var letter_h = 7 * PIXEL_SIZE

	## ===== 霓虹边框 =====
	var frame_left = start_x - FRAME_PAD_X
	var frame_right = start_x + total_w + FRAME_PAD_X
	var frame_top = SIGN_Y - FRAME_PAD_TOP
	var frame_bottom = SIGN_Y + letter_h + FRAME_PAD_BOTTOM
	var frame_w = frame_right - frame_left
	var frame_h = frame_bottom - frame_top

	## 边框颜色 - 独立的慢速循环
	var frame_phase = timer * 0.5
	var fci = int(floor(frame_phase)) % neon_colors.size()
	var fci_next = (fci + 1) % neon_colors.size()
	var frame_color = neon_colors[fci].lerp(neon_colors[fci_next], fmod(frame_phase, 1.0))

	## 边框呼吸
	var frame_breath = 0.8 + 0.2 * sin(timer * 2.0)

	## 外发光层
	_draw_frame(frame_left, frame_top, frame_w, frame_h,
		Color(frame_color.r, frame_color.g, frame_color.b, 0.08 * frame_breath), TUBE_WIDTH * 4)
	## 中发光层
	_draw_frame(frame_left, frame_top, frame_w, frame_h,
		Color(frame_color.r, frame_color.g, frame_color.b, 0.2 * frame_breath), TUBE_WIDTH * 2)
	## 核心层
	_draw_frame(frame_left, frame_top, frame_w, frame_h,
		Color(frame_color.r, frame_color.g, frame_color.b, 0.7 * frame_breath), TUBE_WIDTH)
	## 高光层
	var frame_hl = frame_color.lerp(Color.WHITE, 0.5)
	_draw_frame(frame_left + 1, frame_top + 1, frame_w - 2, frame_h - 2,
		Color(frame_hl.r, frame_hl.g, frame_hl.b, 0.4 * frame_breath), TUBE_WIDTH * 0.5)

	## 角落装饰小圆点
	var corner_r = 4.0
	var corners = [
		Vector2(frame_left, frame_top),
		Vector2(frame_right, frame_top),
		Vector2(frame_left, frame_bottom),
		Vector2(frame_right, frame_bottom),
	]
	for c in corners:
		draw_circle(c, corner_r * 1.5, Color(frame_color.r, frame_color.g, frame_color.b, 0.15 * frame_breath))
		draw_circle(c, corner_r, Color(frame_color.r, frame_color.g, frame_color.b, 0.6 * frame_breath))
		draw_circle(c, corner_r * 0.5, frame_hl)

	## ===== 文字 =====
	for li in range(word.length()):
		var ch = word[li]
		if not letters.has(ch): continue
		var grid = letters[ch]
		var lx = start_x + li * LETTER_SPACING

		var phase = timer + letter_phases[li]
		var ci = int(floor(phase)) % neon_colors.size()
		var ci_next = (ci + 1) % neon_colors.size()
		var blend = fmod(phase, 1.0)
		var color = neon_colors[ci].lerp(neon_colors[ci_next], blend)

		var brightness = 1.0
		if not flicker_state and li == int(timer * 3.0) % word.length():
			brightness = 0.3
		var breath = 0.85 + 0.15 * sin(timer * 3.0 + li * 1.5)
		brightness *= breath

		var final_color = Color(color.r * brightness, color.g * brightness, color.b * brightness, 1.0)

		## 外发光
		_draw_letter_grid(grid, lx, SIGN_Y, PIXEL_SIZE * 1.8,
			Color(final_color.r, final_color.g, final_color.b, 0.15 * brightness))
		## 中发光
		_draw_letter_grid(grid, lx, SIGN_Y, PIXEL_SIZE * 1.3,
			Color(final_color.r, final_color.g, final_color.b, 0.35 * brightness))
		## 核心
		_draw_letter_grid(grid, lx, SIGN_Y, PIXEL_SIZE, final_color)
		## 高光
		var highlight = final_color.lerp(Color.WHITE, 0.5)
		highlight.a = 0.7 * brightness
		_draw_letter_grid(grid, lx, SIGN_Y, PIXEL_SIZE * 0.6, highlight)

func _draw_frame(x: float, y: float, w: float, h: float, color: Color, thickness: float) -> void:
	var ht = thickness / 2.0
	## 上边
	draw_rect(Rect2(x - ht, y - ht, w + thickness, thickness), color)
	## 下边
	draw_rect(Rect2(x - ht, y + h - ht, w + thickness, thickness), color)
	## 左边
	draw_rect(Rect2(x - ht, y - ht, thickness, h + thickness), color)
	## 右边
	draw_rect(Rect2(x + w - ht, y - ht, thickness, h + thickness), color)

func _draw_letter_grid(grid: Array, ox: float, oy: float, px_size: float, color: Color) -> void:
	var offset = (PIXEL_SIZE - px_size) / 2.0
	for row in range(grid.size()):
		var line = grid[row]
		for col in range(line.length()):
			if line[col] == "#":
				draw_rect(Rect2(ox + col * PIXEL_SIZE + offset, oy + row * PIXEL_SIZE + offset, px_size, px_size), color)
