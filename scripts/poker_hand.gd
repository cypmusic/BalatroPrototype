## poker_hand.gd
## 扑克牌型判定与计分系统 V0.086 — 28种牌型 + 6卡支持
## 支持5卡基础牌型(10种) + 6卡扩展牌型(18种)
class_name PokerHand
extends RefCounted

enum HandType {
	## === 5卡基础牌型 (10) ===
	HIGH_CARD,           ## 高牌
	PAIR,                ## 对子
	TWO_PAIR,            ## 两对
	THREE_OF_A_KIND,     ## 三条
	STRAIGHT,            ## 顺子
	FLUSH,               ## 同花
	FULL_HOUSE,          ## 葫芦 (3+2)
	FOUR_OF_A_KIND,      ## 四条
	STRAIGHT_FLUSH,      ## 同花顺
	ROYAL_FLUSH,         ## 皇家同花顺 (10-J-Q-K-A同花)

	## === 6卡扩展牌型 — 需要天书"阴符经"解锁 ===
	FIVE_OF_A_KIND,      ## 五条 (5张同点)
	FLUSH_HOUSE,         ## 同花葫芦 (同花+葫芦)
	FLUSH_FIVE,          ## 同花五条 (同花+五条)
	DOUBLE_THREE,        ## 双三条 (3+3)
	TRIPLE_PAIR,         ## 三对 (2+2+2)
	FOUR_ONE_ONE,        ## 四带二单 (4+1+1)
	FULL_HOUSE_PLUS,     ## 大葫芦 (3+2+1 或 4+2)
	STRAIGHT_SIX,        ## 六连顺
	FLUSH_SIX,           ## 六花 (6张同花)
	STRAIGHT_FLUSH_SIX,  ## 六连同花顺
	FULL_FLUSH,          ## 满花 (同花+葫芦6卡)
	FOUR_TWO,            ## 四带一对 (4+2)
	TWO_THREE,           ## 二三 (2+3=5卡,6卡场景下的评估)
	PAIR_FOUR,           ## 对加四条 (2+4)
	ROYAL_FLUSH_SIX,     ## 六皇家同花顺 (9-10-J-Q-K-A同花)
	SIX_OF_A_KIND,       ## 六条 (6张同点)
	FLUSH_SIX_KIND,      ## 同花六条 (同花+六条)
	ROYAL_SIX_KIND,      ## 皇家六条 (6张同花同点且为皇家)
}

## 牌型排行值 — 越高越强，用于比较牌型优劣
static func get_hand_power(type: HandType) -> int:
	match type:
		HandType.HIGH_CARD:          return 1
		HandType.PAIR:               return 2
		HandType.TWO_PAIR:           return 3
		HandType.THREE_OF_A_KIND:    return 4
		HandType.STRAIGHT:           return 5
		HandType.FLUSH:              return 6
		HandType.FULL_HOUSE:         return 7
		HandType.FOUR_OF_A_KIND:     return 8
		HandType.DOUBLE_THREE:       return 9
		HandType.TRIPLE_PAIR:        return 10
		HandType.FOUR_ONE_ONE:       return 11
		HandType.TWO_THREE:          return 12
		HandType.PAIR_FOUR:          return 13
		HandType.FULL_HOUSE_PLUS:    return 14
		HandType.STRAIGHT_FLUSH:     return 15
		HandType.ROYAL_FLUSH:        return 16
		HandType.FIVE_OF_A_KIND:     return 17
		HandType.FOUR_TWO:           return 18
		HandType.FLUSH_HOUSE:        return 19
		HandType.STRAIGHT_SIX:       return 20
		HandType.FLUSH_SIX:          return 21
		HandType.FLUSH_FIVE:         return 22
		HandType.STRAIGHT_FLUSH_SIX: return 23
		HandType.FULL_FLUSH:         return 24
		HandType.ROYAL_FLUSH_SIX:    return 25
		HandType.SIX_OF_A_KIND:      return 26
		HandType.FLUSH_SIX_KIND:     return 27
		HandType.ROYAL_SIX_KIND:     return 28
		_: return 0

