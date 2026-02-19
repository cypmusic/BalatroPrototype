## status_panel.gd
## TAB 状态面板 - 显示优惠券 + 牌库追踪
extends Node2D

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

const PANEL_W: float = 1200.0
const PANEL_H: float = 700.0
const PANEL_X: float = (SCREEN_W - PANEL_W) / 2.0
const PANEL_Y: float = (SCREEN_H - PANEL_H) / 2.0

## 卡牌追踪网格
const GRID_COLS: int = 13  ## A, K, Q, J, 10, 9, 8, 7, 6, 5, 4, 3, 2
const GRID_ROWS: int = 4   ## ♠, ♥, ♣, ♦
const CELL_W: float = 72.0
const CELL_H: float = 36.0
const GRID_X: float = PANEL_X + 40.0
const GRID_Y: float = PANEL_Y + 280.0

## 花色符号和颜色
const SUIT_SYMBOLS = ["♠", "♥", "♣", "♦"]
const SUIT_COLORS = [
	Color(0.3, 0.35, 0.5),    ## ♠ 黑桃 - 深蓝灰
	Color(0.8, 0.25, 0.25),   ## ♥ 红心 - 红
	Color(0.25, 0.45, 0.3),   ## ♣ 梅花 - 深绿
	Color(0.8, 0.55, 0.15),   ## ♦ 方块 - 橙
]
## CardData.Suit 枚举顺序: HEARTS=0, DIAMONDS=1, CLUBS=2, SPADES=3
## 显示行顺序: ♠(3), ♥(0), ♣(2), ♦(1)
const DISPLAY_SUIT_ORDER = [3, 0, 2, 1]  ## SPADES, HEARTS, CLUBS, DIAMONDS

const RANK_LABELS = ["A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
## CardData.rank: A=14, K=13, Q=12, J=11, 10=10, ..., 2=2
const RANK_VALUES = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

var played_cards: Dictionary = {}  ## key = "suit_rank" → true
var voucher_ids: Array = []

func _ready() -> void:
	visible = false
	z_index = 200

func _f(lbl: Label) -> void:
	var font = Loc.i().cn_font
	if font: lbl.add_theme_font_override("font", font)

## ========== 外部接口 ==========

func update_vouchers(ids: Array) -> void:
	voucher_ids = ids

func record_played_cards(cards: Array) -> void:
	for card in cards:
		if card and card.card_data:
			var key = str(int(card.card_data.suit)) + "_" + str(card.card_data.rank)
			played_cards[key] = true

func reset_tracking() -> void:
	played_cards.clear()
	voucher_ids.clear()

## ========== 显示/隐藏 ==========

func show_panel() -> void:
	visible = true
	queue_redraw()

func hide_panel() -> void:
	visible = false

## ========== 绘制 ==========

func _draw() -> void:
	if not visible:
		return

	## 全屏半透明遮罩
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0, 0, 0, 0.82))

	## 面板背景
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, PANEL_H), Color(0.06, 0.1, 0.08, 0.95))

	## 面板边框
	var bc = Color(0.95, 0.85, 0.3, 0.4)
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, 2), bc)
	draw_rect(Rect2(PANEL_X, PANEL_Y + PANEL_H - 2, PANEL_W, 2), bc)
	draw_rect(Rect2(PANEL_X, PANEL_Y, 2, PANEL_H), bc)
	draw_rect(Rect2(PANEL_X + PANEL_W - 2, PANEL_Y, 2, PANEL_H), bc)

	## ===== 标题 =====
	var font = Loc.i().cn_font
	if font == null:
		font = ThemeDB.fallback_font
	draw_string(font, Vector2(CENTER_X - 80, PANEL_Y + 35), Loc.i().t("Game Status"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(0.95, 0.85, 0.4))

	## ===== 优惠券区域 =====
	draw_string(font, Vector2(PANEL_X + 40, PANEL_Y + 80), "🎟️ " + Loc.i().t("Owned Vouchers"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.8, 0.7, 0.3))

	if voucher_ids.is_empty():
		draw_string(font, Vector2(PANEL_X + 60, PANEL_Y + 110), Loc.i().t("None"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.5, 0.5, 0.45))
	else:
		var vy = PANEL_Y + 110
		for vid in voucher_ids:
			var vdata = VoucherDatabase.get_voucher_by_id(vid)
			if vdata:
				var text = vdata.emoji + " " + Loc.i().t(vdata.voucher_name) + " - " + Loc.i().t(vdata.description)
				draw_string(font, Vector2(PANEL_X + 60, vy), text,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.75, 0.7, 0.55))
				vy += 22

	## ===== 分隔线 =====
	draw_rect(Rect2(PANEL_X + 30, PANEL_Y + 240, PANEL_W - 60, 1), Color(0.95, 0.85, 0.3, 0.2))

	## ===== 牌库追踪标题 =====
	draw_string(font, Vector2(PANEL_X + 40, PANEL_Y + 270), "🃏 " + Loc.i().t("Deck Tracker"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.8, 0.7, 0.3))

	## ===== 列标题 (A, K, Q, ...) =====
	for col in range(GRID_COLS):
		var x = GRID_X + 40 + col * CELL_W + CELL_W / 2.0 - 8.0
		draw_string(font, Vector2(x, GRID_Y - 5), RANK_LABELS[col],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.6, 0.6, 0.55))

	## ===== 行标题 + 卡牌网格 =====
	var played_count = 0
	var total_count = 52

	for row in range(GRID_ROWS):
		var suit_enum = DISPLAY_SUIT_ORDER[row]
		var y = GRID_Y + row * CELL_H

		## 花色符号
		draw_string(font, Vector2(GRID_X + 10, y + CELL_H - 8), SUIT_SYMBOLS[row],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 18, SUIT_COLORS[row])

		for col in range(GRID_COLS):
			var rank = RANK_VALUES[col]
			var key = str(suit_enum) + "_" + str(rank)
			var is_played = played_cards.has(key)

			var cx = GRID_X + 40 + col * CELL_W
			var cy = y + 2

			if is_played:
				## 已打出 - 灰色暗淡
				draw_rect(Rect2(cx, cy, CELL_W - 4, CELL_H - 4), Color(0.15, 0.15, 0.15, 0.6))
				draw_string(font, Vector2(cx + 6, cy + CELL_H - 12), RANK_LABELS[col],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.35, 0.35, 0.35))
				played_count += 1
			else:
				## 未打出 - 正常颜色
				var bg_color = Color(SUIT_COLORS[row].r, SUIT_COLORS[row].g, SUIT_COLORS[row].b, 0.15)
				draw_rect(Rect2(cx, cy, CELL_W - 4, CELL_H - 4), bg_color)
				draw_string(font, Vector2(cx + 6, cy + CELL_H - 12), RANK_LABELS[col],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 14, SUIT_COLORS[row])

	## ===== 统计信息 =====
	var remaining = total_count - played_count
	var stats_y = GRID_Y + GRID_ROWS * CELL_H + 20
	var stats_text = Loc.i().t("Played") + ": " + str(played_count) + " / " + str(total_count) + "    " + Loc.i().t("Remaining") + ": " + str(remaining)
	draw_string(font, Vector2(GRID_X + 40, stats_y), stats_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.6, 0.6, 0.55))

	## ===== 底部提示 =====
	draw_string(font, Vector2(CENTER_X - 60, PANEL_Y + PANEL_H - 20), "[ TAB ]",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.4, 0.35))
