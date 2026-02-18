## deck.gd
## 牌组管理器 - 标准52张扑克牌
extends Node

var cards: Array[CardData] = []
var draw_pile: Array[CardData] = []

func _ready() -> void:
	_create_standard_deck()
	shuffle()

## 创建标准52张扑克牌
func _create_standard_deck() -> void:
	cards.clear()
	for suit in CardData.Suit.values():
		for rank in CardData.Rank.values():
			var card = CardData.new()
			card.suit = suit
			card.rank = rank
			cards.append(card)

## 洗牌
func shuffle() -> void:
	draw_pile = cards.duplicate()
	## Fisher-Yates 洗牌算法
	for i in range(draw_pile.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = draw_pile[i]
		draw_pile[i] = draw_pile[j]
		draw_pile[j] = temp

## 抽一张牌
func draw_card() -> CardData:
	if draw_pile.is_empty():
		return null
	return draw_pile.pop_back()

## 抽多张牌
func draw_cards(count: int) -> Array[CardData]:
	var drawn: Array[CardData] = []
	for i in range(count):
		var card = draw_card()
		if card != null:
			drawn.append(card)
	return drawn

## 剩余牌数
func remaining() -> int:
	return draw_pile.size()