static func get_hand_name(type: HandType) -> String:
	match type:
		HandType.HIGH_CARD:          return "High Card"
		HandType.PAIR:               return "Pair"
		HandType.TWO_PAIR:           return "Two Pair"
		HandType.THREE_OF_A_KIND:    return "Three of a Kind"
		HandType.STRAIGHT:           return "Straight"
		HandType.FLUSH:              return "Flush"
		HandType.FULL_HOUSE:         return "Full House"
		HandType.FOUR_OF_A_KIND:     return "Four of a Kind"
		HandType.STRAIGHT_FLUSH:     return "Straight Flush"
		HandType.ROYAL_FLUSH:        return "Royal Flush"
		HandType.FIVE_OF_A_KIND:     return "Five of a Kind"
		HandType.FLUSH_HOUSE:        return "Flush House"
		HandType.FLUSH_FIVE:         return "Flush Five"
		HandType.DOUBLE_THREE:       return "Double Three"
		HandType.TRIPLE_PAIR:        return "Triple Pair"
		HandType.FOUR_ONE_ONE:       return "Four-One-One"
		HandType.FULL_HOUSE_PLUS:    return "Full House Plus"
		HandType.STRAIGHT_SIX:       return "Straight Six"
		HandType.FLUSH_SIX:          return "Flush Six"
		HandType.STRAIGHT_FLUSH_SIX: return "Straight Flush Six"
		HandType.FULL_FLUSH:         return "Full Flush"
		HandType.FOUR_TWO:           return "Four-Two"
		HandType.TWO_THREE:          return "Two-Three"
		HandType.PAIR_FOUR:          return "Pair-Four"
		HandType.ROYAL_FLUSH_SIX:    return "Royal Flush Six"
		HandType.SIX_OF_A_KIND:      return "Six of a Kind"
		HandType.FLUSH_SIX_KIND:     return "Flush Six of a Kind"
		HandType.ROYAL_SIX_KIND:     return "Royal Six of a Kind"
		_: return "Unknown"

static func get_base_score(type: HandType) -> Dictionary:
	match type:
		## 5卡基础牌型
		HandType.HIGH_CARD:          return {"chips": 5,   "mult": 1}
		HandType.PAIR:               return {"chips": 10,  "mult": 2}
		HandType.TWO_PAIR:           return {"chips": 20,  "mult": 2}
		HandType.THREE_OF_A_KIND:    return {"chips": 30,  "mult": 3}
		HandType.STRAIGHT:           return {"chips": 30,  "mult": 4}
		HandType.FLUSH:              return {"chips": 35,  "mult": 4}
		HandType.FULL_HOUSE:         return {"chips": 40,  "mult": 4}
		HandType.FOUR_OF_A_KIND:     return {"chips": 60,  "mult": 7}
		HandType.STRAIGHT_FLUSH:     return {"chips": 100, "mult": 8}
		HandType.ROYAL_FLUSH:        return {"chips": 120, "mult": 10}
		## 6卡扩展牌型
		HandType.FIVE_OF_A_KIND:     return {"chips": 80,  "mult": 12}
		HandType.FLUSH_HOUSE:        return {"chips": 80,  "mult": 10}
		HandType.FLUSH_FIVE:         return {"chips": 100, "mult": 14}
		HandType.DOUBLE_THREE:       return {"chips": 50,  "mult": 5}
		HandType.TRIPLE_PAIR:        return {"chips": 45,  "mult": 4}
		HandType.FOUR_ONE_ONE:       return {"chips": 55,  "mult": 6}
		HandType.FULL_HOUSE_PLUS:    return {"chips": 60,  "mult": 7}
		HandType.STRAIGHT_SIX:       return {"chips": 60,  "mult": 7}
		HandType.FLUSH_SIX:          return {"chips": 70,  "mult": 8}
		HandType.STRAIGHT_FLUSH_SIX: return {"chips": 140, "mult": 14}
		HandType.FULL_FLUSH:         return {"chips": 100, "mult": 12}
		HandType.FOUR_TWO:           return {"chips": 70,  "mult": 8}
		HandType.TWO_THREE:          return {"chips": 45,  "mult": 5}
		HandType.PAIR_FOUR:          return {"chips": 75,  "mult": 9}
		HandType.ROYAL_FLUSH_SIX:    return {"chips": 180, "mult": 18}
		HandType.SIX_OF_A_KIND:      return {"chips": 150, "mult": 16}
		HandType.FLUSH_SIX_KIND:     return {"chips": 200, "mult": 20}
		HandType.ROYAL_SIX_KIND:     return {"chips": 250, "mult": 25}
		_:                           return {"chips": 0,   "mult": 1}

## 是否为6卡牌型
static func is_six_card_hand(type: HandType) -> bool:
	return type >= HandType.FIVE_OF_A_KIND

