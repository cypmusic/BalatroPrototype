## voucher_database.gd
## 优惠券数据库 V0.075 — 8张基础优惠券
class_name VoucherDatabase
extends RefCounted

static func get_all_vouchers() -> Array[VoucherData]:
	var vouchers: Array[VoucherData] = []

	## 1. Overstock — +1 小丑栏位
	var v1 = VoucherData.new()
	v1.id = "overstock"
	v1.voucher_name = "Overstock"
	v1.description = "+1 Joker slot"
	v1.emoji = "📦"
	v1.effect = VoucherData.VoucherEffect.JOKER_SLOT
	v1.value = 1.0
	v1.cost = 10
	vouchers.append(v1)

	## 2. Clearance Sale — 商店物品打9折
	var v2 = VoucherData.new()
	v2.id = "clearance_sale"
	v2.voucher_name = "Clearance Sale"
	v2.description = "10% discount on shop items"
	v2.emoji = "🏷️"
	v2.effect = VoucherData.VoucherEffect.SHOP_DISCOUNT
	v2.value = 0.1
	v2.cost = 10
	vouchers.append(v2)

	## 3. Grabber — 每回合 +1 手牌
	var v3 = VoucherData.new()
	v3.id = "grabber"
	v3.voucher_name = "Grabber"
	v3.description = "+1 Hand per round"
	v3.emoji = "🤲"
	v3.effect = VoucherData.VoucherEffect.BONUS_HAND
	v3.value = 1.0
	v3.cost = 10
	vouchers.append(v3)

	## 4. Reroll Surplus — 刷新费用 -$2
	var v4 = VoucherData.new()
	v4.id = "reroll_surplus"
	v4.voucher_name = "Reroll Surplus"
	v4.description = "-$2 Reroll cost"
	v4.emoji = "🔄"
	v4.effect = VoucherData.VoucherEffect.REROLL_DISCOUNT
	v4.value = 2.0
	v4.cost = 10
	vouchers.append(v4)

	## 5. Crystal Ball — +1 消耗品栏位
	var v5 = VoucherData.new()
	v5.id = "crystal_ball"
	v5.voucher_name = "Crystal Ball"
	v5.description = "+1 Consumable slot"
	v5.emoji = "🔮"
	v5.effect = VoucherData.VoucherEffect.CONSUMABLE_SLOT
	v5.value = 1.0
	v5.cost = 10
	vouchers.append(v5)

	## 6. Telescope — 利息上限提升至 $10
	var v6 = VoucherData.new()
	v6.id = "telescope"
	v6.voucher_name = "Telescope"
	v6.description = "Interest cap raised to $10"
	v6.emoji = "🔭"
	v6.effect = VoucherData.VoucherEffect.INTEREST_CAP_UP
	v6.value = 5.0
	v6.cost = 10
	vouchers.append(v6)

	## 7. Hone — 每回合 +1 手牌（可叠加）
	var v7 = VoucherData.new()
	v7.id = "hone"
	v7.voucher_name = "Hone"
	v7.description = "+1 Hand per round (stacks)"
	v7.emoji = "⚔️"
	v7.effect = VoucherData.VoucherEffect.BONUS_HAND
	v7.value = 1.0
	v7.cost = 10
	vouchers.append(v7)

	## 8. Wasteful — 每回合 +1 弃牌
	var v8 = VoucherData.new()
	v8.id = "wasteful"
	v8.voucher_name = "Wasteful"
	v8.description = "+1 Discard per round"
	v8.emoji = "🗑️"
	v8.effect = VoucherData.VoucherEffect.BONUS_DISCARD
	v8.value = 1.0
	v8.cost = 10
	vouchers.append(v8)

	return vouchers

## 根据 ID 查找优惠券
static func get_voucher_by_id(voucher_id: String) -> VoucherData:
	for v in get_all_vouchers():
		if v.id == voucher_id:
			return v
	return null

## 获取一张未拥有的随机优惠券
static func get_random_voucher(owned_ids: Array = []) -> VoucherData:
	var all = get_all_vouchers()
	var available: Array[VoucherData] = []
	for v in all:
		if v.id not in owned_ids:
			available.append(v)
	if available.is_empty():
		return null
	return available[randi() % available.size()]
