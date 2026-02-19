## status_panel.gd
## TAB 状态面板 - 垂直布局：优惠券 → 牌库追踪 → 牌型等级
extends Node2D

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0

const PANEL_W: float = 1100.0
const PANEL_H: float = 880.0
const PANEL_X: float = (SCREEN_W - PANEL_W) / 2.0
const PANEL_Y: float = (SCREEN_H - PANEL_H) / 2.0

## 牌库追踪
const GRID_COLS: int = 13
const GRID_ROWS: int = 4
const CELL_W: float = 62.0
const CELL_H: float = 28.0

const SUIT_SYMBOLS = ["♠", "♥", "♣", "♦"]
const SUIT_COLORS = [
	Color(0.4, 0.5, 0.75),
	Color(0.95, 0.3, 0.3),
	Color(0.3, 0.65, 0.4),
	Color(0.95, 0.7, 0.2),
]
const DISPLAY_SUIT_ORDER = [3, 0, 2, 1]
const RANK_LABELS = ["A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
const RANK_VALUES = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

var played_cards: Dictionary = {}
var voucher_ids: Array = []

func _ready() -> void:
	visible = false
	z_index = 200

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

func show_panel() -> void:
	visible = true
	queue_redraw()

func hide_panel() -> void:
	visible = false

func _draw() -> void:
	if not visible:
		return

	var font = Loc.i().cn_font
	if font == null:
		font = ThemeDB.fallback_font

	## 全屏遮罩
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0, 0, 0, 0.85))

	## 面板背景
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, PANEL_H), Color(0.05, 0.08, 0.06, 0.97))

	## 边框
	var bc = Color(0.95, 0.85, 0.3, 0.4)
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, 2), bc)
	draw_rect(Rect2(PANEL_X, PANEL_Y + PANEL_H - 2, PANEL_W, 2), bc)
	draw_rect(Rect2(PANEL_X, PANEL_Y, 2, PANEL_H), bc)
	draw_rect(Rect2(PANEL_X + PANEL_W - 2, PANEL_Y, 2, PANEL_H), bc)

	## 标题
	draw_string(font, Vector2(CENTER_X - 80, PANEL_Y + 35), Loc.i().t("Game Status"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(0.95, 0.85, 0.4))

	var cx = PANEL_X + 35
	var cy = PANEL_Y + 55

	## ===== A) 优惠券 =====
	cy += 15
	draw_string(font, Vector2(cx, cy), "🎟️ " + Loc.i().t("Owned Vouchers"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.7, 0.3))

	if voucher_ids.is_empty():
		cy += 18
		draw_string(font, Vector2(cx + 20, cy), Loc.i().t("None"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.45, 0.45, 0.4))
		cy += 8
	else:
		for vid in voucher_ids:
			cy += 18
			var vdata = VoucherDatabase.get_voucher_by_id(vid)
			if vdata:
				draw_string(font, Vector2(cx + 20, cy),
					vdata.emoji + " " + Loc.i().t(vdata.voucher_name) + " - " + Loc.i().t(vdata.description),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.65, 0.5))
		cy += 8

	## 分隔线
	cy += 10
	draw_rect(Rect2(cx, cy, PANEL_W - 70, 1), Color(0.95, 0.85, 0.3, 0.15))

	## ===== B) 牌库追踪 =====
	cy += 15
	draw_string(font, Vector2(cx, cy), "🃏 " + Loc.i().t("Deck Tracker"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.7, 0.3))

	cy = _draw_deck_tracker(font, cx, cy + 8)

	## 分隔线
	cy += 12
	draw_rect(Rect2(cx, cy, PANEL_W - 70, 1), Color(0.95, 0.85, 0.3, 0.15))

	## ===== C) 牌型等级 =====
	cy += 15
	draw_string(font, Vector2(cx, cy), "📊 " + Loc.i().t("Hand Levels"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.7, 0.3))

	_draw_hand_levels(font, cx, cy + 8)

	## 底部提示
	draw_string(font, Vector2(CENTER_X - 35, PANEL_Y + PANEL_H - 15), "[ TAB ]",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.4, 0.35))

## ========== 牌库追踪（返回结束 y）==========

