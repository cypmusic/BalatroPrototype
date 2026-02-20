## joker_data.gd
## 异兽牌数据定义 V10 — 支持72张异兽牌的12种效果分类
class_name JokerData
extends Resource

enum TriggerType {
	ON_SCORE,           ## 无条件，每次计分触发
	ON_CARD_SCORED,     ## 每张计分牌检查
	ON_HAND_PLAYED,     ## 根据牌型触发
	PASSIVE,            ## 被动效果（静态加成）
	ON_SCORE_CONTEXT,   ## 需要游戏上下文（如剩余弃牌数）
	ON_ROUND_END,       ## 回合结束时触发
	ON_DISCARD,         ## 弃牌时触发
	ON_SELL,            ## 出售时触发
	ON_BUY,             ## 购买时触发
	ON_REEL_DRAW,       ## 转盘抽卡时触发（BeatClock 系统）
	ON_BEAT_HIT,        ## 节拍命中时触发（BeatClock 系统）
	ON_BLIND_START,     ## 盲注开始时触发
	ON_CARD_HELD,       ## 手中持有的牌（不计分的牌）
}

enum EffectType {
	ADD_MULT,           ## +N 倍率
	MULTIPLY_MULT,      ## ×N 倍率
	ADD_CHIPS,          ## +N 筹码
	ADD_MULT_IF,        ## 满足条件时 +N 倍率
	ADD_CHIPS_IF,       ## 满足条件时 +N 筹码
	MULTIPLY_MULT_IF,   ## 满足条件时 ×N 倍率
	ADD_CHIPS_PER,      ## 每满足条件1次 +N chips
	ADD_MULT_PER,       ## 每满足条件1次 +N mult
	EARN_MONEY,         ## 获得 $N
	RETRIGGER,          ## 使计分牌重新触发 N 次
	COPY_EFFECT,        ## 复制左/右邻异兽效果
	SELF_DESTROY_GAIN,  ## 自毁并获得增益
	SCALING_MULT,       ## 递增倍率（每次触发 +N）
	SCALING_CHIPS,      ## 递增筹码（每次触发 +N）
	MULT_PER_MONEY,     ## 每 $N 金钱 +1 倍率
	CHIPS_PER_HAND,     ## 每 N 张手牌 +N 筹码
	RANDOM_MULT,        ## 随机倍率 (N~M 范围)
	MULT_PER_CARD,      ## 每张计分牌 +N 倍率（无条件）
	ADD_JOKER_SLOT,     ## +N 异兽栏位
	REDUCE_REQUIREMENT, ## 降低目标分数 N%
}

enum ConditionType {
	NONE,
	SUIT_IN_HAND,       ## 手中有特定花色
	RANK_IN_HAND,       ## 手中有特定点数
	HAND_TYPE,          ## 打出特定牌型
	CARD_SUIT,          ## 计分牌为特定花色
	HAND_SIZE,          ## 手牌数量相关
	CARD_RANK_LIST,     ## 卡牌点数在指定列表中
	CARD_IS_FACE,       ## 卡牌是人头牌 (J/Q/K)
	CARD_RANK_EVEN,     ## 卡牌点数为偶数
	CARD_RANK_ODD,      ## 卡牌点数为奇数
	DISCARDS_REMAINING, ## 剩余弃牌次数相关
	MONEY_THRESHOLD,    ## 金钱超过 N
	CARD_HAS_SEAL,      ## 计分牌有灵印
	CARD_HAS_ENHANCE,   ## 计分牌有增强
	HAND_CONTAINS_PAIR, ## 牌型包含对子
	HAND_CONTAINS_THREE,## 牌型包含三条
	CARDS_PLAYED_COUNT, ## 本回合已出牌 N 次
	JOKER_COUNT,        ## 持有异兽数量
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
@export var value2: float = 0.0  ## 辅助值（如范围上限、第二效果值）
@export var condition_value: int = 0

## 扩展条件值（用于 CARD_RANK_LIST 等需要多值的条件）
var condition_values: Array = []

## 递增状态（用于 SCALING_MULT / SCALING_CHIPS）
var scaling_current: float = 0.0

@export var emoji: String = "🐲"

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
