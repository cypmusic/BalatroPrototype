## blind_data.gd
## 盲注系统 V0.085 — 64卦难度路由
## 8个回合(Ante) × 3盲注(小/大/Boss) = 24关
## 每个Boss盲注由64卦中的特定卦象定义，具有独特效果
class_name BlindData
extends RefCounted

enum BlindType {
	SMALL_BLIND,
	BIG_BLIND,
	BOSS_BLIND,
}

## Boss效果类型 — 扩展至支持64卦
enum BossEffect {
	NONE,
	## --- 基础限制型 ---
	NO_FACE_CARDS,       ## 人头牌不计分
	NO_HEARTS,           ## ♥不计分
	NO_DIAMONDS,         ## ♦不计分
	NO_SPADES,           ## ♠不计分
	NO_CLUBS,            ## ♣不计分
	DEBUFF_FIRST_HAND,   ## 首手得分减半
	FEWER_HANDS,         ## 仅3次出牌
	NO_DISCARDS,         ## 无法弃牌
	## --- 高阶限制型 ---
	FACE_CARDS_DEBUFF,   ## 人头牌-20 Chips
	LOW_CARDS_DEBUFF,    ## 2-5牌不计分
	NO_PAIRS,            ## 禁用对子系牌型
	NO_STRAIGHTS,        ## 禁用顺子系牌型
	NO_FLUSH,            ## 禁用同花系牌型
	BLIND_HAND,          ## 牌面朝下(随机3张)
	HALVE_MULT,          ## 总倍率减半
	DOUBLE_TARGET,       ## 目标分数×2
	SCORE_DECAY,         ## 每手得分递减10%
	SEAL_DISABLED,       ## 灵印效果失效
	BEAST_DISABLED,      ## 首个异兽效果失效
	ENHANCEMENT_STRIPPED, ## 增强效果失效
	MONEY_DRAIN,         ## 每手-$1
	HAND_SIZE_MINUS,     ## 手牌-2
}

## ============================================================
## Boss盲注数据类
## ============================================================
class BossBlind:
	var name: String
	var effect: BossEffect
	var description: String
	var emoji: String
	var hexagram_num: int   ## 卦序(1-64)
	var hexagram_name: String ## 卦名

	func _init(n: String, e: BossEffect, d: String, em: String,
			hex_num: int = 0, hex_name: String = ""):
		name = n
		effect = e
		description = d
		emoji = em
		hexagram_num = hex_num
		hexagram_name = hex_name

