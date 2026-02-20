## seal_effect.gd
## 灵印效果处理器 V0.085 — 四灵封印（青龙/朱雀/白虎/玄武）
## 在计分、弃牌、手牌持有等时机触发灵印效果
class_name SealEffect
extends RefCounted

## ============================================================
## 计分时灵印效果 — 处理参与计分的牌的灵印
## 返回 { bonus_chips, bonus_mult, retrigger_cards, money_earned, triggers }
## ============================================================
static func apply_scoring_seals(scoring_cards: Array) -> Dictionary:
	var bonus_chips: int = 0
	var bonus_mult: float = 0.0
	var retrigger_cards: Array = []
	var money_earned: int = 0
	var triggers: Array = []

	for card in scoring_cards:
		if not card.card_data:
			continue
		match card.card_data.seal:
			CardData.Seal.AZURE_DRAGON:
				## 青龙印：计分时额外触发一次（retrigger）
				retrigger_cards.append(card)
				triggers.append({
					"card": card,
					"seal": "Azure Dragon Seal",
					"text": "Retrigger!",
				})

			CardData.Seal.WHITE_TIGER:
				## 白虎印：计分时+20 Chips
				bonus_chips += 20
				triggers.append({
					"card": card,
					"seal": "White Tiger Seal",
					"text": "+20 Chips",
				})

			## 朱雀印和玄武印不在计分时触发
			_:
				pass

	return {
		"bonus_chips": bonus_chips,
		"bonus_mult": bonus_mult,
		"retrigger_cards": retrigger_cards,
		"money_earned": money_earned,
		"triggers": triggers,
	}

## ============================================================
## 手牌持有时灵印效果 — 处理未打出但留在手中的牌
## 返回 { bonus_chips, bonus_mult, triggers }
## ============================================================
static func apply_held_seals(held_cards: Array) -> Dictionary:
	var bonus_chips: int = 0
	var bonus_mult: float = 0.0
	var triggers: Array = []

	for card in held_cards:
		if not card.card_data:
			continue
		match card.card_data.seal:
			CardData.Seal.BLACK_TORTOISE:
				## 玄武印：留在手中时+5 Mult
				bonus_mult += 5.0
				triggers.append({
					"card": card,
					"seal": "Black Tortoise Seal",
					"text": "+5 Mult (held)",
				})
			_:
				pass

	return {
		"bonus_chips": bonus_chips,
		"bonus_mult": bonus_mult,
		"triggers": triggers,
	}

## ============================================================
## 弃牌时灵印效果 — 处理被弃掉的牌
## 返回 { money_earned, triggers }
## ============================================================
static func apply_discard_seals(discarded_cards: Array) -> Dictionary:
	var money_earned: int = 0
	var triggers: Array = []

	for card in discarded_cards:
		if not card.card_data:
			continue
		match card.card_data.seal:
			CardData.Seal.VERMILLION_BIRD:
				## 朱雀印：弃牌时获得$3
				money_earned += 3
				triggers.append({
					"card": card,
					"seal": "Vermillion Bird Seal",
					"text": "+$3",
				})
			_:
				pass

	return {
		"money_earned": money_earned,
		"triggers": triggers,
	}

## ============================================================
## 获取灵印效果描述（用于UI显示）
## ============================================================
static func get_seal_description(seal: CardData.Seal) -> String:
	match seal:
		CardData.Seal.AZURE_DRAGON:
			return "Scoring: retrigger this card"
		CardData.Seal.VERMILLION_BIRD:
			return "Discard: earn $3"
		CardData.Seal.WHITE_TIGER:
			return "Scoring: +20 Chips"
		CardData.Seal.BLACK_TORTOISE:
			return "Held in hand: +5 Mult"
		_:
			return ""
