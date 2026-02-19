## status_panel.gd
## TAB 状态面板 - 优惠券 + 牌型等级 + 牌库追踪
extends Node2D

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0
const CENTER_Y: float = SCREEN_H / 2.0

const PANEL_W: float = 1300.0
const PANEL_H: float = 920.0
const PANEL_X: float = (SCREEN_W - PANEL_W) / 2.0
const PANEL_Y: float = (SCREEN_H - PANEL_H) / 2.0

## 牌库追踪网格
const GRID_COLS: int = 13
const GRID_ROWS: int = 4
const CELL_W: float = 50.0
const CELL_H: float = 28.0

## 花色符号和颜色（显示用，提高亮度）
const SUIT_SYMBOLS = ["♠", "♥", "♣", "♦"]
const SUIT_COLORS = [
	Color(0.4, 0.5, 0.75),    ## ♠ 黑桃 - 亮蓝灰
	Color(0.95, 0.3, 0.3),    ## ♥ 红心 - 亮红
	Color(0.3, 0.65, 0.4),    ## ♣ 梅花 - 亮绿
	Color(0.95, 0.7, 0.2),    ## ♦ 方块 - 亮橙
]
## CardData.Suit 枚举: HEARTS=0, DIAMONDS=1, CLUBS=2, SPADES=3
## 显示行顺序: ♠(3), ♥(0), ♣(2), ♦(1)
const DISPLAY_SUIT_ORDER = [3, 0, 2, 1]

const RANK_LABELS = ["A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
const RANK_VALUES = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

var played_cards: Dictionary = {}
var voucher_ids: Array = []

func _ready() -> void:
	visible = false
	z_index = 200

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

	var font = Loc.i().cn_font
	if font == null:
		font = ThemeDB.fallback_font

	## 全屏半透明遮罩
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0, 0, 0, 0.85))

	## 面板背景
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, PANEL_H), Color(0.05, 0.08, 0.06, 0.97))

	## 面板边框
	var bc = Color(0.95, 0.85, 0.3, 0.4)
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, 2), bc)
	draw_rect(Rect2(PANEL_X, PANEL_Y + PANEL_H - 2, PANEL_W, 2), bc)
	draw_rect(Rect2(PANEL_X, PANEL_Y, 2, PANEL_H), bc)
	draw_rect(Rect2(PANEL_X + PANEL_W - 2, PANEL_Y, 2, PANEL_H), bc)

	## ===== 标题 =====
	draw_string(font, Vector2(CENTER_X - 80, PANEL_Y + 35), Loc.i().t("Game Status"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(0.95, 0.85, 0.4))

	## ===== 左半区 =====
	var left_x = PANEL_X + 30
	var right_x = PANEL_X + PANEL_W / 2.0 + 15

	## ----- 优惠券 -----
	draw_string(font, Vector2(left_x + 10, PANEL_Y + 75), "🎟️ " + Loc.i().t("Owned Vouchers"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.7, 0.3))

	if voucher_ids.is_empty():
		draw_string(font, Vector2(left_x + 30, PANEL_Y + 100), Loc.i().t("None"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.45, 0.45, 0.4))
	else:
		var vy = PANEL_Y + 100
		for vid in voucher_ids:
			var vdata = VoucherDatabase.get_voucher_by_id(vid)
			if vdata:
				var text = vdata.emoji + " " + Loc.i().t(vdata.voucher_name) + " - " + Loc.i().t(vdata.description)
				draw_string(font, Vector2(left_x + 30, vy), text,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.65, 0.5))
				vy += 20

	## ----- 分隔线 -----
	draw_rect(Rect2(left_x, PANEL_Y + 160, PANEL_W / 2.0 - 45, 1), Color(0.95, 0.85, 0.3, 0.15))

	## ----- 牌型等级表 -----
	draw_string(font, Vector2(left_x + 10, PANEL_Y + 185), "📊 " + Loc.i().t("Hand Levels"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.7, 0.3))

	_draw_hand_levels(font, left_x + 10, PANEL_Y + 205)

	## ===== 右半区：牌库追踪 =====
	## 竖分隔线
	draw_rect(Rect2(right_x - 15, PANEL_Y + 55, 1, PANEL_H - 100), Color(0.95, 0.85, 0.3, 0.12))

	draw_string(font, Vector2(right_x + 10, PANEL_Y + 75), "🃏 " + Loc.i().t("Deck Tracker"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.7, 0.3))

	_draw_deck_tracker(font, right_x + 10, PANEL_Y + 95)

	## ===== 底部提示 =====
	draw_string(font, Vector2(CENTER_X - 35, PANEL_Y + PANEL_H - 15), "[ TAB ]",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.4, 0.35))

## ========== 牌型等级表 ==========

