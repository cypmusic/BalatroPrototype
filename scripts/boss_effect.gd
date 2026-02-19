## boss_effect.gd
## Boss 盲注效果处理器 V2 — 修复花色debuff枚举比较Bug
## 静态函数修改计分结果
class_name BossEffectProcessor
extends RefCounted

## 将 Boss 效果应用到计分结果上（直接修改 result 字典）
## result: PokerHand.calculate_score() 的输出
## boss: BlindData.BossBlind（可以为 null）
## hands_played: 本回合已出牌次数（用于 DEBUFF_FIRST_HAND）
static func apply_to_result(result: Dictionary, boss, hands_played: int = 0) -> void:
	if boss == null:
		return

	match boss.effect:
		BlindData.BossEffect.NO_FACE_CARDS:
			var new_chips: int = result["base_chips"] + result.get("level_bonus_chips", 0)
			for card in result["scoring_cards"]:
				if card.card_data.rank < 11:
					new_chips += card.card_data.get_chip_value()
			result["total_chips"] = new_chips
			result["final_score"] = new_chips * result["total_mult"]

		BlindData.BossEffect.NO_HEARTS:
			_debuff_suit(result, CardData.Suit.HEARTS)

		BlindData.BossEffect.NO_DIAMONDS:
			_debuff_suit(result, CardData.Suit.DIAMONDS)

		BlindData.BossEffect.NO_SPADES:
			_debuff_suit(result, CardData.Suit.SPADES)

		BlindData.BossEffect.NO_CLUBS:
			_debuff_suit(result, CardData.Suit.CLUBS)

		BlindData.BossEffect.DEBUFF_FIRST_HAND:
			if hands_played == 0:
				result["total_chips"] = int(result["total_chips"] / 2)
				result["final_score"] = int(result["total_chips"] * result["total_mult"])


## 禁用特定花色的卡牌筹码
## 使用 int() 强制转换确保枚举比较一致
static func _debuff_suit(result: Dictionary, debuff_suit_id: int) -> void:
	var new_chips: int = result["base_chips"] + result.get("level_bonus_chips", 0)
	for card in result["scoring_cards"]:
		## 强制 int 比较，避免枚举类型不匹配
		if int(card.card_data.suit) != int(debuff_suit_id):
			new_chips += card.card_data.get_chip_value()
	result["total_chips"] = new_chips
	result["final_score"] = new_chips * result["total_mult"]