## ============================================================
## Boss盲注库 — 按回合(Ante)分组，每Ante有可选Boss池
## ============================================================
static func get_bosses_for_ante(ante: int) -> Array:
	match ante:
		## Ante 1: 入门Boss (温和限制)
		1:
			return [
				BossBlind.new("Earth/Ground", BossEffect.FEWER_HANDS,
					"Only 3 hands this round", "☷", 2, "坤"),
				BossBlind.new("Mountain/Still", BossEffect.NO_DISCARDS,
					"No discards this round", "⛰️", 52, "艮"),
				BossBlind.new("Wind/Gentle", BossEffect.DEBUFF_FIRST_HAND,
					"First hand played scores half", "🌬️", 57, "巽"),
			]
		## Ante 2: 花色限制
		2:
			return [
				BossBlind.new("Water/Abyss", BossEffect.NO_HEARTS,
					"Hearts don't score", "💧", 29, "坎"),
				BossBlind.new("Fire/Clinging", BossEffect.NO_SPADES,
					"Spades don't score", "🔥", 30, "离"),
				BossBlind.new("Thunder/Arousing", BossEffect.NO_CLUBS,
					"Clubs don't score", "⚡", 51, "震"),
				BossBlind.new("Lake/Joyous", BossEffect.NO_DIAMONDS,
					"Diamonds don't score", "🏞️", 58, "兑"),
			]
		## Ante 3: 牌面限制
		3:
			return [
				BossBlind.new("Darkening of Light", BossEffect.NO_FACE_CARDS,
					"Face cards score no chips", "🌑", 36, "明夷"),
				BossBlind.new("Decrease", BossEffect.LOW_CARDS_DEBUFF,
					"Cards 2-5 don't score", "📉", 41, "损"),
				BossBlind.new("Obstruction", BossEffect.FACE_CARDS_DEBUFF,
					"Face cards: -20 Chips each", "🚧", 39, "蹇"),
				BossBlind.new("Youthful Folly", BossEffect.BLIND_HAND,
					"3 random cards are face-down", "🃏", 4, "蒙"),
			]
		## Ante 4: 牌型限制
		4:
			return [
				BossBlind.new("Opposition", BossEffect.NO_PAIRS,
					"Pair-type hands disabled", "⚔️", 38, "睽"),
				BossBlind.new("Standstill", BossEffect.NO_STRAIGHTS,
					"Straight-type hands disabled", "🛑", 12, "否"),
				BossBlind.new("Splitting Apart", BossEffect.NO_FLUSH,
					"Flush-type hands disabled", "💔", 23, "剥"),
				BossBlind.new("The Cauldron", BossEffect.FEWER_HANDS,
					"Only 3 hands this round", "🫕", 50, "鼎"),
			]
		## Ante 5: 得分削弱
		5:
			return [
				BossBlind.new("Biting Through", BossEffect.HALVE_MULT,
					"Total Mult is halved", "🦷", 21, "噬嗑"),
				BossBlind.new("Great Exceeding", BossEffect.DOUBLE_TARGET,
					"Score target is doubled", "📈", 28, "大过"),
				BossBlind.new("Gradual Progress", BossEffect.SCORE_DECAY,
					"Each hand scores 10% less", "🐌", 53, "渐"),
				BossBlind.new("Treading", BossEffect.MONEY_DRAIN,
					"Lose $1 per hand played", "👞", 10, "履"),
			]
		## Ante 6: 系统干扰
		6:
			return [
				BossBlind.new("Influence", BossEffect.BEAST_DISABLED,
					"First Beast's effect disabled", "🫥", 31, "咸"),
				BossBlind.new("Breakthrough", BossEffect.SEAL_DISABLED,
					"All Seals disabled this round", "🔓", 43, "夬"),
				BossBlind.new("Grace", BossEffect.ENHANCEMENT_STRIPPED,
					"All Enhancements disabled", "✨", 22, "贲"),
				BossBlind.new("Limitation", BossEffect.HAND_SIZE_MINUS,
					"Hand size -2 this round", "📏", 60, "节"),
			]
		## Ante 7: 综合困难
		7:
			return [
				BossBlind.new("After Completion", BossEffect.SCORE_DECAY,
					"Each hand scores 10% less", "🏁", 63, "既济"),
				BossBlind.new("Revolution", BossEffect.DOUBLE_TARGET,
					"Score target is doubled", "🔄", 49, "革"),
				BossBlind.new("Conflict", BossEffect.NO_FACE_CARDS,
					"Face cards score no chips", "⚔️", 6, "讼"),
				BossBlind.new("Exhaustion", BossEffect.FEWER_HANDS,
					"Only 3 hands this round", "😰", 47, "困"),
			]
		## Ante 8: 终极Boss
		8:
			return [
				BossBlind.new("Before Completion", BossEffect.HALVE_MULT,
					"Total Mult is halved", "⏳", 64, "未济"),
				BossBlind.new("Heaven/Creative", BossEffect.DOUBLE_TARGET,
					"Score target is doubled", "☰", 1, "乾"),
				BossBlind.new("Abundance", BossEffect.NO_DISCARDS,
					"No discards this round", "🌕", 55, "丰"),
			]
		_:
			## 超过8回合时随机选择高难度Boss
			return get_bosses_for_ante(randi_range(5, 8))

## ============================================================
## 获取随机Boss
## ============================================================
static func get_random_boss(ante: int = 1, exclude_names: Array = []) -> BossBlind:
	var bosses = get_bosses_for_ante(ante)
	var available: Array = []
	for b in bosses:
		if b.name not in exclude_names:
			available.append(b)
	if available.is_empty():
		available = bosses
	return available[randi() % available.size()]

## ============================================================
## 旧接口兼容 — 不带ante参数的随机Boss
## ============================================================
static func get_all_bosses() -> Array:
	var all: Array = []
	for ante in range(1, 9):
		all.append_array(get_bosses_for_ante(ante))
	return all

## ============================================================
## 难度曲线 — 目标分数
## ============================================================
## 设计理念:
## Ante 1: 无异兽，基础牌力 ~100-300/手 → 4手最多 1200
## Ante 2: 1-2异兽，~200-500/手
## Ante 3-4: 2-3异兽，~500-1500/手
## Ante 5-6: 3-4异兽+升级，~1500-4000/手
## Ante 7-8: 4-5异兽，~4000-10000+/手

static func get_blind_target(ante: int, blind_type: BlindType) -> int:
	var small_targets = [300, 500, 800, 1400, 2400, 4000, 6500, 10000]
	var ante_idx = clampi(ante - 1, 0, small_targets.size() - 1)
	var base = small_targets[ante_idx]

	match blind_type:
		BlindType.SMALL_BLIND:
			return base
		BlindType.BIG_BLIND:
			return int(base * 1.5)
		BlindType.BOSS_BLIND:
			return base * 2
		_:
			return base

## ============================================================
## 奖励
## ============================================================
static func get_blind_reward(blind_type: BlindType) -> int:
	match blind_type:
		BlindType.SMALL_BLIND: return 3
		BlindType.BIG_BLIND: return 4
		BlindType.BOSS_BLIND: return 5
		_: return 3

## ============================================================
## 盲注名称
## ============================================================
static func get_blind_name(blind_type: BlindType) -> String:
	match blind_type:
		BlindType.SMALL_BLIND: return "Small Blind"
		BlindType.BIG_BLIND: return "Big Blind"
		BlindType.BOSS_BLIND: return "Boss Blind"
		_: return "Blind"
