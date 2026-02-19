## joker_database.gd
## 小丑牌数据库 V2 - 16 张小丑牌
class_name JokerDatabase
extends RefCounted

static func get_all_jokers() -> Array[JokerData]:
	var jokers: Array[JokerData] = []

	## ============================================================
	## 普通小丑牌 (Rarity 0) - 简单直接的加成
	## ============================================================

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

	## 9. Sly Joker - +50 Chips（纯筹码型基础卡）
	var j9 = JokerData.new()
	j9.id = "sly_joker"
	j9.joker_name = "Sly Joker"
	j9.description = "+50 Chips"
	j9.emoji = "🦊"
	j9.rarity = 0
	j9.cost = 3
	j9.trigger = JokerData.TriggerType.ON_SCORE
	j9.effect = JokerData.EffectType.ADD_CHIPS
	j9.value = 50.0
	jokers.append(j9)

	## 13. Scary Face - 计分人头牌(J/Q/K)各 +30 Chips
	var j13 = JokerData.new()
	j13.id = "scary_face"
	j13.joker_name = "Scary Face"
	j13.description = "+30 Chips for each face card scored"
	j13.emoji = "😱"
	j13.rarity = 0
	j13.cost = 4
	j13.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j13.effect = JokerData.EffectType.ADD_CHIPS_IF
	j13.condition = JokerData.ConditionType.CARD_IS_FACE
	j13.value = 30.0
	jokers.append(j13)

	## ============================================================
	## 罕见小丑牌 (Rarity 1) - 更强的条件效果
	## ============================================================

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

	## 10. Banner - 每剩余1次弃牌 +30 Chips
	var j10 = JokerData.new()
	j10.id = "banner"
	j10.joker_name = "Banner"
	j10.description = "+30 Chips per discard remaining"
	j10.emoji = "🚩"
	j10.rarity = 1
	j10.cost = 5
	j10.trigger = JokerData.TriggerType.ON_SCORE_CONTEXT
	j10.effect = JokerData.EffectType.ADD_CHIPS_PER
	j10.condition = JokerData.ConditionType.DISCARDS_REMAINING
	j10.value = 30.0
	jokers.append(j10)

	## 11. Mystic Summit - 剩余0次弃牌时 +15 Mult
	var j11 = JokerData.new()
	j11.id = "mystic_summit"
	j11.joker_name = "Mystic Summit"
	j11.description = "+15 Mult when 0 discards remaining"
	j11.emoji = "🏔️"
	j11.rarity = 1
	j11.cost = 6
	j11.trigger = JokerData.TriggerType.ON_SCORE_CONTEXT
	j11.effect = JokerData.EffectType.ADD_MULT_IF
	j11.condition = JokerData.ConditionType.DISCARDS_REMAINING
	j11.condition_value = 0  ## 剩余弃牌 == 0 时触发
	j11.value = 15.0
	jokers.append(j11)

	## 12. Fibonacci - 计分的 A/2/3/5/8 各 +8 Mult
	var j12 = JokerData.new()
	j12.id = "fibonacci"
	j12.joker_name = "Fibonacci"
	j12.description = "+8 Mult for each A,2,3,5,8 scored"
	j12.emoji = "🐚"
	j12.rarity = 1
	j12.cost = 7
	j12.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j12.effect = JokerData.EffectType.ADD_MULT_IF
	j12.condition = JokerData.ConditionType.CARD_RANK_LIST
	j12.condition_values = [14, 2, 3, 5, 8]  ## A=14, 2, 3, 5, 8
	j12.value = 8.0
	jokers.append(j12)

	## 14. Even Steven - 计分偶数牌(2/4/6/8/10)各 +4 Mult
	var j14 = JokerData.new()
	j14.id = "even_steven"
	j14.joker_name = "Even Steven"
	j14.description = "+4 Mult for each even card scored"
	j14.emoji = "⚖️"
	j14.rarity = 1
	j14.cost = 6
	j14.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j14.effect = JokerData.EffectType.ADD_MULT_IF
	j14.condition = JokerData.ConditionType.CARD_RANK_EVEN
	j14.value = 4.0
	jokers.append(j14)

	## 15. Odd Todd - 计分奇数牌(A/3/5/7/9)各 +30 Chips
	var j15 = JokerData.new()
	j15.id = "odd_todd"
	j15.joker_name = "Odd Todd"
	j15.description = "+30 Chips for each odd card scored"
	j15.emoji = "🎲"
	j15.rarity = 1
	j15.cost = 6
	j15.trigger = JokerData.TriggerType.ON_CARD_SCORED
	j15.effect = JokerData.EffectType.ADD_CHIPS_IF
	j15.condition = JokerData.ConditionType.CARD_RANK_ODD
	j15.value = 30.0
	jokers.append(j15)

	## ============================================================
	## 稀有小丑牌 (Rarity 2) - 强力乘法效果
	## ============================================================

	## 8. The Duo - 牌型含 Pair 时 ×2 Mult
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
	j8.condition_value = PokerHand.HandType.PAIR
	j8.value = 2.0
	jokers.append(j8)

	## 16. The Trio - 牌型含三条时 ×3 Mult
	var j16 = JokerData.new()
	j16.id = "the_trio"
	j16.joker_name = "The Trio"
	j16.description = "×3 Mult if hand contains Three of a Kind"
	j16.emoji = "🎭"
	j16.rarity = 2
	j16.cost = 8
	j16.trigger = JokerData.TriggerType.ON_HAND_PLAYED
	j16.effect = JokerData.EffectType.MULTIPLY_MULT_IF
	j16.condition = JokerData.ConditionType.HAND_TYPE
	j16.condition_value = PokerHand.HandType.THREE_OF_A_KIND
	j16.value = 3.0
	jokers.append(j16)

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
