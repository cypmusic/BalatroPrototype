## joker_effect.gd
## 小丑牌效果处理器 V2 - 支持 16 张小丑牌的全部条件类型
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
	var triggers: Array = []

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

			## ON_SCORE_CONTEXT: 需要 GameState 上下文
			JokerData.TriggerType.ON_SCORE_CONTEXT:
				var ctx_result = _apply_context_effect(joker_data)
				if ctx_result["triggered"]:
					chips += ctx_result.get("bonus_chips", 0)
					mult += ctx_result.get("bonus_mult", 0.0)
					triggered = true
					trigger_text = ctx_result["text"]

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

		JokerData.ConditionType.CARD_IS_FACE:
			## J=11, Q=12, K=13
			return card.card_data.rank >= 11 and card.card_data.rank <= 13

		JokerData.ConditionType.CARD_RANK_EVEN:
			## 2,4,6,8,10（rank 值: 2-10）
			return card.card_data.rank >= 2 and card.card_data.rank <= 10 and card.card_data.rank % 2 == 0

		JokerData.ConditionType.CARD_RANK_ODD:
			## A(14→1),3,5,7,9
			var r = card.card_data.rank
			if r == 14: r = 1  ## Ace
			return r % 2 == 1

		JokerData.ConditionType.CARD_RANK_LIST:
			## 检查 rank 是否在 condition_values 列表中
			return card.card_data.rank in joker_data.condition_values

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

## 处理需要游戏上下文的效果（从 GameState 读取数据）
static func _apply_context_effect(joker_data: JokerData) -> Dictionary:
	match joker_data.condition:
		JokerData.ConditionType.DISCARDS_REMAINING:
			var discards = GameState.discards_remaining
			if joker_data.effect == JokerData.EffectType.ADD_CHIPS_PER:
				## 每剩余1次弃牌 +N chips
				var bonus = int(joker_data.value) * discards
				if bonus > 0:
					return {"triggered": true, "bonus_chips": bonus, "text": "+" + str(bonus) + " Chips (" + str(discards) + " discards)"}
			elif joker_data.effect == JokerData.EffectType.ADD_MULT_IF:
				## 剩余弃牌 == condition_value 时触发
				if discards == joker_data.condition_value:
					return {"triggered": true, "bonus_mult": joker_data.value, "text": "+" + str(int(joker_data.value)) + " Mult (0 discards!)"}
		_:
			pass
	return {"triggered": false}
