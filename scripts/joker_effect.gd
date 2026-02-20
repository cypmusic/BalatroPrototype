## joker_effect.gd
## 异兽效果处理器 V0.085 — 支持72张异兽的全部触发/效果/条件
## TriggerType: 13种 / EffectType: 20种 / ConditionType: 17种
class_name JokerEffect
extends RefCounted

## ============================================================
## 主计分处理 — 处理所有异兽对计分的影响
## ============================================================
## active_jokers: 当前持有的异兽数据数组
## base_result: PokerHand.calculate_score() 的结果
## scoring_cards: 参与计分的牌
## context: 额外上下文 { held_cards, discards_remaining, hands_remaining, ... }
## 返回 { total_chips, total_mult, final_score, joker_triggers, retrigger_cards }
static func apply_jokers(active_jokers: Array, base_result: Dictionary,
		scoring_cards: Array, context: Dictionary = {}) -> Dictionary:
	var chips: int = base_result["total_chips"]
	var mult: float = float(base_result["total_mult"])
	var hand_type = base_result["hand_type"]
	var triggers: Array = []
	var retrigger_cards: Array = []

	for joker_data in active_jokers:
		var result = _process_single_joker(joker_data, chips, mult, hand_type,
			scoring_cards, context)
		chips = result["chips"]
		mult = result["mult"]
		if result["triggered"]:
			triggers.append({
				"joker": joker_data,
				"text": result["text"],
			})
		retrigger_cards.append_array(result.get("retrigger_cards", []))

	var final_mult = int(mult) if mult >= 1.0 else 1
	var final_score = int(chips * mult)

	return {
		"total_chips": chips,
		"total_mult": final_mult,
		"final_score": final_score,
		"joker_triggers": triggers,
		"retrigger_cards": retrigger_cards,
	}

## ============================================================
## 单个异兽效果处理
## ============================================================
static func _process_single_joker(joker_data: JokerData, chips: int, mult: float,
		hand_type, scoring_cards: Array, ctx: Dictionary) -> Dictionary:
	var triggered = false
	var trigger_text = ""
	var retrigger_cards: Array = []

	match joker_data.trigger:
		## === ON_SCORE: 无条件，每次计分触发 ===
		JokerData.TriggerType.ON_SCORE:
			var r = _apply_effect_unconditional(joker_data, chips, mult)
			chips = r["chips"]; mult = r["mult"]
			triggered = r["triggered"]; trigger_text = r["text"]
			retrigger_cards = r.get("retrigger_cards", [])

		## === ON_CARD_SCORED: 每张计分牌检查 ===
		JokerData.TriggerType.ON_CARD_SCORED:
			var r = _apply_per_card(joker_data, chips, mult, scoring_cards)
			chips = r["chips"]; mult = r["mult"]
			triggered = r["triggered"]; trigger_text = r["text"]
			retrigger_cards = r.get("retrigger_cards", [])

		## === ON_HAND_PLAYED: 根据牌型/条件触发 ===
		JokerData.TriggerType.ON_HAND_PLAYED:
			var r = _apply_hand_played(joker_data, chips, mult, hand_type)
			chips = r["chips"]; mult = r["mult"]
			triggered = r["triggered"]; trigger_text = r["text"]

		## === ON_SCORE_CONTEXT: 需要游戏上下文 ===
		JokerData.TriggerType.ON_SCORE_CONTEXT:
			var r = _apply_context_effect(joker_data, chips, mult, ctx)
			chips = r["chips"]; mult = r["mult"]
			triggered = r["triggered"]; trigger_text = r["text"]

		## === PASSIVE: 被动效果（由其他系统读取） ===
		JokerData.TriggerType.PASSIVE:
			pass  ## 被动效果在其他系统中检查

		## === 以下触发类型不在计分时处理 ===
		JokerData.TriggerType.ON_ROUND_END, \
		JokerData.TriggerType.ON_DISCARD, \
		JokerData.TriggerType.ON_SELL, \
		JokerData.TriggerType.ON_BUY, \
		JokerData.TriggerType.ON_REEL_DRAW, \
		JokerData.TriggerType.ON_BEAT_HIT, \
		JokerData.TriggerType.ON_BLIND_START, \
		JokerData.TriggerType.ON_CARD_HELD:
			pass  ## 这些在各自的系统中处理

	return {
		"chips": chips, "mult": mult,
		"triggered": triggered, "text": trigger_text,
		"retrigger_cards": retrigger_cards,
	}

