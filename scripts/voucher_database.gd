## voucher_database.gd
## 天书数据库 V0.085 — 16部天书（8基础 + 8进阶）
class_name VoucherDatabase
extends RefCounted

static func get_all_vouchers() -> Array[VoucherData]:
	var vouchers: Array[VoucherData] = []

	## ============================================================
	## 基础天书 (8部) — Base Celestial Tomes
	## ============================================================

	## T-B01 握机经 — 每回合+1出牌
	var v = VoucherData.new()
	v.id = "woji_jing"
	v.voucher_name = "Classic of Seizing Opportunity"
	v.description = "+1 Hand per round"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.BONUS_HAND
	v.value = 1.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B02 弃繁经 — 每回合+1弃牌
	v = VoucherData.new()
	v.id = "qifan_jing"
	v.voucher_name = "Classic of Discarding Excess"
	v.description = "+1 Discard per round"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.BONUS_DISCARD
	v.value = 1.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B03 百兽谱 — +1异兽栏位
	v = VoucherData.new()
	v.id = "baishou_pu"
	v.voucher_name = "Bestiary of a Hundred Beasts"
	v.description = "+1 Beast slot"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.JOKER_SLOT
	v.value = 1.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B04 乾坤袋经 — +1消耗品栏位
	v = VoucherData.new()
	v.id = "qiankun_dai"
	v.voucher_name = "Classic of the Cosmos Pouch"
	v.description = "+1 Consumable slot"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.CONSUMABLE_SLOT
	v.value = 1.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B05 活络经 — 刷新费用-$2
	v = VoucherData.new()
	v.id = "huoluo_jing"
	v.voucher_name = "Classic of Free Flow"
	v.description = "-$2 Reroll cost"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.REROLL_DISCOUNT
	v.value = 2.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B06 市易经 — 商店物品9折
	v = VoucherData.new()
	v.id = "shiyi_jing"
	v.voucher_name = "Classic of Fair Trade"
	v.description = "10% shop discount"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.SHOP_DISCOUNT
	v.value = 0.1
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B07 聚宝经 — 利息上限提升至$10
	v = VoucherData.new()
	v.id = "jubao_jing"
	v.voucher_name = "Classic of Gathering Treasures"
	v.description = "Interest cap raised to $10"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.INTEREST_CAP_UP
	v.value = 5.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## T-B08 养兽经 — 异兽出售价格+$1
	v = VoucherData.new()
	v.id = "yangshou_jing"
	v.voucher_name = "Classic of Beast-Rearing"
	v.description = "+$1 Beast sell value"
	v.emoji = "📖"
	v.effect = VoucherData.VoucherEffect.JOKER_SELL_BONUS
	v.value = 1.0
	v.cost = 10
	v.is_advanced = false
	vouchers.append(v)

	## ============================================================
	## 进阶天书 (8部) — Advanced Celestial Tomes
	## ============================================================

	## T-A01 洞真经 — 每回合再+1出牌 (前置: 握机经)
	v = VoucherData.new()
	v.id = "dongzhen_jing"
	v.voucher_name = "Classic of Profound Truth"
	v.description = "+1 Hand per round (stacks)"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.BONUS_HAND
	v.value = 1.0
	v.cost = 10
	v.prerequisite_id = "woji_jing"
	v.is_advanced = true
	vouchers.append(v)

	## T-A02 洗心经 — 每回合再+1弃牌 (前置: 弃繁经)
	v = VoucherData.new()
	v.id = "xixin_jing"
	v.voucher_name = "Classic of Heart-Cleansing"
	v.description = "+1 Discard per round (stacks)"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.BONUS_DISCARD
	v.value = 1.0
	v.cost = 10
	v.prerequisite_id = "qifan_jing"
	v.is_advanced = true
	vouchers.append(v)

	## T-A03 万兽录 — 再+1异兽栏位 (前置: 百兽谱)
	v = VoucherData.new()
	v.id = "wanshou_lu"
	v.voucher_name = "Record of Ten Thousand Beasts"
	v.description = "+1 Beast slot (stacks)"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.JOKER_SLOT
	v.value = 1.0
	v.cost = 10
	v.prerequisite_id = "baishou_pu"
	v.is_advanced = true
	vouchers.append(v)

	## T-A04 须弥经 — 刷新免费 (前置: 活络经)
	v = VoucherData.new()
	v.id = "xumi_jing"
	v.voucher_name = "Classic of Sumeru"
	v.description = "Rerolls are free"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.REROLL_FREE
	v.value = 1.0
	v.cost = 10
	v.prerequisite_id = "huoluo_jing"
	v.is_advanced = true
	vouchers.append(v)

	## T-A05 通商经 — 商店物品75折 (前置: 市易经)
	v = VoucherData.new()
	v.id = "tongshang_jing"
	v.voucher_name = "Classic of Open Commerce"
	v.description = "25% shop discount"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.SHOP_DISCOUNT_25
	v.value = 0.25
	v.cost = 10
	v.prerequisite_id = "shiyi_jing"
	v.is_advanced = true
	vouchers.append(v)

	## T-A06 炼金经 — 利息上限提升至$15 (前置: 聚宝经)
	v = VoucherData.new()
	v.id = "lianjin_jing"
	v.voucher_name = "Classic of Alchemy"
	v.description = "Interest cap raised to $15"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.INTEREST_CAP_15
	v.value = 10.0
	v.cost = 10
	v.prerequisite_id = "jubao_jing"
	v.is_advanced = true
	vouchers.append(v)

	## T-A07 驯兽经 — 异兽出售价格再+$2 (前置: 养兽经)
	v = VoucherData.new()
	v.id = "xunshou_jing"
	v.voucher_name = "Classic of Beast-Taming"
	v.description = "+$2 Beast sell value"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.JOKER_SELL_BONUS
	v.value = 2.0
	v.cost = 10
	v.prerequisite_id = "yangshou_jing"
	v.is_advanced = true
	vouchers.append(v)

	## T-A08 阴符经 — 出牌上限+1(解锁6张牌型) (前置: 乾坤袋经)
	v = VoucherData.new()
	v.id = "yinfu_jing"
	v.voucher_name = "Classic of the Hidden Talisman"
	v.description = "+1 card play limit (unlock 6-card hands)"
	v.emoji = "📜"
	v.effect = VoucherData.VoucherEffect.MAX_PLAY_CARDS
	v.value = 1.0
	v.cost = 10
	v.prerequisite_id = "qiankun_dai"
	v.is_advanced = true
	vouchers.append(v)

	return vouchers

## 根据 ID 查找天书
static func get_voucher_by_id(voucher_id: String) -> VoucherData:
	for v in get_all_vouchers():
		if v.id == voucher_id:
			return v
	return null

## 获取可购买的天书（未拥有 + 前置已满足）
static func get_available_voucher(owned_ids: Array = []) -> VoucherData:
	var all = get_all_vouchers()
	var available: Array[VoucherData] = []
	for v in all:
		if v.id in owned_ids:
			continue
		if v.is_advanced and v.prerequisite_id != "" and v.prerequisite_id not in owned_ids:
			continue
		available.append(v)
	if available.is_empty():
		return null
	return available[randi() % available.size()]

## 获取所有基础天书
static func get_base_vouchers() -> Array[VoucherData]:
	var result: Array[VoucherData] = []
	for v in get_all_vouchers():
		if not v.is_advanced:
			result.append(v)
	return result

## 获取所有进阶天书
static func get_advanced_vouchers() -> Array[VoucherData]:
	var result: Array[VoucherData] = []
	for v in get_all_vouchers():
		if v.is_advanced:
			result.append(v)
	return result
