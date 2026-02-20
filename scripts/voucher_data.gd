## voucher_data.gd
## 天书数据定义 V0.085 — 16部天书（8基础 + 8进阶）
class_name VoucherData
extends Resource

enum VoucherEffect {
	BONUS_HAND,        ## 每回合额外手数
	BONUS_DISCARD,     ## 每回合额外弃牌
	JOKER_SLOT,        ## 增加异兽栏位
	CONSUMABLE_SLOT,   ## 增加消耗品栏位
	REROLL_DISCOUNT,   ## 刷新费用减免
	REROLL_FREE,       ## 刷新免费
	SHOP_DISCOUNT,     ## 商店折扣
	SHOP_DISCOUNT_25,  ## 商店75折（进阶）
	INTEREST_CAP_UP,   ## 利息上限提升
	INTEREST_CAP_15,   ## 利息上限$15（进阶）
	JOKER_SELL_BONUS,  ## 异兽出售+$N
	MAX_PLAY_CARDS,    ## 出牌上限+1（解锁6张牌型）
}

@export var id: String = ""
@export var voucher_name: String = ""
@export var description: String = ""
@export var emoji: String = "📖"
@export var effect: VoucherEffect = VoucherEffect.BONUS_HAND
@export var value: float = 1.0
@export var cost: int = 10
@export var prerequisite_id: String = ""  ## 进阶天书的前置条件
@export var is_advanced: bool = false

func get_rarity_color() -> Color:
	if is_advanced:
		return Color(0.95, 0.55, 0.15)  ## 进阶天书 - 橙金色
	return Color(0.95, 0.75, 0.2)  ## 基础天书 - 金色