## ============================================================
## 无条件效果（ON_SCORE触发）
## ============================================================
static func _apply_effect_unconditional(joker_data: JokerData, chips: int, mult: float) -> Dictionary:
	var triggered = false
	var text = ""
	var retrigger_cards: Array = []

	match joker_data.effect:
		JokerData.EffectType.ADD_MULT:
			mult += joker_data.value
			triggered = true
			text = "+" + str(int(joker_data.value)) + " Mult"

		JokerData.EffectType.ADD_CHIPS:
			chips += int(joker_data.value)
			triggered = true
			text = "+" + str(int(joker_data.value)) + " Chips"

		JokerData.EffectType.MULTIPLY_MULT:
			mult *= joker_data.value
			triggered = true
			text = "x" + str(joker_data.value) + " Mult"

		JokerData.EffectType.RETRIGGER:
			## 所有计分牌重触发（玄龟等）
			triggered = true
			text = "All cards retrigger!"
			## retrigger由调用者处理

		JokerData.EffectType.COPY_EFFECT:
			## 复制效果（腾蛇/陆吾等）— 需要外部系统支持
			triggered = false

		JokerData.EffectType.SCALING_MULT:
			## 缩放倍率(已累积的值)
			if joker_data.scaling_current > 0:
				mult += joker_data.scaling_current
				triggered = true
				text = "+" + str(int(joker_data.scaling_current)) + " Mult (scaled)"

		JokerData.EffectType.SCALING_CHIPS:
			## 缩放筹码(已累积的值)
			if joker_data.scaling_current > 0:
				chips += int(joker_data.scaling_current)
				triggered = true
				text = "+" + str(int(joker_data.scaling_current)) + " Chips (scaled)"

	return {"chips": chips, "mult": mult, "triggered": triggered, "text": text,
		"retrigger_cards": retrigger_cards}

## ============================================================
## 每张计分牌检查（ON_CARD_SCORED触发）
## ============================================================
static func _apply_per_card(joker_data: JokerData, chips: int, mult: float,
		scoring_cards: Array) -> Dictionary:
	var triggered = false
	var text = ""
	var card_count = 0
	var retrigger_cards: Array = []

	for card in scoring_cards:
		if _check_card_condition(joker_data, card):
			card_count += 1

	if card_count > 0:
		match joker_data.effect:
			JokerData.EffectType.ADD_MULT_IF:
				var bonus = joker_data.value * card_count
				mult += bonus
				triggered = true
				text = "+" + str(int(bonus)) + " Mult (" + str(card_count) + "x)"

			JokerData.EffectType.ADD_CHIPS_IF:
				var bonus = int(joker_data.value) * card_count
				chips += bonus
				triggered = true
				text = "+" + str(bonus) + " Chips (" + str(card_count) + "x)"

			JokerData.EffectType.MULTIPLY_MULT_IF:
				for i in range(card_count):
					mult *= joker_data.value
				triggered = true
				text = "x" + str(joker_data.value) + " Mult (" + str(card_count) + "x)"

			JokerData.EffectType.RETRIGGER:
				for card in scoring_cards:
					if _check_card_condition(joker_data, card):
						retrigger_cards.append(card)
				triggered = true
				text = str(card_count) + " card(s) retrigger"

			JokerData.EffectType.EARN_MONEY:
				## 每张计分牌+$N (如獬豸)
				triggered = true
				text = "+$" + str(int(joker_data.value * card_count))

	return {"chips": chips, "mult": mult, "triggered": triggered, "text": text,
		"retrigger_cards": retrigger_cards}

