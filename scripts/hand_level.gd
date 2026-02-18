## hand_level.gd
## 牌型升级系统 V9.1 - 支持星球牌直接升级
class_name HandLevel
extends RefCounted

static var play_counts: Dictionary = {}
static var levels: Dictionary = {}
## 星球牌额外加成（独立于打牌升级）
static var planet_bonus_chips: Dictionary = {}
static var planet_bonus_mult: Dictionary = {}

const PLAYS_PER_LEVEL: int = 3
const CHIPS_PER_LEVEL: int = 10
const MULT_PER_LEVEL: int = 1

static func reset() -> void:
	play_counts.clear()
	levels.clear()
	planet_bonus_chips.clear()
	planet_bonus_mult.clear()
	for type in PokerHand.HandType.values():
		play_counts[type] = 0
		levels[type] = 1
		planet_bonus_chips[type] = 0
		planet_bonus_mult[type] = 0

static func record_play(hand_type: PokerHand.HandType) -> Dictionary:
	if levels.is_empty():
		reset()
	play_counts[hand_type] = play_counts.get(hand_type, 0) + 1
	var count = play_counts[hand_type]
	var old_level = levels.get(hand_type, 1)
	var new_level = 1 + int(count / PLAYS_PER_LEVEL)
	var leveled_up = new_level > old_level
	levels[hand_type] = new_level
	return {
		"leveled_up": leveled_up,
		"level": new_level,
		"plays": count,
		"plays_to_next": PLAYS_PER_LEVEL - (count % PLAYS_PER_LEVEL),
	}

## 星球牌升级：直接增加对应牌型的等级和加成
static func planet_level_up(hand_type: PokerHand.HandType, bonus_chips: int, bonus_mult: int) -> Dictionary:
	if levels.is_empty():
		reset()
	levels[hand_type] = levels.get(hand_type, 1) + 1
	planet_bonus_chips[hand_type] = planet_bonus_chips.get(hand_type, 0) + bonus_chips
	planet_bonus_mult[hand_type] = planet_bonus_mult.get(hand_type, 0) + bonus_mult
	return {
		"new_level": levels[hand_type],
		"total_bonus_chips": get_bonus(hand_type)["chips"],
		"total_bonus_mult": get_bonus(hand_type)["mult"],
	}

static func get_level_info(hand_type: PokerHand.HandType) -> Dictionary:
	if levels.is_empty():
		reset()
	var level = levels.get(hand_type, 1)
	var count = play_counts.get(hand_type, 0)
	return {
		"level": level,
		"plays": count,
		"plays_to_next": PLAYS_PER_LEVEL - (count % PLAYS_PER_LEVEL),
		"bonus_chips": get_bonus(hand_type)["chips"],
		"bonus_mult": get_bonus(hand_type)["mult"],
	}

## 总加成 = 打牌升级加成 + 星球牌加成
static func get_bonus(hand_type: PokerHand.HandType) -> Dictionary:
	if levels.is_empty():
		reset()
	var level = levels.get(hand_type, 1)
	var base_chips = (level - 1) * CHIPS_PER_LEVEL
	var base_mult = (level - 1) * MULT_PER_LEVEL
	## 星球牌加成已经包含在 level 提升中，所以这里只用 level 计算
	## 但星球牌每级给的数值比打牌升级更高，所以用混合计算
	## 实际实现：play升级给固定值，planet额外加成独立累加
	var extra_chips = planet_bonus_chips.get(hand_type, 0)
	var extra_mult = planet_bonus_mult.get(hand_type, 0)
	return {
		"chips": base_chips + extra_chips,
		"mult": base_mult + extra_mult,
	}