## 获取所有手牌类型（用于HandLevel等）
static func get_all_hand_types() -> Array:
	return [
		HandType.HIGH_CARD, HandType.PAIR, HandType.TWO_PAIR,
		HandType.THREE_OF_A_KIND, HandType.STRAIGHT, HandType.FLUSH,
		HandType.FULL_HOUSE, HandType.FOUR_OF_A_KIND, HandType.STRAIGHT_FLUSH,
		HandType.ROYAL_FLUSH, HandType.FIVE_OF_A_KIND, HandType.FLUSH_HOUSE,
		HandType.FLUSH_FIVE, HandType.DOUBLE_THREE, HandType.TRIPLE_PAIR,
		HandType.FOUR_ONE_ONE, HandType.FULL_HOUSE_PLUS, HandType.STRAIGHT_SIX,
		HandType.FLUSH_SIX, HandType.STRAIGHT_FLUSH_SIX, HandType.FULL_FLUSH,
		HandType.FOUR_TWO, HandType.TWO_THREE, HandType.PAIR_FOUR,
		HandType.ROYAL_FLUSH_SIX, HandType.SIX_OF_A_KIND,
		HandType.FLUSH_SIX_KIND, HandType.ROYAL_SIX_KIND,
	]

## ============================================================
## 判定一组牌的最佳牌型（支持5卡和6卡）
## ============================================================
static func evaluate(cards: Array) -> Dictionary:
	if cards.is_empty():
		return {"type": HandType.HIGH_CARD, "scoring_cards": []}

	var n = cards.size()
	var ranks: Array[int] = []
	var suits: Array[int] = []
	for card in cards:
		ranks.append(card.card_data.rank)
		suits.append(card.card_data.suit)

	var rank_counts: Dictionary = {}
	for r in ranks:
		rank_counts[r] = rank_counts.get(r, 0) + 1

	## 按频率分组
	var count_groups = _get_count_groups(rank_counts)

	var is_all_flush = _is_flush(suits, n)
	var is_straight_5 = _is_straight(ranks) if n >= 5 else false
	var is_straight_6 = _is_straight_6(ranks) if n == 6 else false
	var is_royal = _is_royal(ranks, n)

	## ====== 6卡判定优先（仅当出了6张牌时） ======
	if n == 6:
		## 皇家六条: 6张同花+同点+皇家点数(10/J/Q/K/A)
		if is_all_flush and count_groups.has(6) and _is_royal_rank(ranks[0]):
			return {"type": HandType.ROYAL_SIX_KIND, "scoring_cards": cards}

		## 同花六条: 6张同花+同点
		if is_all_flush and count_groups.has(6):
			return {"type": HandType.FLUSH_SIX_KIND, "scoring_cards": cards}

		## 六条: 6张同点
		if count_groups.has(6):
			return {"type": HandType.SIX_OF_A_KIND, "scoring_cards": cards}

		## 六皇家同花顺: 6连顺+同花+含皇家
		if is_all_flush and is_straight_6 and _is_royal_six(ranks):
			return {"type": HandType.ROYAL_FLUSH_SIX, "scoring_cards": cards}

		## 满花 (Full Flush): 同花 + 葫芦格式(3+3或3+2+1等)
		if is_all_flush and count_groups.has(3):
			var threes_count = count_groups[3]
			if threes_count >= 2:
				return {"type": HandType.FULL_FLUSH, "scoring_cards": cards}
			elif count_groups.has(2):
				return {"type": HandType.FULL_FLUSH, "scoring_cards": cards}

		## 六连同花顺: 6连顺+同花
		if is_all_flush and is_straight_6:
			return {"type": HandType.STRAIGHT_FLUSH_SIX, "scoring_cards": cards}

		## 同花五条: 5同点+同花 (6卡场景下，5张同点+1张同花)
		if is_all_flush and count_groups.has(5):
			return {"type": HandType.FLUSH_FIVE, "scoring_cards": cards}

		## 同花葫芦(6卡): 同花 + 3+2(+1)
		if is_all_flush and count_groups.has(3) and count_groups.has(2):
			return {"type": HandType.FLUSH_HOUSE, "scoring_cards": cards}

		## 六花: 6张同花 (无顺子/组合)
		if is_all_flush:
			return {"type": HandType.FLUSH_SIX, "scoring_cards": cards}

		## 对加四条 (2+4): 有4条和对子
		if count_groups.has(4) and count_groups.has(2):
			return {"type": HandType.PAIR_FOUR, "scoring_cards": cards}

		## 五条(5张同点+1散)
		if count_groups.has(5):
			var five_cards = _find_n_of_a_kind(cards, rank_counts, 5)
			return {"type": HandType.FIVE_OF_A_KIND, "scoring_cards": five_cards}

		## 四带一对: 4条+2条
		if count_groups.has(4) and count_groups.has(2):
			return {"type": HandType.FOUR_TWO, "scoring_cards": cards}

		## 大葫芦 (Full House Plus): 4+1+1 或 3+2+1
		## 注: 3+2+1 is just a Full House with extra card; 4+2 handled above
		## Re-check: FULL_HOUSE_PLUS = 3+2+1
		if count_groups.has(3) and count_groups.has(2):
			return {"type": HandType.FULL_HOUSE_PLUS, "scoring_cards": cards}

		## 六连顺: 6连顺
		if is_straight_6:
			return {"type": HandType.STRAIGHT_SIX, "scoring_cards": cards}

		## 四带二单 (4+1+1): 有4条但无对子
		if count_groups.has(4):
			return {"type": HandType.FOUR_ONE_ONE, "scoring_cards": cards}

		## 双三条 (3+3): 两组三条
		if count_groups.has(3) and count_groups.get(3, 0) >= 2:
			return {"type": HandType.DOUBLE_THREE, "scoring_cards": cards}

		## 二三 (2+3+1 → pair+three): 三条+对子+散牌(和大葫芦区分)
		## 实际上: 如果有3条+2条，上面已返回FULL_HOUSE_PLUS
		## TWO_THREE 用于 3条+单+单+单？不，根据设计是 2+3
		## 重新理解: TWO_THREE = 一个对子+一个三条(与FULL_HOUSE_PLUS相同结构，不同命名)
		## 此处简化: THREE_OF_A_KIND + 散牌(6卡场景)
		if count_groups.has(3):
			var three_cards_6 = _find_n_of_a_kind(cards, rank_counts, 3)
			return {"type": HandType.THREE_OF_A_KIND, "scoring_cards": three_cards_6}

		## 三对 (2+2+2): 三组对子
		if count_groups.has(2) and count_groups.get(2, 0) >= 3:
			return {"type": HandType.TRIPLE_PAIR, "scoring_cards": cards}

		## 两对 + 散牌
		if count_groups.has(2) and count_groups.get(2, 0) >= 2:
			var pair_cards_6 = _find_pairs(cards, rank_counts, 2)
			return {"type": HandType.TWO_PAIR, "scoring_cards": pair_cards_6}

		## 对子
		if count_groups.has(2):
			var pair_cards_6b = _find_n_of_a_kind(cards, rank_counts, 2)
			return {"type": HandType.PAIR, "scoring_cards": pair_cards_6b}

		## 高牌
		var highest_6 = _find_highest(cards)
		return {"type": HandType.HIGH_CARD, "scoring_cards": [highest_6]}

	## ====== 5卡判定（经典牌型） ======
	if n >= 5:
		## 皇家同花顺
		if is_all_flush and is_straight_5 and is_royal:
			return {"type": HandType.ROYAL_FLUSH, "scoring_cards": cards}

		## 同花顺
		if is_all_flush and is_straight_5:
			return {"type": HandType.STRAIGHT_FLUSH, "scoring_cards": cards}

	## 四条
	var four_cards = _find_n_of_a_kind(cards, rank_counts, 4)
	if four_cards.size() > 0:
		return {"type": HandType.FOUR_OF_A_KIND, "scoring_cards": four_cards}

	## 葫芦
	var three_cards = _find_n_of_a_kind(cards, rank_counts, 3)
	var pair_cards = _find_n_of_a_kind(cards, rank_counts, 2)
	if three_cards.size() > 0 and pair_cards.size() > 0:
		var full_house_cards: Array = []
		full_house_cards.append_array(three_cards)
		full_house_cards.append_array(pair_cards)
		return {"type": HandType.FULL_HOUSE, "scoring_cards": full_house_cards}

	## 同花
	if is_all_flush and n >= 5:
		return {"type": HandType.FLUSH, "scoring_cards": cards}

	## 顺子
	if is_straight_5 and n >= 5:
		return {"type": HandType.STRAIGHT, "scoring_cards": cards}

	## 三条
	if three_cards.size() > 0:
		return {"type": HandType.THREE_OF_A_KIND, "scoring_cards": three_cards}

	## 两对
	if pair_cards.size() >= 4:
		return {"type": HandType.TWO_PAIR, "scoring_cards": pair_cards.slice(0, 4)}

	## 对子
	if pair_cards.size() >= 2:
		return {"type": HandType.PAIR, "scoring_cards": pair_cards.slice(0, 2)}

	## 高牌
	var highest = _find_highest(cards)
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