func _draw_hand_levels(font: Font, start_x: float, start_y: float) -> void:
	var col_name_x = start_x
	var col_lvl_x = start_x + 200
	var col_chips_x = start_x + 260
	var col_mult_x = start_x + 370
	var header_color = Color(0.55, 0.55, 0.5)
	var table_w = col_mult_x + 60 - col_name_x

	## 表头
	draw_string(font, Vector2(col_name_x, start_y + 14), Loc.i().t("Hand Type"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, header_color)
	draw_string(font, Vector2(col_lvl_x, start_y + 14), "Lv.",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, header_color)
	draw_string(font, Vector2(col_chips_x, start_y + 14), Loc.i().t("Chips"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.6, 0.9))
	draw_string(font, Vector2(col_mult_x, start_y + 14), Loc.i().t("Mult"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.4, 0.35))

	## 分隔线
	draw_rect(Rect2(col_name_x, start_y + 20, table_w, 1), Color(0.5, 0.5, 0.4, 0.2))

	## 标准牌型（强到弱）
	var hand_types: Array = [
		PokerHand.HandType.STRAIGHT_FLUSH,
		PokerHand.HandType.FOUR_OF_A_KIND,
		PokerHand.HandType.FULL_HOUSE,
		PokerHand.HandType.FLUSH,
		PokerHand.HandType.STRAIGHT,
		PokerHand.HandType.THREE_OF_A_KIND,
		PokerHand.HandType.TWO_PAIR,
		PokerHand.HandType.PAIR,
		PokerHand.HandType.HIGH_CARD,
	]

	var row_h = 24.0
	var y = start_y + 28

	for i in range(hand_types.size()):
		var ht = hand_types[i]
		var hand_name = Loc.i().t(PokerHand.get_hand_name(ht))
		var info = HandLevel.get_level_info(ht)
		var level = info["level"]
		var chips = info["base_chips"]
		var mult = info["base_mult"]

		## 行背景交替
		if i % 2 == 0:
			draw_rect(Rect2(col_name_x - 5, y - 2, table_w + 10, row_h), Color(1, 1, 1, 0.02))

		## 牌型名称（升级过的高亮）
		var name_color = Color(0.75, 0.75, 0.7)
		if level > 1:
			name_color = Color(0.95, 0.9, 0.55)
		draw_string(font, Vector2(col_name_x, y + 15), hand_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, name_color)

		## 等级
		var lvl_color = Color(0.5, 0.5, 0.45) if level <= 1 else Color(0.3, 0.9, 0.4)
		draw_string(font, Vector2(col_lvl_x, y + 15), str(level),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, lvl_color)

		## 筹码
		draw_string(font, Vector2(col_chips_x, y + 15), str(chips),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.45, 0.65, 0.95))

		## 倍率
		draw_string(font, Vector2(col_mult_x, y + 15), str(mult),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.95, 0.45, 0.4))

		y += row_h

## ========== 牌库追踪 ==========

func _draw_deck_tracker(font: Font, start_x: float, start_y: float) -> void:
	var grid_x = start_x
	var grid_y = start_y + 25

	## 列标题
	for col in range(GRID_COLS):
		var x = grid_x + 30 + col * CELL_W + CELL_W / 2.0 - 8.0
		draw_string(font, Vector2(x, grid_y - 5), RANK_LABELS[col],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.55, 0.55, 0.5))

	## 行标题 + 网格
	var played_count = 0

	for row in range(GRID_ROWS):
		var suit_enum = DISPLAY_SUIT_ORDER[row]
		var y = grid_y + row * CELL_H

		## 花色符号
		draw_string(font, Vector2(grid_x + 8, y + CELL_H - 6), SUIT_SYMBOLS[row],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, SUIT_COLORS[row])

		for col in range(GRID_COLS):
			var rank = RANK_VALUES[col]
			var key = str(suit_enum) + "_" + str(rank)
			var is_played = played_cards.has(key)

			var cx = grid_x + 30 + col * CELL_W
			var cy = y + 2

			if is_played:
				## ===== 已打出：深黑底 + 极暗文字 + 红色删除线 =====
				draw_rect(Rect2(cx, cy, CELL_W - 3, CELL_H - 3), Color(0.06, 0.05, 0.05, 0.95))
				draw_rect(Rect2(cx, cy, CELL_W - 3, CELL_H - 3), Color(0.25, 0.12, 0.12, 0.4), false, 1.0)
				draw_string(font, Vector2(cx + 5, cy + CELL_H - 10), RANK_LABELS[col],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.2, 0.18, 0.18))
				## 删除线
				draw_rect(Rect2(cx + 3, cy + CELL_H / 2.0 - 1, CELL_W - 9, 1),
					Color(0.6, 0.2, 0.2, 0.6))
				played_count += 1
			else:
				## ===== 未打出：鲜明花色底 + 亮色文字 =====
				var bg = Color(SUIT_COLORS[row].r, SUIT_COLORS[row].g, SUIT_COLORS[row].b, 0.22)
				draw_rect(Rect2(cx, cy, CELL_W - 3, CELL_H - 3), bg)
				draw_string(font, Vector2(cx + 5, cy + CELL_H - 10), RANK_LABELS[col],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 12, SUIT_COLORS[row])

	## 统计
	var remaining = 52 - played_count
	var stats_y = grid_y + GRID_ROWS * CELL_H + 15
	var stats_text = Loc.i().t("Played") + ": " + str(played_count) + " / 52    " + Loc.i().t("Remaining") + ": " + str(remaining)
	draw_string(font, Vector2(grid_x + 30, stats_y), stats_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.55, 0.55, 0.5))
