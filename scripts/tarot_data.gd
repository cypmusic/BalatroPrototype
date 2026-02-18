## tarot_data.gd
## 塔罗牌数据定义
class_name TarotData
extends Resource

enum TarotEffect {
	COPY_CARD,          ## 复制选中牌
	RANDOM_SUIT,        ## 随机变花色
	CHANGE_TO_HEARTS,   ## 变♥（≤3张）
	CHANGE_TO_SPADES,   ## 变♠（≤3张）
	CHANGE_TO_CLUBS,    ## 变♣（≤3张）
	CHANGE_TO_DIAMONDS, ## 变♦（≤3张）
	DESTROY_CARD,       ## 销毁选中牌
	GAIN_MONEY,         ## 获得金钱
	CLONE_CARD,         ## 左牌变成右牌副本
	SPAWN_TAROT,        ## 获得2张随机塔罗牌
	SPAWN_PLANET,       ## 获得2张随机星球牌
	RANDOM_LEVEL_UP,    ## 随机升级一种牌型2级
}

@export var id: String = ""
@export var tarot_name: String = ""
@export var description: String = ""
@export var emoji: String = "🔮"
@export var effect: TarotEffect = TarotEffect.GAIN_MONEY
@export var cost: int = 3

## 是否需要选中手牌才能使用
@export var needs_selection: bool = true
## 最大选中数量（0=不限）
@export var max_select: int = 1
## 最小选中数量
@export var min_select: int = 1

func get_rarity_color() -> Color:
	return Color(0.7, 0.35, 0.75)  ## 塔罗牌 - 紫色

func get_rarity_name() -> String:
	return "Tarot"
