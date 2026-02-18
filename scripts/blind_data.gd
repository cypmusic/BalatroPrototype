## blind_data.gd
## 盲注系统 V9 - 重新设计难度曲线
class_name BlindData
extends RefCounted

enum BlindType {
	SMALL_BLIND,
	BIG_BLIND,
	BOSS_BLIND,
}

enum BossEffect {
	NONE,
	NO_FACE_CARDS,
	NO_HEARTS,
	NO_DIAMONDS,
	NO_SPADES,
	NO_CLUBS,
	DEBUFF_FIRST_HAND,
	FEWER_HANDS,
	NO_DISCARDS,
}

class BossBlind:
	var name: String
	var effect: BossEffect
	var description: String
	var emoji: String

	func _init(n: String, e: BossEffect, d: String, em: String):
		name = n
		effect = e
		description = d
		emoji = em

static func get_all_bosses() -> Array:
	return [
		BossBlind.new("The Hook", BossEffect.FEWER_HANDS, "Only 3 hands this round", "🪝"),
		BossBlind.new("The Wall", BossEffect.NO_DISCARDS, "No discards this round", "🧱"),
		BossBlind.new("The Eye", BossEffect.NO_FACE_CARDS, "Face cards score no chips", "👁️"),
		BossBlind.new("The Mouth", BossEffect.NO_HEARTS, "Hearts don't score", "👄"),
		BossBlind.new("The Plant", BossEffect.NO_CLUBS, "Clubs don't score", "🌿"),
		BossBlind.new("The Serpent", BossEffect.NO_SPADES, "Spades don't score", "🐍"),
		BossBlind.new("The Ox", BossEffect.NO_DIAMONDS, "Diamonds don't score", "🐂"),
		BossBlind.new("The Needle", BossEffect.DEBUFF_FIRST_HAND, "First hand played scores half", "🪡"),
	]

static func get_random_boss(exclude_names: Array = []) -> BossBlind:
	var bosses = get_all_bosses()
	var available: Array = []
	for b in bosses:
		if b.name not in exclude_names:
			available.append(b)
	if available.is_empty():
		available = bosses
	return available[randi() % available.size()]

## 难度曲线设计：
## Ante 1: 玩家无小丑牌，基础牌力 ~100-300/手
## Ante 2: 1-2 张小丑牌，~200-500/手
## Ante 3-4: 2-3 张小丑牌，能打出 ~500-1500/手
## Ante 5-6: 3-4 张小丑牌 + 升级，~1500-4000/手
## Ante 7-8: 4-5 张小丑牌，~4000-10000+/手
##
## 每手基础分约 100-200（无小丑），4 手最多 400-800
## 小丑牌平均增加 2-3x 倍率
static func get_blind_target(ante: int, blind_type: BlindType) -> int:
	## Small Blind 基础目标
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

static func get_blind_reward(blind_type: BlindType) -> int:
	match blind_type:
		BlindType.SMALL_BLIND: return 3
		BlindType.BIG_BLIND: return 4
		BlindType.BOSS_BLIND: return 5
		_: return 3

static func get_blind_name(blind_type: BlindType) -> String:
	match blind_type:
		BlindType.SMALL_BLIND: return "Small Blind"
		BlindType.BIG_BLIND: return "Big Blind"
		BlindType.BOSS_BLIND: return "Boss Blind"
		_: return "Blind"
