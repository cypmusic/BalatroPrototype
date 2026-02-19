## voucher_data.gd
## 优惠券数据定义 V0.075
class_name VoucherData
extends Resource

enum VoucherEffect {
	BONUS_HAND,        ## 每回合额外手数
	BONUS_DISCARD,     ## 每回合额外弃牌
	JOKER_SLOT,        ## 增加小丑栏位
	CONSUMABLE_SLOT,   ## 增加消耗品栏位
	REROLL_DISCOUNT,   ## 刷新费用减免
	SHOP_DISCOUNT,     ## 商店折扣
	INTEREST_CAP_UP,   ## 利息上限提升
}

@export var id: String = ""
@export var voucher_name: String = ""
@export var description: String = ""
@export var emoji: String = "🎟️"
@export var effect: VoucherEffect = VoucherEffect.BONUS_HAND
@export var value: float = 1.0
@export var cost: int = 10

func get_rarity_color() -> Color:
	return Color(0.95, 0.75, 0.2)  ## 优惠券 - 金色