## ============================================================
## 辅助函数
## ============================================================

## 检查是否全同花
static func _is_flush(suits: Array[int], min_count: int = 5) -> bool:
	if suits.size() < min_count:
		return false
	var first = suits[0]
	for s in suits:
		if s != first:
			return false
	return true

## 5卡顺子判定
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

	## 只取前5张判定
	var check = deduped.slice(0, 5)
	var is_normal = true
	for i in range(1, check.size()):
		if check[i] != check[i - 1] + 1:
			is_normal = false
			break
	if is_normal:
		return true

	## Ace-high 顺子 (A当14)
	var high_ace = deduped.duplicate()
	for i in range(high_ace.size()):
		if high_ace[i] == 1:
			high_ace[i] = 14
	high_ace.sort()

	check = high_ace.slice(high_ace.size() - 5)
	var is_high = true
	for i in range(1, check.size()):
		if check[i] != check[i - 1] + 1:
			is_high = false
			break

	return is_high

## 6卡顺子判定
static func _is_straight_6(ranks: Array[int]) -> bool:
	if ranks.size() != 6:
		return false

	var unique_ranks = ranks.duplicate()
	unique_ranks.sort()

	var deduped: Array[int] = []
	for r in unique_ranks:
		if deduped.is_empty() or deduped[-1] != r:
			deduped.append(r)

	if deduped.size() < 6:
		return false

	var is_normal = true
	for i in range(1, 6):
		if deduped[i] != deduped[i - 1] + 1:
			is_normal = false
			break
	if is_normal:
		return true

	## Ace-high 6顺 (9-10-J-Q-K-A)
	var high_ace = deduped.duplicate()
	for i in range(high_ace.size()):
		if high_ace[i] == 1:
			high_ace[i] = 14
	high_ace.sort()

	var is_high = true
	for i in range(1, 6):
		if high_ace[i] != high_ace[i - 1] + 1:
			is_high = false
			break

	return is_high