## ============================================================
## 牌型条件检查（ON_HAND_PLAYED触发）
## ============================================================
static func _apply_hand_played(joker_data: JokerData, chips: int, mult: float,
		hand_type) -> Dictionary:
	var triggered = false
	var text = ""

	if _check_hand_condition(joker_data, hand_type):
		match joker_data.effect:
			JokerData.EffectType.ADD_MULT_IF:
				mult += joker_data.value
				triggered = true
				text = "+" + str(int(joker_data.value)) + " Mult"

			JokerData.EffectType.ADD_CHIPS_IF:
				chips += int(joker_data.value)
				triggered = true
				text = "+" + str(int(joker_data.value)) + " Chips"

			JokerData.EffectType.MULTIPLY_MULT_IF:
				mult *= joker_data.value
				triggered = true
				text = "x" + str(joker_data.value) + " Mult"

			JokerData.EffectType.SCALING_MULT:
				## 条件型缩放（如肥遗：每打出同花永久+2 Mult）
				joker_data.scaling_current += joker_data.value
				mult += joker_data.value
				triggered = true
				text = "+" + str(int(joker_data.value)) + " Mult (permanent)"

	return {"chips": chips, "mult": mult, "triggered": triggered, "text": text}

## ============================================================
## 上下文效果（ON_SCORE_CONTEXT触发）
## ============================================================
static func _apply_context_effect(joker_data: JokerData, chips: int, mult: float,
		ctx: Dictionary) -> Dictionary:
	var triggered = false
	var text = ""

	match joker_data.condition:
		JokerData.ConditionType.DISCARDS_REMAINING:
			var discards = ctx.get("discards_remaining", GameState.discards_remaining)
			match joker_data.effect:
				JokerData.EffectType.ADD_MULT_PER:
					var bonus = joker_data.value * discards
					if bonus > 0:
						mult += bonus
						triggered = true
						text = "+" + str(int(bonus)) + " Mult (" + str(discards) + " discards)"
				JokerData.EffectType.ADD_MULT_IF:
					if discards == joker_data.condition_value:
						mult += joker_data.value
						triggered = true
						text = "+" + str(int(joker_data.value)) + " Mult (0 discards!)"
				JokerData.EffectType.ADD_CHIPS_PER:
					var bonus = int(joker_data.value) * discards
					if bonus > 0:
						chips += bonus
						triggered = true
						text = "+" + str(bonus) + " Chips (" + str(discards) + " discards)"

		JokerData.ConditionType.MONEY_THRESHOLD:
			var money = ctx.get("money", GameState.money)
			if money >= joker_data.condition_value:
				match joker_data.effect:
					JokerData.EffectType.MULTIPLY_MULT_IF:
						mult *= joker_data.value
						triggered = true
						text = "x" + str(joker_data.value) + " Mult ($" + str(money) + ")"

		JokerData.ConditionType.CARDS_PLAYED_COUNT:
			var plays_this_round = ctx.get("plays_this_round", 0)
			if plays_this_round == joker_data.condition_value:
				match joker_data.effect:
					JokerData.EffectType.MULTIPLY_MULT_IF:
						mult *= joker_data.value
						triggered = true
						text = "x" + str(joker_data.value) + " Mult (first hand!)"

		JokerData.ConditionType.NONE:
			## 无条件上下文效果（如重明鸟: 每剩余1次出牌+30 Chips）
			match joker_data.effect:
				JokerData.EffectType.ADD_CHIPS_PER:
					var hands = ctx.get("hands_remaining", GameState.hands_remaining)
					var bonus = int(joker_data.value) * hands
					if bonus > 0:
						chips += bonus
						triggered = true
						text = "+" + str(bonus) + " Chips (" + str(hands) + " plays)"
				JokerData.EffectType.ADD_MULT_PER:
					var hands = ctx.get("hands_remaining", GameState.hands_remaining)
					var bonus = joker_data.value * hands
					if bonus > 0:
						mult += bonus
						triggered = true
						text = "+" + str(int(bonus)) + " Mult (" + str(hands) + " plays)"

	return {"chips": chips, "mult": mult, "triggered": triggered, "text": text}

