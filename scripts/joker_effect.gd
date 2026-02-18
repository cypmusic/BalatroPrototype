## joker_effect.gd
## 小丑牌效果处理器 - 在计分流程中计算所有小丑牌的加成
class_name JokerEffect
extends RefCounted

## 处理所有小丑牌对计分的影响
## active_jokers: 当前持有的小丑牌数据数组
## base_result: PokerHand.calculate_score() 的结果
## scoring_cards: 参与计分的牌
## 返回修改后的 { total_chips, total_mult, final_score, joker_triggers: [...] }
static func apply_jokers(active_jokers: Array, base_result: Dictionary, scoring_cards: Array) -> Dictionary:
	var chips: int = base_result["total_chips"]
	var mult: float = float(base_result["total_mult"])
	var hand_type = base_result["hand_type"]
	var triggers: Array = []  ## 记录哪些小丑牌触发了（用于动画）

	for joker_data in active_jokers:
		var triggered = false
		var trigger_text = ""

		match joker_data.trigger:
			## ON_SCORE: 无条件，每次计分都触发
			JokerData.TriggerType.ON_SCORE:
				match joker_data.effect:
					JokerData.EffectType.ADD_MULT:
						mult += joker_data.value
						triggered = true
						trigger_text = "+" + str(int(joker_data.value)) + " Mult"
					JokerData.EffectType.ADD_CHIPS:
						chips += int(joker_data.value)
						triggered = true
						trigger_text = "+" + str(int(joker_data.value)) + " Chips"
					JokerData.EffectType.MULTIPLY_MULT:
						mult *= joker_data.value
						triggered = true
						trigger_text = "×" + str(joker_data.value) + " Mult"

			## ON_CARD_SCORED: 每张计分牌各自检查
			JokerData.TriggerType.ON_CARD_SCORED:
				var card_trigger_count = 0
				for card in scoring_cards:
					if _check_card_condition(joker_data, card):
						card_trigger_count += 1

				if card_trigger_count > 0:
					match joker_data.effect:
						JokerData.EffectType.ADD_MULT_IF:
							var bonus = joker_data.value * card_trigger_count
							mult += bonus
							triggered = true
							trigger_text = "+" + str(int(bonus)) + " Mult (" + str(card_trigger_count) + "×)"
						JokerData.EffectType.ADD_CHIPS_IF:
							var bonus = int(joker_data.value) * card_trigger_count
							chips += bonus
							triggered = true
							trigger_text = "+" + str(bonus) + " Chips (" + str(card_trigger_count) + "×)"

			## ON_HAND_PLAYED: 根据牌型触发
			JokerData.TriggerType.ON_HAND_PLAYED:
				if _check_hand_condition(joker_data, hand_type):
					match joker_data.effect:
						JokerData.EffectType.ADD_MULT_IF:
							mult += joker_data.value
							triggered = true
							trigger_text = "+" + str(int(joker_data.value)) + " Mult"
						JokerData.EffectType.ADD_CHIPS_IF:
							chips += int(joker_data.value)
							triggered = true
							trigger_text = "+" + str(int(joker_data.value)) + " Chips"
						JokerData.EffectType.MULTIPLY_MULT_IF:
							mult *= joker_data.value
							triggered = true
							trigger_text = "×" + str(joker_data.value) + " Mult"

		if triggered:
			triggers.append({
				"joker": joker_data,
				"text": trigger_text,
			})

	var final_score = int(chips * mult)

	return {
		"total_chips": chips,
		"total_mult": int(mult),
		"final_score": final_score,
		"joker_triggers": triggers,
	}

## 检查单张牌是否满足小丑牌的条件
static func _check_card_condition(joker_data: JokerData, card: Node2D) -> bool:
	match joker_data.condition:
		JokerData.ConditionType.CARD_SUIT:
			return card.card_data.suit == joker_data.condition_value
		_:
			return false

## 检查牌型是否满足条件
static func _check_hand_condition(joker_data: JokerData, hand_type: PokerHand.HandType) -> bool:
	match joker_data.condition:
		JokerData.ConditionType.HAND_TYPE:
			if joker_data.effect == JokerData.EffectType.MULTIPLY_MULT_IF:
				## 乘法类：牌型 >= 条件即可（如 The Duo: 只要包含 Pair）
				return hand_type >= joker_data.condition_value
			else:
				## 加法类：精确匹配
				return hand_type == joker_data.condition_value
		_:
			return false
