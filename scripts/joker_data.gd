## joker_data.gd
## 小丑牌数据定义 V9 - 新增条件类型支持 16 张小丑牌
class_name JokerData
extends Resource

enum TriggerType {
	ON_SCORE,           ## 无条件，每次计分触发
	ON_CARD_SCORED,     ## 每张计分牌检查
	ON_HAND_PLAYED,     ## 根据牌型触发
	PASSIVE,            ## 被动效果
	ON_SCORE_CONTEXT,   ## 需要游戏上下文（如剩余弃牌数）
}

enum EffectType {
	ADD_MULT,
	MULTIPLY_MULT,
	ADD_CHIPS,
	ADD_MULT_IF,
	ADD_CHIPS_IF,
	MULTIPLY_MULT_IF,
	ADD_CHIPS_PER,      ## 每满足条件1次 +N chips（如每剩余1次弃牌 +30）
	ADD_MULT_PER,       ## 每满足条件1次 +N mult
}

enum ConditionType {
	NONE,
	SUIT_IN_HAND,
	RANK_IN_HAND,
	HAND_TYPE,
	CARD_SUIT,
	HAND_SIZE,
	CARD_RANK_LIST,     ## 卡牌点数在指定列表中（用 condition_values 数组）
	CARD_IS_FACE,       ## 卡牌是人头牌 (J=11, Q=12, K=13)
	CARD_RANK_EVEN,     ## 卡牌点数为偶数 (2,4,6,8,10)
	CARD_RANK_ODD,      ## 卡牌点数为奇数 (A,3,5,7,9)
	DISCARDS_REMAINING, ## 剩余弃牌次数相关
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

## 扩展条件值（用于 CARD_RANK_LIST 等需要多值的条件）
var condition_values: Array = []

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
