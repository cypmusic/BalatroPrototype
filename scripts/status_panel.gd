## status_panel.gd
## TAB 状态面板 - 垂直居中布局：优惠券 → 牌库追踪 → 牌型等级
extends Node2D

const SCREEN_W: float = 1920.0
const SCREEN_H: float = 1080.0
const CENTER_X: float = SCREEN_W / 2.0

const PANEL_W: float = 1060.0
const PANEL_H: float = 920.0
const PANEL_X: float = (SCREEN_W - PANEL_W) / 2.0
const PANEL_Y: float = (SCREEN_H - PANEL_H) / 2.0

const GRID_COLS: int = 13
const GRID_ROWS: int = 4
const CELL_W: float = 60.0
const CELL_H: float = 30.0
const GRID_W: float = 30.0 + GRID_COLS * CELL_W

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

## 辅助：居中绘制文字
func _ct(font: Font, text: String, cx: float, y: float, size: int, color: Color) -> void:
	var tw = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, Vector2(cx - tw / 2.0, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	if not visible:
		return
	var font = Loc.i().cn_font
	if font == null:
		font = ThemeDB.fallback_font

	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0, 0, 0, 0.85))
	draw_rect(Rect2(PANEL_X, PANEL_Y, PANEL_W, PANEL_H), Color(0.05, 0.08, 0.06, 0.97))
	var bc = Color(0.95, 0.85, 0.3, 0.4)
	for r in [Rect2(PANEL_X, PANEL_Y, PANEL_W, 2), Rect2(PANEL_X, PANEL_Y + PANEL_H - 2, PANEL_W, 2),
			Rect2(PANEL_X, PANEL_Y, 2, PANEL_H), Rect2(PANEL_X + PANEL_W - 2, PANEL_Y, 2, PANEL_H)]:
		draw_rect(r, bc)

	_ct(font, Loc.i().t("Game Status"), CENTER_X, PANEL_Y + 40, 28, Color(0.95, 0.85, 0.4))

	var cy = PANEL_Y + 70

	## A) 优惠券
	_ct(font, "🎟️ " + Loc.i().t("Owned Vouchers"), CENTER_X, cy, 16, Color(0.8, 0.7, 0.3))
	if voucher_ids.is_empty():
		cy += 24
		_ct(font, Loc.i().t("None"), CENTER_X, cy, 14, Color(0.45, 0.45, 0.4))
		cy += 12
	else:
		for vid in voucher_ids:
			cy += 24
			var vdata = VoucherDatabase.get_voucher_by_id(vid)
			if vdata:
				_ct(font, vdata.emoji + " " + Loc.i().t(vdata.voucher_name) + " - " + Loc.i().t(vdata.description),
					CENTER_X, cy, 13, Color(0.7, 0.65, 0.5))
		cy += 12

	cy += 12
	draw_rect(Rect2(PANEL_X + 40, cy, PANEL_W - 80, 1), Color(0.95, 0.85, 0.3, 0.15))

	## B) 牌库追踪
	cy += 28
	_ct(font, "🃏 " + Loc.i().t("Deck Tracker"), CENTER_X, cy, 16, Color(0.8, 0.7, 0.3))
	var gx = (PANEL_W - GRID_W) / 2.0 + PANEL_X
	cy = _draw_deck_tracker(font, gx, cy + 12)

	cy += 22
	draw_rect(Rect2(PANEL_X + 40, cy, PANEL_W - 80, 1), Color(0.95, 0.85, 0.3, 0.15))

	## C) 牌型等级
	cy += 28
	_ct(font, "📊 " + Loc.i().t("Hand Levels"), CENTER_X, cy, 16, Color(0.8, 0.7, 0.3))
	var tw: float = 500.0
	var tx = (PANEL_W - tw) / 2.0 + PANEL_X
	_draw_hand_levels(font, tx, cy + 12)

	_ct(font, "[ TAB ]", CENTER_X, PANEL_Y + PANEL_H - 15, 12, Color(0.4, 0.4, 0.35))

## ========== 牌库追踪 ==========

