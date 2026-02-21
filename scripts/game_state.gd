## game_state.gd
## 全局游戏状态单例 (AutoLoad) — V0.086
## 集中管理可变游戏状态，与 UI 脱耦
## 在 Project Settings → AutoLoad 中注册为 "GameState"
extends Node

## ========== 信号 ==========
signal money_changed(old_value: int, new_value: int)
signal hands_changed(value: int)
signal discards_changed(value: int)
signal ante_changed(ante: int, blind_index: int)
signal game_restarted()

## ========== 游戏进程 ==========
var current_ante: int = 1
var blind_index: int = 0  ## 0=Small, 1=Big, 2=Boss
var current_blind_type: int = 0  ## BlindData.BlindType
var current_boss = null
var ante_boss = null
var used_boss_names: Array = []

## ========== 回合状态 ==========
var hands_remaining: int = GameConfig.STARTING_HANDS
var discards_remaining: int = GameConfig.STARTING_DISCARDS
var hands_played_this_round: int = 0
var total_discarded: int = 0

## ========== 手牌上限（幽冥牌可修改）==========
var hand_size_modifier: int = 0  ## 永久手牌上限修正值（负数=减少）

## ========== 出牌上限（天书"阴符经"可提升）==========
var max_play_cards_bonus: int = 0  ## 出牌上限加成（阴符经+1，解锁6张牌型）

## ========== 64卦路线 ==========
var current_hexagram: int = -1       ## 当前卦（文王序），-1=未选择
var hexagram_effect_id: String = ""  ## 当前卦的效果ID

## ========== 经济 ==========
var _money: int = GameConfig.STARTING_MONEY

var money: int:
	get: return _money
	set(value):
		var old = _money
		_money = value
		money_changed.emit(old, value)

## ========== 动画/交互锁 ==========
var is_score_animating: bool = false
var is_discarding: bool = false
var is_round_ended: bool = false
var is_game_won: bool = false

## ========== 方法 ==========

func reset() -> void:
	current_ante = 1
	blind_index = 0
	current_blind_type = 0
	current_boss = null
	ante_boss = null
	used_boss_names.clear()

	hands_remaining = GameConfig.STARTING_HANDS
	discards_remaining = GameConfig.STARTING_DISCARDS
	hands_played_this_round = 0
	total_discarded = 0
	_money = GameConfig.STARTING_MONEY
	hand_size_modifier = 0
	max_play_cards_bonus = 0
	current_hexagram = -1
	hexagram_effect_id = ""

	is_score_animating = false
	is_discarding = false
	is_round_ended = false
	is_game_won = false

	game_restarted.emit()

func start_round(blind_type: int, boss) -> void:
	current_blind_type = blind_type
	current_boss = boss
	hands_played_this_round = 0
	is_round_ended = false
	total_discarded = 0

	hands_remaining = GameConfig.STARTING_HANDS
	discards_remaining = GameConfig.STARTING_DISCARDS

	## Boss effect adjustments
	if current_boss != null:
		match current_boss.effect:
			BlindData.BossEffect.FEWER_HANDS:
				hands_remaining = 3
			BlindData.BossEffect.NO_DISCARDS:
				discards_remaining = 0



func use_hand() -> void:
	hands_remaining -= 1
	hands_played_this_round += 1
	hands_changed.emit(hands_remaining)

func use_discard(count: int) -> void:
	discards_remaining -= 1
	total_discarded += count
	discards_changed.emit(discards_remaining)

func advance_blind() -> void:
	blind_index += 1
	if blind_index >= 3:
		blind_index = 0
		current_ante += 1
		ante_boss = null
	ante_changed.emit(current_ante, blind_index)

func calculate_income(won: bool) -> int:
	var income = GameConfig.BASE_INCOME
	var interest = mini(money / 5, GameConfig.INTEREST_CAP)
	income += interest
	if won:
		income += GameConfig.WIN_BONUS
	return income

## ========== 动态上限计算 ==========

## 当前有效手牌数（基础8 + 幽冥修正）
func get_effective_hand_size() -> int:
	return maxi(1, GameConfig.INITIAL_HAND_SIZE + hand_size_modifier)

## 当前出牌上限（基础5 + 天书加成）
func get_max_play_cards() -> int:
	return GameConfig.MAX_SELECT + max_play_cards_bonus

## 检查是否被遮罩界面覆盖（由 main 调用更新）
var overlay_active: bool = false
