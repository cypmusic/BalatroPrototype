## joker_database.gd
## 小丑牌数据库 - 首批 8 张基础小丑牌
class_name JokerDatabase
extends RefCounted

## 创建所有小丑牌数据
static func get_all_jokers() -> Array[JokerData]:
	var jokers: Array[JokerData] = []

	## === 普通小丑牌（简单直接的加成）===

	## 1. Joker - 最基础的小丑，+4 Mult
	var j1 = JokerData.new()
	j1.id = "joker"
	j1.joker_name = "Joker"
	j1.description = "+4 Mult"
	j1.emoji = "🃏"
	j1.rarity = 0
	j1.cost = 2
	j1.trigger = JokerData.TriggerType.ON_SCORE
	j1.effect = JokerData.EffectType.ADD_MULT
	j1.value = 4.0
	jokers.append(j1)

	## 2. Greedy Joker - 每张计分的♦ +3 Mult
	var j2 = JokerData.new()
	j2.id = "greedy_joker"
	j2.joker_name = "Greedy Joker"
	j2.description = "+3 Mult for each ♦ scored"
	j2.emoji = "💰"
	j2.rarity = 0
	j2.cost = 5
	j2.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j2.effect = JokerData.EffectType.ADD_MULT_IF
	j2.condition = JokerData.ConditionType.CARD_SUIT
	j2.condition_value = CardData.Suit.DIAMONDS
	j2.value = 3.0
	jokers.append(j2)

	## 3. Lusty Joker - 每张计分的♥ +3 Mult
	var j3 = JokerData.new()
	j3.id = "lusty_joker"
	j3.joker_name = "Lusty Joker"
	j3.description = "+3 Mult for each ♥ scored"
	j3.emoji = "❤️"
	j3.rarity = 0
	j3.cost = 5
	j3.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j3.effect = JokerData.EffectType.ADD_MULT_IF
	j3.condition = JokerData.ConditionType.CARD_SUIT
	j3.condition_value = CardData.Suit.HEARTS
	j3.value = 3.0
	jokers.append(j3)

	## 4. Wrathful Joker - 每张计分的♠ +3 Mult
	var j4 = JokerData.new()
	j4.id = "wrathful_joker"
	j4.joker_name = "Wrathful Joker"
	j4.description = "+3 Mult for each ♠ scored"
	j4.emoji = "🗡️"
	j4.rarity = 0
	j4.cost = 5
	j4.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j4.effect = JokerData.EffectType.ADD_MULT_IF
	j4.condition = JokerData.ConditionType.CARD_SUIT
	j4.condition_value = CardData.Suit.SPADES
	j4.value = 3.0
	jokers.append(j4)

	## 5. Glutton Joker - 每张计分的♣ +3 Mult
	var j5 = JokerData.new()
	j5.id = "glutton_joker"
	j5.joker_name = "Glutton Joker"
	j5.description = "+3 Mult for each ♣ scored"
	j5.emoji = "🍀"
	j5.rarity = 0
	j5.cost = 5
	j5.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j5.effect = JokerData.EffectType.ADD_MULT_IF
	j5.condition = JokerData.ConditionType.CARD_SUIT
	j5.condition_value = CardData.Suit.CLUBS
	j5.value = 3.0
	jokers.append(j5)

	## === 罕见小丑牌（更强的效果）===

	## 6. Jolly Joker - 打出 Pair 时 +8 Mult
	var j6 = JokerData.new()
	j6.id = "jolly_joker"
	j6.joker_name = "Jolly Joker"
	j6.description = "+8 Mult if hand is Pair"
	j6.emoji = "🎪"
	j6.rarity = 1
	j6.cost = 6
	j6.trigger = JokerData.TriggerType.ON_HAND_PLAYED
	j6.effect = JokerData.EffectType.ADD_MULT_IF
	j6.condition = JokerData.ConditionType.HAND_TYPE
	j6.condition_value = PokerHand.HandType.PAIR
	j6.value = 8.0
	jokers.append(j6)

	## 7. Zany Joker - 打出 Three of a Kind 时 +12 Mult
	var j7 = JokerData.new()
	j7.id = "zany_joker"
	j7.joker_name = "Zany Joker"
	j7.description = "+12 Mult if Three of a Kind"
	j7.emoji = "🤪"
	j7.rarity = 1
	j7.cost = 6
	j7.trigger = JokerData.TriggerType.ON_HAND_PLAYED
	j7.effect = JokerData.EffectType.ADD_MULT_IF
	j7.condition = JokerData.ConditionType.HAND_TYPE
	j7.condition_value = PokerHand.HandType.THREE_OF_A_KIND
	j7.value = 12.0
	jokers.append(j7)

	## === 稀有小丑牌（乘法效果，非常强力）===

	## 8. The Duo - 打出包含 Pair 的牌型时 ×2 Mult
	var j8 = JokerData.new()
	j8.id = "the_duo"
	j8.joker_name = "The Duo"
	j8.description = "×2 Mult if hand contains a Pair"
	j8.emoji = "👯"
	j8.rarity = 2
	j8.cost = 8
	j8.trigger = JokerData.TriggerType.ON_HAND_PLAYED
	j8.effect = JokerData.EffectType.MULTIPLY_MULT_IF
	j8.condition = JokerData.ConditionType.HAND_TYPE
	## 这个比较特殊：只要牌型 >= Pair 就触发
	j8.condition_value = PokerHand.HandType.PAIR
	j8.value = 2.0
	jokers.append(j8)

	return jokers

## 获取随机 N 张小丑牌（用于商店）
static func get_random_jokers(count: int, exclude_ids: Array = []) -> Array[JokerData]:
	var all = get_all_jokers()
	var available: Array[JokerData] = []
	for j in all:
		if not exclude_ids.has(j.id):
			available.append(j)

	available.shuffle()
	var result: Array[JokerData] = []
	for i in range(mini(count, available.size())):
		result.append(available[i])
	return result