func _draw_deck_tracker(font: Font, sx: float, sy: float) -> float:
	var gy = sy + 22
	## 列标题
	for col in range(GRID_COLS):
		var x = sx + 30 + col * CELL_W + CELL_W / 2.0 - 8.0
		draw_string(font, Vector2(x, gy - 3), RANK_LABELS[col],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.55, 0.55, 0.5))

	var played_count = 0
	for row in range(GRID_ROWS):
		var suit_enum = DISPLAY_SUIT_ORDER[row]
		var y = gy + row * CELL_H
		draw_string(font, Vector2(sx + 8, y + CELL_H - 6), SUIT_SYMBOLS[row],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, SUIT_COLORS[row])

		for col in range(GRID_COLS):
			var rank = RANK_VALUES[col]
			var key = str(suit_enum) + "_" + str(rank)
			var is_played = played_cards.has(key)
			var ccx = sx + 30 + col * CELL_W
			var ccy = y + 2

			if is_played:
				draw_rect(Rect2(ccx, ccy, CELL_W - 3, CELL_H - 3), Color(0.06, 0.05, 0.05, 0.95))
				draw_rect(Rect2(ccx, ccy, CELL_W - 3, CELL_H - 3), Color(0.25, 0.12, 0.12, 0.4), false, 1.0)
				draw_string(font, Vector2(ccx + 5, ccy + CELL_H - 10), RANK_LABELS[col],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.2, 0.18, 0.18))
				draw_rect(Rect2(ccx + 3, ccy + CELL_H / 2.0 - 1, CELL_W - 9, 1),
					Color(0.6, 0.2, 0.2, 0.6))
				played_count += 1
			else:
				var bg = Color(SUIT_COLORS[row].r, SUIT_COLORS[row].g, SUIT_COLORS[row].b, 0.22)
				draw_rect(Rect2(ccx, ccy, CELL_W - 3, CELL_H - 3), bg)
				draw_string(font, Vector2(ccx + 5, ccy + CELL_H - 10), RANK_LABELS[col],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 12, SUIT_COLORS[row])

	var stats_y = gy + GRID_ROWS * CELL_H + 10
	var remaining = 52 - played_count
	draw_string(font, Vector2(sx + 30, stats_y),
		Loc.i().t("Played") + ": " + str(played_count) + " / 52    " + Loc.i().t("Remaining") + ": " + str(remaining),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.55, 0.55, 0.5))
	return stats_y + 5

## ========== 牌型等级表 ==========

func _draw_hand_levels(font: Font, sx: float, sy: float) -> void:
	var c0 = sx
	var c1 = sx + 200
	var c2 = sx + 260
	var c3 = sx + 380
	var tw = c3 + 60 - c0
	var hc = Color(0.55, 0.55, 0.5)

	draw_string(font, Vector2(c0, sy + 14), Loc.i().t("Hand Type"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, hc)
	draw_string(font, Vector2(c1, sy + 14), "Lv.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, hc)
	draw_string(font, Vector2(c2, sy + 14), Loc.i().t("Chips"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.6, 0.9))
	draw_string(font, Vector2(c3, sy + 14), Loc.i().t("Mult"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.4, 0.35))
	draw_rect(Rect2(c0, sy + 20, tw, 1), Color(0.5, 0.5, 0.4, 0.2))

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

	var rh = 22.0
	var y = sy + 26
	for i in range(hand_types.size()):
		var ht = hand_types[i]
		var info = HandLevel.get_level_info(ht)
		var level = info["level"]
		var base = PokerHand.get_base_score(ht)
		var chips = base["chips"] + info["bonus_chips"]
		var mult = base["mult"] + info["bonus_mult"]

		if i % 2 == 0:
			draw_rect(Rect2(c0 - 5, y - 2, tw + 10, rh), Color(1, 1, 1, 0.02))

		var nc = Color(0.75, 0.75, 0.7) if level <= 1 else Color(0.95, 0.9, 0.55)
		draw_string(font, Vector2(c0, y + 14), Loc.i().t(PokerHand.get_hand_name(ht)),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, nc)

		var lc = Color(0.5, 0.5, 0.45) if level <= 1 else Color(0.3, 0.9, 0.4)
		draw_string(font, Vector2(c1, y + 14), str(level), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, lc)
		draw_string(font, Vector2(c2, y + 14), str(chips), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.45, 0.65, 0.95))
		draw_string(font, Vector2(c3, y + 14), str(mult), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.95, 0.45, 0.4))
		y += rh
