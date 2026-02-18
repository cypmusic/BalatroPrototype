## joker_data.gd
## 小丑牌数据定义 V8.3 - 修正稀有度颜色
class_name JokerData
extends Resource

enum TriggerType {
	ON_SCORE,
	ON_CARD_SCORED,
	ON_HAND_PLAYED,
	PASSIVE,
}

enum EffectType {
	ADD_MULT,
	MULTIPLY_MULT,
	ADD_CHIPS,
	ADD_MULT_IF,
	ADD_CHIPS_IF,
	MULTIPLY_MULT_IF,
}

enum ConditionType {
	NONE,
	SUIT_IN_HAND,
	RANK_IN_HAND,
	HAND_TYPE,
	CARD_SUIT,
	HAND_SIZE,
}

@export var id: String = ""
@export var joker_name: String = ""
@export var description: String = ""
@export var rarity: int = 0
@export var cost: int = 4

@export var trigger: TriggerType = TriggerType.ON_SCORE
@export var effect: EffectType = EffectType.ADD_MULT
@export var condition: ConditionType = ConditionType.NONE
@export var value: float = 0.0
@export var condition_value: int = 0

@export var emoji: String = "🃏"

## 稀有度颜色：绿(普通) → 蓝(罕见) → 紫(稀有) → 金(传奇)
func get_rarity_color() -> Color:
	match rarity:
		0: return Color(0.3, 0.7, 0.35)   ## 普通 - 绿
		1: return Color(0.3, 0.5, 0.9)    ## 罕见 - 蓝
		2: return Color(0.75, 0.3, 0.8)   ## 稀有 - 紫
		3: return Color(0.95, 0.75, 0.2)  ## 传奇 - 金
		_: return Color(0.5, 0.5, 0.5)

func get_rarity_name() -> String:
	match rarity:
		0: return "Common"
		1: return "Uncommon"
		2: return "Rare"
		3: return "Legendary"
		_: return "Unknown"

## 卖出价格（购买价格的一半，向上取整）
func get_sell_price() -> int:
	return ceili(float(cost) / 2.0)