## ============================================================
## 回合结束效果 — 处理ON_ROUND_END触发
## 返回 { money_earned, triggers }
## ============================================================
static func apply_round_end(active_jokers: Array) -> Dictionary:
	var money_earned: int = 0
	var triggers: Array = []

	for joker_data in active_jokers:
		if joker_data.trigger != JokerData.TriggerType.ON_ROUND_END:
			continue

		match joker_data.effect:
			JokerData.EffectType.EARN_MONEY:
				money_earned += int(joker_data.value)
				triggers.append({
					"joker": joker_data,
					"text": "+$" + str(int(joker_data.value)),
				})

			JokerData.EffectType.SCALING_MULT:
				joker_data.scaling_current += joker_data.value
				triggers.append({
					"joker": joker_data,
					"text": "+" + str(int(joker_data.value)) + " Mult (permanent)",
				})

	return {"money_earned": money_earned, "triggers": triggers}

## ============================================================
## 弃牌效果 — 处理ON_DISCARD触发
## 返回 { triggers }
## ============================================================
static func apply_discard(active_jokers: Array) -> Dictionary:
	var triggers: Array = []

	for joker_data in active_jokers:
		if joker_data.trigger != JokerData.TriggerType.ON_DISCARD:
			continue

		match joker_data.effect:
			JokerData.EffectType.SCALING_CHIPS:
				joker_data.scaling_current += joker_data.value
				triggers.append({
					"joker": joker_data,
					"text": "+" + str(int(joker_data.value)) + " Chips (permanent)",
				})

	return {"triggers": triggers}

## ============================================================
## 卖出效果 — 处理ON_SELL触发
## 返回 { money_earned, triggers, special_effects }
## ============================================================
static func apply_sell(joker_data: JokerData) -> Dictionary:
	var money_earned: int = 0
	var triggers: Array = []
	var special_effects: Array = []

	if joker_data.trigger != JokerData.TriggerType.ON_SELL:
		return {"money_earned": 0, "triggers": [], "special_effects": []}

	match joker_data.effect:
		JokerData.EffectType.EARN_MONEY:
			money_earned += int(joker_data.value)
			triggers.append({
				"joker": joker_data,
				"text": "+$" + str(int(joker_data.value)) + " bonus",
			})

		JokerData.EffectType.SELF_DESTROY_GAIN:
			special_effects.append({"type": "sell_boost", "value": joker_data.value})
			triggers.append({
				"joker": joker_data,
				"text": "Next hand x" + str(joker_data.value) + " Mult",
			})

		JokerData.EffectType.SCALING_MULT:
			## 饕餮: 永久+卖价 Mult (由调用者计算卖价)
			special_effects.append({"type": "scale_by_sell_price"})
			triggers.append({
				"joker": joker_data,
				"text": "Absorbed sell value as Mult",
			})

	return {"money_earned": money_earned, "triggers": triggers,
		"special_effects": special_effects}

