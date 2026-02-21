## beat_clock.gd
## 节拍时钟系统 V0.086 — BPM同步 + Boss战限时出牌 + Bonus池计分
## Boss战中使用节拍系统：玩家需在节拍窗口内出牌获得加成
## 设计为AutoLoad单例: BeatClock
class_name BeatClockSystem
extends Node

## ============================================================
## 信号
## ============================================================
signal beat_tick(beat_index: int)           ## 每拍触发
signal bar_complete(bar_index: int)         ## 每小节完成
signal beat_window_open                     ## 出牌窗口开启
signal beat_window_close                    ## 出牌窗口关闭
signal beat_result(accuracy: String, bonus: float) ## 出牌判定结果
signal timer_expired()                      ## Boss战计时耗尽

## ============================================================
## 状态
## ============================================================
var is_active: bool = false          ## 是否启动节拍系统
var is_boss_round: bool = false      ## 是否Boss回合

## BPM与节拍
var current_bpm: float = 120.0       ## 当前BPM
var beat_interval: float = 0.5       ## 每拍间隔(秒) = 60/BPM
var beats_per_bar: int = 4           ## 每小节拍数
var current_beat: int = 0            ## 当前拍数(0-based)
var current_bar: int = 0             ## 当前小节数
var total_bars: int = 16             ## Boss战总小节数(默认)

## 时间追踪
var beat_timer: float = 0.0          ## 拍内计时器
var total_elapsed: float = 0.0       ## 总经过时间

## 判定窗口 — 按设计文档以强拍(第1/3拍)为基准
var perfect_window: float = 0.040    ## 天合 Perfect (±40ms)
var great_window: float = 0.100      ## 地应 Great   (±100ms)
var good_window: float = 0.200       ## 人和 Good    (±200ms)
var window_is_open: bool = false     ## 出牌窗口状态

## Boss战时限
var bars_remaining: int = 16         ## 剩余小节数
var extra_bars: int = 0              ## 异兽额外小节数

## ============================================================
## Bonus池计分模型
## Boss目标满分 = 基础分(2/3) + Bonus池(1/3)
## Bonus池 ÷ 出牌次数 = 每手Bonus上限
## ============================================================
var bonus_pool: int = 0              ## 本Boss回合Bonus池总额
var max_hands_for_bonus: int = 4     ## 预设出牌次数(用于计算每手上限)
var hands_played_boss: int = 0       ## 本Boss回合已出手数
var total_bonus_earned: int = 0      ## 已获得Bonus总分

## Boss目标满分表（按Ante）
const BOSS_FULL_TARGETS: Array = [
	800, 1350, 2200, 3800, 6500, 10500, 17000, 27000,
]

## ============================================================
## BPM速度表 — 按Ante递增
## ============================================================
const BPM_TABLE: Array = [
	100.0,   ## Ante 1: 极慢
	110.0,   ## Ante 2: 慢
	120.0,   ## Ante 3: 中等
	130.0,   ## Ante 4: 中快
	140.0,   ## Ante 5: 快
	150.0,   ## Ante 6: 较快
	160.0,   ## Ante 7: 很快
	180.0,   ## Ante 8: 极快
]

## 每次出牌的限时小节数
const PLAY_TIMER_BARS: int = 16

## 每张补牌增加的小节数
const REFILL_BARS_PER_CARD: int = 4

## ============================================================
## 初始化与重置
## ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset() -> void:
	is_active = false
	is_boss_round = false
	current_beat = 0
	current_bar = 0
	beat_timer = 0.0
	total_elapsed = 0.0
	window_is_open = false
	bars_remaining = PLAY_TIMER_BARS
	extra_bars = 0
	bonus_pool = 0
	max_hands_for_bonus = 4
	hands_played_boss = 0
	total_bonus_earned = 0

## 为Boss回合启动节拍系统
func start_boss_beat(ante: int, starting_hands: int = 4) -> void:
	var ante_idx = clampi(ante - 1, 0, BPM_TABLE.size() - 1)
	current_bpm = BPM_TABLE[ante_idx]
	beat_interval = 60.0 / current_bpm

	## 计算 Bonus 池
	var full_target = BOSS_FULL_TARGETS[ante_idx]
	bonus_pool = int(full_target / 3.0)
	max_hands_for_bonus = starting_hands
	hands_played_boss = 0
	total_bonus_earned = 0

	## 每次出牌16小节限时
	bars_remaining = PLAY_TIMER_BARS
	extra_bars = 0
	total_bars = PLAY_TIMER_BARS

	current_beat = 0
	current_bar = 0
	beat_timer = 0.0
	total_elapsed = 0.0
	window_is_open = false
	is_active = true
	is_boss_round = true

## 停止节拍系统
func stop() -> void:
	is_active = false
	is_boss_round = false
	window_is_open = false

## 出牌后重置计时器（新的16小节）
func reset_play_timer() -> void:
	bars_remaining = PLAY_TIMER_BARS + extra_bars
	extra_bars = 0
	current_bar = 0
	current_beat = 0
	beat_timer = 0.0
	hands_played_boss += 1

## 添加额外小节（补牌时调用：每张+4小节）
func add_refill_bars(card_count: int) -> void:
	var extra = card_count * REFILL_BARS_PER_CARD
	extra_bars += extra
	bars_remaining += extra

## 添加额外小节（异兽效果）
func add_extra_bars(count: int) -> void:
	extra_bars += count
	bars_remaining += count

