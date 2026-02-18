## card_data.gd
## 卡牌数据类 - 定义一张扑克牌的基本信息
class_name CardData
extends Resource

enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES }
enum Rank {
	ACE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5,
	SIX = 6, SEVEN = 7, EIGHT = 8, NINE = 9, TEN = 10,
	JACK = 11, QUEEN = 12, KING = 13
}

@export var suit: Suit
@export var rank: Rank

## 获取牌的筹码值（Balatro 中每张牌的基础分值）
func get_chip_value() -> int:
	match rank:
		Rank.ACE: return 11
		Rank.KING, Rank.QUEEN, Rank.JACK: return 10
		_: return rank

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
			return Color(0.9, 0.15, 0.15)  # 红色
		_:
			return Color(0.1, 0.1, 0.1)  # 黑色

## 用于显示的完整名称
func get_display_name() -> String:
	return get_rank_text() + get_suit_symbol()
