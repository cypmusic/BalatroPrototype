## card_data.gd
## 卡牌数据类 V2 - 新增增强系统 (Foil / Holographic / Polychrome)
class_name CardData
extends Resource

enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES }
enum Rank {
	ACE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5,
	SIX = 6, SEVEN = 7, EIGHT = 8, NINE = 9, TEN = 10,
	JACK = 11, QUEEN = 12, KING = 13
}

## 增强类型
enum Enhancement {
	NONE,
	FOIL,          ## 箔片 - +50 Chips
	HOLOGRAPHIC,   ## 全息 - +10 Mult
	POLYCHROME,    ## 多彩 - ×1.5 Mult
}

@export var suit: Suit
@export var rank: Rank
@export var enhancement: Enhancement = Enhancement.NONE

## 获取牌的筹码值（Balatro 中每张牌的基础分值）
func get_chip_value() -> int:
	match rank:
		Rank.ACE: return 11
		Rank.KING, Rank.QUEEN, Rank.JACK: return 10
		_: return rank

## 获取增强提供的额外筹码
func get_enhancement_chips() -> int:
	if enhancement == Enhancement.FOIL:
		return 50
	return 0

## 获取增强提供的额外倍率（加法）
func get_enhancement_mult() -> int:
	if enhancement == Enhancement.HOLOGRAPHIC:
		return 10
	return 0

## 获取增强提供的倍率乘数
func get_enhancement_mult_multiplier() -> float:
	if enhancement == Enhancement.POLYCHROME:
		return 1.5
	return 1.0

## 获取增强名称
func get_enhancement_name() -> String:
	match enhancement:
		Enhancement.FOIL: return "Foil"
		Enhancement.HOLOGRAPHIC: return "Holographic"
		Enhancement.POLYCHROME: return "Polychrome"
		_: return ""

## 获取增强颜色（用于边框/光效）
func get_enhancement_color() -> Color:
	match enhancement:
		Enhancement.FOIL: return Color(0.4, 0.6, 0.95)
		Enhancement.HOLOGRAPHIC: return Color(0.9, 0.4, 0.8)
		Enhancement.POLYCHROME: return Color(0.95, 0.85, 0.2)
		_: return Color.WHITE

## 获取花色的显示符号
func get_suit_symbol() -> String:
	match suit:
		Suit.HEARTS: return "♥"
		Suit.DIAMONDS: return "♦"
		Suit.CLUBS: return "♣"
		Suit.SPADES: return "♠"
		_: return "?"

## 获取牌面的显示文字
func get_rank_text() -> String:
	match rank:
		Rank.ACE: return "A"
		Rank.JACK: return "J"
		Rank.QUEEN: return "Q"
		Rank.KING: return "K"
		_: return str(rank)

## 获取花色颜色
func get_suit_color() -> Color:
	match suit:
		Suit.HEARTS, Suit.DIAMONDS:
			return Color(0.9, 0.15, 0.15)
		_:
			return Color(0.1, 0.1, 0.1)

## 用于显示的完整名称
func get_display_name() -> String:
	var base = get_rank_text() + get_suit_symbol()
	if enhancement != Enhancement.NONE:
		return get_enhancement_name() + " " + base
	return base