## 降低BPM一档（相柳效果）
func reduce_bpm_tier(tiers: int = 1) -> void:
	var current_tier = 0
	for i in range(BPM_TABLE.size()):
		if BPM_TABLE[i] >= current_bpm:
			current_tier = i
			break
	var new_tier = maxi(0, current_tier - tiers)
	current_bpm = BPM_TABLE[new_tier]
	beat_interval = 60.0 / current_bpm

## ============================================================
## 帧更新
## ============================================================
func _process(delta: float) -> void:
	if not is_active:
		return

	beat_timer += delta
	total_elapsed += delta

	## 拍触发检测
	if beat_timer >= beat_interval:
		beat_timer -= beat_interval
		_on_beat()

## ============================================================
## 节拍事件
## ============================================================
func _on_beat() -> void:
	current_beat += 1
	beat_tick.emit(current_beat)

	## 小节完成
	if current_beat >= beats_per_bar:
		current_beat = 0
		current_bar += 1
		bars_remaining -= 1
		bar_complete.emit(current_bar)

		## Boss战时间耗尽
		if bars_remaining <= 0:
			timer_expired.emit()
			return

	## 出牌窗口管理 — 每小节第1拍开启窗口
	if current_beat == 0:
		_open_window()
	elif current_beat == 1:
		_close_window()

func _open_window() -> void:
	if not window_is_open:
		window_is_open = true
		beat_window_open.emit()

func _close_window() -> void:
	if window_is_open:
		window_is_open = false
		beat_window_close.emit()

## ============================================================
## 出牌判定 — 以强拍(第1/3拍)为判定基准
## 返回 {grade, bonus_ratio, distance_ms, bonus_score}
## ============================================================
func judge_boss_play() -> Dictionary:
	if not is_active or not is_boss_round:
		return {"grade": "None", "bonus_ratio": 0.0, "distance_ms": 0.0, "bonus_score": 0}

	## 计算到最近强拍（第1、3拍，即 beat 0 和 beat 2）的距离
	## 强拍间隔 = 2个beat间隔
	var strong_beat_interval = beat_interval * 2.0
	var time_in_strong = fmod(total_elapsed, strong_beat_interval)
	var distance = minf(time_in_strong, strong_beat_interval - time_in_strong)

	var grade: String
	var bonus_ratio: float

	if distance <= perfect_window:
		grade = "Perfect"     ## 天合
		bonus_ratio = 1.0
	elif distance <= great_window:
		grade = "Great"       ## 地应
		bonus_ratio = 0.6
	elif distance <= good_window:
		grade = "Good"        ## 人和
		bonus_ratio = 0.3
	else:
		grade = "Miss"        ## 无感
		bonus_ratio = 0.0

	## 计算Bonus分
	var per_hand_cap = get_per_hand_bonus_cap()
	var bonus_score = int(per_hand_cap * bonus_ratio)

	beat_result.emit(grade, bonus_ratio)

	return {
		"grade": grade,
		"bonus_ratio": bonus_ratio,
		"distance_ms": distance * 1000.0,
		"bonus_score": bonus_score,
	}

## 获取每手Bonus上限
func get_per_hand_bonus_cap() -> int:
	if max_hands_for_bonus <= 0:
		return 0
	return int(float(bonus_pool) / float(max_hands_for_bonus))

## 记录Bonus得分
func record_bonus(bonus_score: int) -> void:
	total_bonus_earned += bonus_score

## 旧接口兼容
func judge_play() -> Dictionary:
	if not is_active:
		return {"accuracy": "None", "bonus": 1.0}
	var offset = beat_timer
	if offset > beat_interval * 0.5:
		offset = beat_interval - offset
	var accuracy: String
	var bonus: float
	if offset <= perfect_window:
		accuracy = "Perfect"
		bonus = 1.2
	elif offset <= good_window:
		accuracy = "Good"
		bonus = 1.0
	else:
		accuracy = "Miss"
		bonus = 0.8
	beat_result.emit(accuracy, bonus)
	return {"accuracy": accuracy, "bonus": bonus, "offset": offset, "beat_timer": beat_timer}

## ============================================================
## 状态查询
## ============================================================

## Boss战计时进度(0.0~1.0)
func get_timer_progress() -> float:
	var total = PLAY_TIMER_BARS + extra_bars
	if total <= 0:
		return 1.0
	var elapsed_bars = total - bars_remaining
	return clampf(float(elapsed_bars) / float(total), 0.0, 1.0)

## 获取拍内进度(0.0~1.0)用于UI节拍指示器
func get_beat_progress() -> float:
	if beat_interval <= 0:
		return 0.0
	return beat_timer / beat_interval

## 获取当前状态信息
func get_status() -> Dictionary:
	return {
		"bpm": current_bpm,
		"bar": current_bar,
		"beat": current_beat,
		"bars_remaining": bars_remaining,
		"progress": get_timer_progress(),
		"is_active": is_active,
		"window_open": window_is_open,
		"bonus_pool": bonus_pool,
		"total_bonus": total_bonus_earned,
		"per_hand_cap": get_per_hand_bonus_cap(),
	}

## 判断Boss战是否超时(时间耗尽)
func is_time_up() -> bool:
	return is_boss_round and bars_remaining <= 0

## ============================================================
## 天机抽牌(Reel Draw)周期 — 与节拍同步
## ============================================================
func is_reel_draw_beat() -> bool:
	return is_active and current_beat == 0

func get_reel_speed_modifier(active_jokers: Array) -> float:
	var modifier: float = 1.0
	for joker in active_jokers:
		if joker.trigger == JokerData.TriggerType.ON_REEL_DRAW:
			if joker.effect == JokerData.EffectType.REDUCE_REQUIREMENT:
				modifier *= joker.value
	return modifier
