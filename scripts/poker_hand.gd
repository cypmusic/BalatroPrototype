## poker_hand.gd
## 扑克牌型判定与计分系统 V6 - 集成卡牌增强计分
class_name PokerHand
extends RefCounted

enum HandType {
	HIGH_CARD,
	PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	STRAIGHT,
	FLUSH,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	STRAIGHT_FLUSH,
}

static func get_hand_name(type: HandType) -> String:
	match type:
		HandType.HIGH_CARD: return "High Card"
		HandType.PAIR: return "Pair"
		HandType.TWO_PAIR: return "Two Pair"
		HandType.THREE_OF_A_KIND: return "Three of a Kind"
		HandType.STRAIGHT: return "Straight"
		HandType.FLUSH: return "Flush"
		HandType.FULL_HOUSE: return "Full House"
		HandType.FOUR_OF_A_KIND: return "Four of a Kind"
		HandType.STRAIGHT_FLUSH: return "Straight Flush"
		_: return "Unknown"

static func get_base_score(type: HandType) -> Dictionary:
	match type:
		HandType.HIGH_CARD:        return {"chips": 5,   "mult": 1}
		HandType.PAIR:             return {"chips": 10,  "mult": 2}
		HandType.TWO_PAIR:         return {"chips": 20,  "mult": 2}
		HandType.THREE_OF_A_KIND:  return {"chips": 30,  "mult": 3}
		HandType.STRAIGHT:         return {"chips": 30,  "mult": 4}
		HandType.FLUSH:            return {"chips": 35,  "mult": 4}
		HandType.FULL_HOUSE:       return {"chips": 40,  "mult": 4}
		HandType.FOUR_OF_A_KIND:   return {"chips": 60,  "mult": 7}
		HandType.STRAIGHT_FLUSH:   return {"chips": 100, "mult": 8}
		_:                         return {"chips": 0,   "mult": 1}

## 判定一组牌的最佳牌型
static func evaluate(cards: Array) -> Dictionary:
	if cards.is_empty():
		return {"type": HandType.HIGH_CARD, "scoring_cards": []}

	var ranks: Array[int] = []
	var suits: Array[int] = []
	for card in cards:
		ranks.append(card.card_data.rank)
		suits.append(card.card_data.suit)

	var rank_counts: Dictionary = {}
	for r in ranks:
		rank_counts[r] = rank_counts.get(r, 0) + 1

	var is_flush_result = _is_flush(suits)
	var is_straight_result = _is_straight(ranks)

	if is_flush_result and is_straight_result and cards.size() >= 5:
		return {"type": HandType.STRAIGHT_FLUSH, "scoring_cards": cards}

	var four_cards = _find_n_of_a_kind(cards, rank_counts, 4)
	if four_cards.size() > 0:
		return {"type": HandType.FOUR_OF_A_KIND, "scoring_cards": four_cards}

	var three_cards = _find_n_of_a_kind(cards, rank_counts, 3)
	var pair_cards = _find_n_of_a_kind(cards, rank_counts, 2)
	if three_cards.size() > 0 and pair_cards.size() > 0:
		var full_house_cards: Array = []
		full_house_cards.append_array(three_cards)
		full_house_cards.append_array(pair_cards)
		return {"type": HandType.FULL_HOUSE, "scoring_cards": full_house_cards}

	if is_flush_result and cards.size() >= 5:
		return {"type": HandType.FLUSH, "scoring_cards": cards}

	if is_straight_result and cards.size() >= 5:
		return {"type": HandType.STRAIGHT, "scoring_cards": cards}

	if three_cards.size() > 0:
		return {"type": HandType.THREE_OF_A_KIND, "scoring_cards": three_cards}

	if pair_cards.size() >= 4:
		return {"type": HandType.TWO_PAIR, "scoring_cards": pair_cards.slice(0, 4)}

	if pair_cards.size() >= 2:
		return {"type": HandType.PAIR, "scoring_cards": pair_cards.slice(0, 2)}

	var highest = cards[0]
	for card in cards:
		if card.card_data.rank > highest.card_data.rank:
			highest = card
	return {"type": HandType.HIGH_CARD, "scoring_cards": [highest]}

## 计算最终得分（集成牌型升级 + 卡牌增强加成）
static func calculate_score(cards: Array) -> Dictionary:
	var eval_result = evaluate(cards)
	var hand_type: HandType = eval_result["type"]
	var scoring_cards: Array = eval_result["scoring_cards"]
	var base = get_base_score(hand_type)

	## 获取升级加成
	var level_bonus = HandLevel.get_bonus(hand_type)
	var level_info = HandLevel.get_level_info(hand_type)

	## 计算卡牌筹码 + 增强加成
	var card_chips: int = 0
	var enhancement_mult_add: int = 0
	var enhancement_mult_multiply: float = 1.0
	for card in scoring_cards:
		card_chips += card.card_data.get_chip_value()
		card_chips += card.card_data.get_enhancement_chips()
		enhancement_mult_add += card.card_data.get_enhancement_mult()
		enhancement_mult_multiply *= card.card_data.get_enhancement_mult_multiplier()

	var total_chips: int = base["chips"] + level_bonus["chips"] + card_chips
	var total_mult: int = base["mult"] + level_bonus["mult"] + enhancement_mult_add

	## 应用多彩乘数
	var total_mult_f: float = float(total_mult) * enhancement_mult_multiply
	total_mult = int(total_mult_f)
	if total_mult < 1:
		total_mult = 1

	var final_score: int = total_chips * total_mult

	return {
		"hand_type": hand_type,
		"hand_name": get_hand_name(hand_type),
		"base_chips": base["chips"],
		"base_mult": base["mult"],
		"level_bonus_chips": level_bonus["chips"],
		"level_bonus_mult": level_bonus["mult"],
		"level": level_info["level"],
		"card_chips": card_chips,
		"total_chips": total_chips,
		"total_mult": total_mult,
		"final_score": final_score,
		"scoring_cards": scoring_cards,
	}

## ========== 辅助函数 ==========

static func _is_flush(suits: Array[int]) -> bool:
	if suits.size() < 5:
		return false
	var first = suits[0]
	for s in suits:
		if s != first:
			return false
	return true

static func _is_straight(ranks: Array[int]) -> bool:
	if ranks.size() < 5:
		return false

	var unique_ranks = ranks.duplicate()
	unique_ranks.sort()

	var deduped: Array[int] = []
	for r in unique_ranks:
		if deduped.is_empty() or deduped[-1] != r:
			deduped.append(r)

	if deduped.size() < 5:
		return false

	var is_normal_straight = true
	for i in range(1, deduped.size()):
		if deduped[i] != deduped[i - 1] + 1:
			is_normal_straight = false
			break

	if is_normal_straight:
		return true

	var high_ace = deduped.duplicate()
	for i in range(high_ace.size()):
		if high_ace[i] == 1:
			high_ace[i] = 14
	high_ace.sort()

	var is_high_straight = true
	for i in range(1, high_ace.size()):
		if high_ace[i] != high_ace[i - 1] + 1:
			is_high_straight = false
			break

	return is_high_straight

static func _find_n_of_a_kind(cards: Array, rank_counts: Dictionary, n: int) -> Array:
	var result: Array = []
	var found_ranks: Array = []

	for rank in rank_counts:
		if rank_counts[rank] >= n:
			found_ranks.append(rank)

	found_ranks.sort()
	found_ranks.reverse()

	for rank in found_ranks:
		var count = 0
		for card in cards:
			if card.card_data.rank == rank and count < n:
				result.append(card)
				count += 1

	return result