## 检查是否为皇家(5卡: 10-J-Q-K-A)
static func _is_royal(ranks: Array[int], count: int = 5) -> bool:
	if count < 5:
		return false
	var adjusted: Array[int] = []
	for r in ranks:
		if r == 1:
			adjusted.append(14)
		else:
			adjusted.append(r)
	adjusted.sort()
	## 5卡皇家: 10,11,12,13,14
	var royal_5 = [10, 11, 12, 13, 14]
	if adjusted.size() >= 5:
		var last_5 = adjusted.slice(adjusted.size() - 5)
		if last_5 == royal_5:
			return true
	return false

## 检查是否为6卡皇家(9-10-J-Q-K-A)
static func _is_royal_six(ranks: Array[int]) -> bool:
	var adjusted: Array[int] = []
	for r in ranks:
		if r == 1:
			adjusted.append(14)
		else:
			adjusted.append(r)
	adjusted.sort()
	return adjusted == [9, 10, 11, 12, 13, 14]

## 检查是否为皇家点数(10/J/Q/K/A)
static func _is_royal_rank(rank: int) -> bool:
	return rank == 1 or rank >= 10  ## A=1, 10, J=11, Q=12, K=13

## 获取点数频率分组 {频率: 出现次数}
static func _get_count_groups(rank_counts: Dictionary) -> Dictionary:
	var groups: Dictionary = {}
	for rank in rank_counts:
		var count = rank_counts[rank]
		groups[count] = groups.get(count, 0) + 1
	return groups

## 查找最高牌
static func _find_highest(cards: Array):
	var highest = cards[0]
	for card in cards:
		var r = card.card_data.rank
		var hr = highest.card_data.rank
		## A(1) 视为最大
		if r == 1:
			highest = card
		elif hr != 1 and r > hr:
			highest = card
	return highest

## 查找N条
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

## 查找指定数量的对子的所有牌
static func _find_pairs(cards: Array, rank_counts: Dictionary, pair_count: int) -> Array:
	var pair_ranks: Array = []
	for rank in rank_counts:
		if rank_counts[rank] >= 2:
			pair_ranks.append(rank)
	pair_ranks.sort()
	pair_ranks.reverse()

	var result: Array = []
	var pairs_found = 0
	for rank in pair_ranks:
		if pairs_found >= pair_count:
			break
		var count = 0
		for card in cards:
			if card.card_data.rank == rank and count < 2:
				result.append(card)
				count += 1
		pairs_found += 1

	return result