func _draw_deck_tracker(font: Font, sx: float, sy: float) -> float:
	var gy = sy + 22
	for col in range(GRID_COLS):
		_ct(font, RANK_LABELS[col], sx + 30 + col * CELL_W + CELL_W / 2.0, gy - 2, 12, Color(0.55, 0.55, 0.5))

	var pc = 0
	for row in range(GRID_ROWS):
		var se = DISPLAY_SUIT_ORDER[row]
		var y = gy + row * CELL_H
		draw_string(font, Vector2(sx + 6, y + CELL_H - 7), SUIT_SYMBOLS[row],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, SUIT_COLORS[row])
		for col in range(GRID_COLS):
			var key = str(se) + "_" + str(RANK_VALUES[col])
			var ip = played_cards.has(key)
			var cx = sx + 30 + col * CELL_W
			var ccy = y + 2
			var ccx = cx + (CELL_W - 3) / 2.0
			var ty = ccy + (CELL_H - 3) / 2.0 + 5
			if ip:
				draw_rect(Rect2(cx, ccy, CELL_W - 3, CELL_H - 3), Color(0.06, 0.05, 0.05, 0.95))
				draw_rect(Rect2(cx, ccy, CELL_W - 3, CELL_H - 3), Color(0.25, 0.12, 0.12, 0.4), false, 1.0)
				_ct(font, RANK_LABELS[col], ccx, ty, 13, Color(0.2, 0.18, 0.18))
				draw_rect(Rect2(cx + 4, ccy + (CELL_H - 3) / 2.0, CELL_W - 10, 1), Color(0.6, 0.2, 0.2, 0.6))
				pc += 1
			else:
				draw_rect(Rect2(cx, ccy, CELL_W - 3, CELL_H - 3),
					Color(SUIT_COLORS[row].r, SUIT_COLORS[row].g, SUIT_COLORS[row].b, 0.22))
				_ct(font, RANK_LABELS[col], ccx, ty, 13, SUIT_COLORS[row])

	var sty = gy + GRID_ROWS * CELL_H + 14
	_ct(font, Loc.i().t("Played") + ": " + str(pc) + " / 52    " + Loc.i().t("Remaining") + ": " + str(52 - pc),
		sx + GRID_W / 2.0 + 15, sty, 13, Color(0.55, 0.55, 0.5))
	return sty + 5

## ========== 牌型等级（列顺序：牌型 | 筹码 | 倍率 | Lv.）==========

func _draw_hand_levels(font: Font, sx: float, sy: float) -> void:
	## 列位置：牌型名 | 筹码 | 倍率 | 等级
	var c_name = sx
	var c_chips = sx + 230
	var c_mult = sx + 340
	var c_lvl = sx + 440
	var tw = c_lvl + 40 - c_name

	var hc = Color(0.55, 0.55, 0.5)
	draw_string(font, Vector2(c_name, sy + 14), Loc.i().t("Hand Type"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hc)
	draw_string(font, Vector2(c_chips, sy + 14), Loc.i().t("Chips"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.4, 0.6, 0.9))
	draw_string(font, Vector2(c_mult, sy + 14), Loc.i().t("Mult"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.4, 0.35))
	draw_string(font, Vector2(c_lvl, sy + 14), "Lv.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, hc)
	draw_rect(Rect2(c_name, sy + 20, tw, 1), Color(0.5, 0.5, 0.4, 0.2))

	var hts: Array = [
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

	var rh = 24.0
	var y = sy + 28
	for i in range(hts.size()):
		var ht = hts[i]
		var info = HandLevel.get_level_info(ht)
		var lv = info["level"]
		var base = PokerHand.get_base_score(ht)
		var chips = base["chips"] + info["bonus_chips"]
		var mult = base["mult"] + info["bonus_mult"]

		if i % 2 == 0:
			draw_rect(Rect2(c_name - 5, y - 2, tw + 10, rh), Color(1, 1, 1, 0.02))

		var nc = Color(0.75, 0.75, 0.7) if lv <= 1 else Color(0.95, 0.9, 0.55)
		draw_string(font, Vector2(c_name, y + 15), Loc.i().t(PokerHand.get_hand_name(ht)),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, nc)
		draw_string(font, Vector2(c_chips, y + 15), str(chips), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.45, 0.65, 0.95))
		draw_string(font, Vector2(c_mult, y + 15), str(mult), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.95, 0.45, 0.4))
		var lc = Color(0.5, 0.5, 0.45) if lv <= 1 else Color(0.3, 0.9, 0.4)
		draw_string(font, Vector2(c_lvl, y + 15), str(lv), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, lc)
		y += rh
