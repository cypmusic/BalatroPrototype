## beat_clock.gd
## 节拍时钟系统 V0.085 — BPM同步机制
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

## 判定窗口
var perfect_window: float = 0.05     ## Perfect判定窗口(±秒)
var good_window: float = 0.15        ## Good判定窗口(±秒)
var window_is_open: bool = false     ## 出牌窗口状态

## 加成倍率
var perfect_bonus: float = 1.2       ## Perfect加成
var good_bonus: float = 1.0          ## Good加成(无加成)
var miss_penalty: float = 0.8        ## Miss惩罚

## Boss战时限
var bars_remaining: int = 16         ## 剩余小节数
var extra_bars: int = 0              ## 异兽额外小节数

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

## 每Ante的Boss战小节数
const BARS_TABLE: Array = [
	20, 18, 16, 16, 14, 14, 12, 12,
]

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
	bars_remaining = total_bars
	extra_bars = 0

## 为Boss回合启动节拍系统
func start_boss_beat(ante: int, extra: int = 0) -> void:
	var ante_idx = clampi(ante - 1, 0, BPM_TABLE.size() - 1)
	current_bpm = BPM_TABLE[ante_idx]
	beat_interval = 60.0 / current_bpm
	total_bars = BARS_TABLE[ante_idx]
	extra_bars = extra
	bars_remaining = total_bars + extra_bars

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

## 添加额外小节（异兽效果）
func add_extra_bars(count: int) -> void:
	extra_bars += count
	bars_remaining += count

## 降低BPM一档（相柳效果）
func reduce_bpm_tier(tiers: int = 1) -> void:
	## 从当前BPM找到对应档位并降低
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
			stop()
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
## 出牌判定 — 玩家在此时刻出牌，返回判定结果
## ============================================================
func judge_play() -> Dictionary:
	if not is_active:
		return {"accuracy": "None", "bonus": 1.0}

	## 计算距最近拍的偏移量
	var offset = beat_timer
	if offset > beat_interval * 0.5:
		offset = beat_interval - offset  ## 距下一拍更近

	var accuracy: String
	var bonus: float

	if offset <= perfect_window:
		accuracy = "Perfect"
		bonus = perfect_bonus
	elif offset <= good_window:
		accuracy = "Good"
		bonus = good_bonus
	else:
		accuracy = "Miss"
		bonus = miss_penalty

	beat_result.emit(accuracy, bonus)

	return {
		"accuracy": accuracy,
		"bonus": bonus,
		"offset": offset,
		"beat_timer": beat_timer,
	}

## ============================================================
## 状态查询
## ============================================================

## 获取当前进度(0.0~1.0)
func get_progress() -> float:
	if total_bars + extra_bars <= 0:
		return 1.0
	var total = total_bars + extra_bars
	var elapsed = total - bars_remaining
	return float(elapsed) / float(total)

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
		"progress": get_progress(),
		"is_active": is_active,
		"window_open": window_is_open,
	}

## 判断Boss战是否超时(时间耗尽)
func is_time_up() -> bool:
	return is_boss_round and bars_remaining <= 0

## ============================================================
## 天机抽牌(Reel Draw)周期 — 与节拍同步
## ============================================================
## 天机抽牌在每小节开始时触发
## 返回当前是否为天机抽牌时刻
func is_reel_draw_beat() -> bool:
	return is_active and current_beat == 0

## 获取天机抽牌速度修改器（异兽效果）
func get_reel_speed_modifier(active_jokers: Array) -> float:
	var modifier: float = 1.0
	for joker in active_jokers:
		if joker.trigger == JokerData.TriggerType.ON_REEL_DRAW:
			if joker.effect == JokerData.EffectType.REDUCE_REQUIREMENT:
				modifier *= joker.value  ## 如凝时兽: 0.5(减半)
	return modifier