## ============================================================
## 获取被动效果数据（供其他系统查询）
## ============================================================
static func get_passive_value(active_jokers: Array, passive_type: String) -> float:
	var total: float = 0.0
	for joker_data in active_jokers:
		if joker_data.trigger != JokerData.TriggerType.PASSIVE:
			continue
		match passive_type:
			"boss_timer_bars":
				## 凤凰雏/化蛇等增加Boss时限
				if joker_data.effect == JokerData.EffectType.ADD_CHIPS:
					total += joker_data.value
			"interest_cap":
				## 貔貅: 利息上限
				if joker_data.effect == JokerData.EffectType.EARN_MONEY:
					total = maxf(total, joker_data.value)
			"bpm_reduction":
				## 相柳: 降BPM
				if joker_data.effect == JokerData.EffectType.REDUCE_REQUIREMENT:
					total += joker_data.value
			"reel_extra_draws":
				## 白泽: 天机抽牌次数
				if joker_data.effect == JokerData.EffectType.ADD_JOKER_SLOT:
					total += joker_data.value
	return total

## ============================================================
## 卡牌条件检查
## ============================================================
static func _check_card_condition(joker_data: JokerData, card) -> bool:
	match joker_data.condition:
		JokerData.ConditionType.CARD_SUIT:
			return card.card_data.suit == joker_data.condition_value

		JokerData.ConditionType.CARD_IS_FACE:
			return card.card_data.rank >= 11 and card.card_data.rank <= 13

		JokerData.ConditionType.CARD_RANK_EVEN:
			return card.card_data.rank >= 2 and card.card_data.rank <= 10 and card.card_data.rank % 2 == 0

		JokerData.ConditionType.CARD_RANK_ODD:
			var r = card.card_data.rank
			if r == 14: r = 1
			return r % 2 == 1

		JokerData.ConditionType.CARD_RANK_LIST:
			return card.card_data.rank in joker_data.condition_values

		JokerData.ConditionType.CARD_HAS_SEAL:
			return card.card_data.seal != CardData.Seal.NONE

		JokerData.ConditionType.CARD_HAS_ENHANCE:
			return card.card_data.enhancement != CardData.Enhancement.NONE

		JokerData.ConditionType.NONE:
			return true

		_:
			return false

## ============================================================
## 牌型条件检查
## ============================================================
static func _check_hand_condition(joker_data: JokerData, hand_type) -> bool:
	match joker_data.condition:
		JokerData.ConditionType.HAND_TYPE:
			if joker_data.effect == JokerData.EffectType.MULTIPLY_MULT_IF:
				## 乘法类：牌型强度 >= 条件值(用power比较)
				return PokerHand.get_hand_power(hand_type) >= \
					PokerHand.get_hand_power(joker_data.condition_value)
			else:
				## 加法类：精确匹配
				return hand_type == joker_data.condition_value

		JokerData.ConditionType.HAND_CONTAINS_PAIR:
			## 牌型含对子（对子/两对/葫芦/etc）
			return hand_type == PokerHand.HandType.PAIR or \
				hand_type == PokerHand.HandType.TWO_PAIR or \
				hand_type == PokerHand.HandType.FULL_HOUSE or \
				hand_type == PokerHand.HandType.TRIPLE_PAIR or \
				hand_type == PokerHand.HandType.FULL_HOUSE_PLUS or \
				hand_type == PokerHand.HandType.FOUR_TWO or \
				hand_type == PokerHand.HandType.PAIR_FOUR or \
				hand_type == PokerHand.HandType.FLUSH_HOUSE or \
				hand_type == PokerHand.HandType.FULL_FLUSH

		JokerData.ConditionType.HAND_CONTAINS_THREE:
			## 牌型含三条
			return hand_type == PokerHand.HandType.THREE_OF_A_KIND or \
				hand_type == PokerHand.HandType.FULL_HOUSE or \
				hand_type == PokerHand.HandType.DOUBLE_THREE or \
				hand_type == PokerHand.HandType.FULL_HOUSE_PLUS or \
				hand_type == PokerHand.HandType.TWO_THREE or \
				hand_type == PokerHand.HandType.FLUSH_HOUSE or \
				hand_type == PokerHand.HandType.FULL_FLUSH

		JokerData.ConditionType.NONE:
			return true

		_:
			return false
