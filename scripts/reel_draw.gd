## reel_draw.gd
## 天机抽牌系统 V0.086 — 3张牌老虎机式节拍抽牌
## 每回合发牌：5张自动 + 3张天机（A/B/C三档速度）
## A=4次/小节(四分音符) B=8次/小节(八分音符) C=16次/小节(十六分音符)
extends Node2D

signal reel_complete(drawn_cards: Array)  ## 三张牌全部锁定

## ========== BPM 速度表（天机抽牌专用，与Boss战BPM独立）==========
const REEL_BPM_TABLE: Array = [
	80.0,    ## Ante 1
	88.0,    ## Ante 2
	96.0,    ## Ante 3
	104.0,   ## Ante 4
	112.0,   ## Ante 5
	120.0,   ## Ante 6
	128.0,   ## Ante 7
	136.0,   ## Ante 8
]

## ========== 槽位配置 ==========
## changes_per_bar: 每小节变化次数
## bars: 循环小节数
## total = changes_per_bar × bars (候选池翻面总次数)
## pool_size = total × 2 (候选池大小)
const SLOT_CONFIG: Array = [
	{"name": "A", "changes_per_bar": 4,  "bars": 4, "color": Color(0.95, 0.75, 0.25)},  ## 16次, 池32张
	{"name": "B", "changes_per_bar": 8,  "bars": 3, "color": Color(0.35, 0.75, 0.95)},  ## 24次, 池48张
	{"name": "C", "changes_per_bar": 16, "bars": 2, "color": Color(0.85, 0.35, 0.85)},  ## 32次, 池64张
]

## ========== 布局常量 ==========
const REEL_Y: float = 400.0          ## 天机区域Y坐标
const SLOT_SPACING: float = 200.0    ## 槽位间距
const CARD_W: float = 140.0
const CARD_H: float = 195.0
const LABEL_SIZE: int = 18
const TITLE_SIZE: int = 28
const HINT_SIZE: int = 16
const SLOT_LABEL_SIZE: int = 22
const TIMER_BAR_H: float = 6.0      ## 计时条高度

## ========== 状态 ==========
var is_active: bool = false
var current_bpm: float = 80.0
var measure_duration: float = 3.0    ## 一小节时长(秒)

## 三个槽位的状态
var slots: Array = []  ## [{config, candidates, current_idx, interval, timer, locked, locked_card, elapsed, total_duration}]
var active_slot_index: int = 0       ## 当前激活的槽位(0=A, 1=B, 2=C)
var drawn_cards: Array = []          ## 已锁定的 CardData 列表

## 抽牌来源
var deck_ref = null                  ## 引用 deck 节点
var speed_modifier: float = 1.0      ## 异兽速度修正

## 视觉效果
var flash_timer: float = 0.0
var flash_slot: int = -1

func _ready() -> void:
	visible = false
	z_index = 40

## ========== 启动天机抽牌 ==========
func start_reel(ante: int, deck_node, jokers: Array = []) -> void:
	deck_ref = deck_node
	drawn_cards.clear()
	slots.clear()
	active_slot_index = 0

	## 设置 BPM
	var ante_idx = clampi(ante - 1, 0, REEL_BPM_TABLE.size() - 1)
	current_bpm = REEL_BPM_TABLE[ante_idx]
	measure_duration = 240.0 / current_bpm  ## 4拍 = 240/BPM 秒

	## 计算异兽速度修正
	speed_modifier = 1.0
	for joker in jokers:
		if joker.trigger == JokerData.TriggerType.ON_REEL_DRAW:
			if joker.effect == JokerData.EffectType.REDUCE_REQUIREMENT:
				speed_modifier *= joker.value

	## 初始化三个槽位（候选池延迟构建，避免同一张牌出现在多个槽位）
	for i in range(3):
		var cfg = SLOT_CONFIG[i]
		var total_changes = cfg["changes_per_bar"] * cfg["bars"]
		var pool_size = total_changes * 2
		var interval = measure_duration / cfg["changes_per_bar"] / speed_modifier
		var total_dur = cfg["bars"] * measure_duration / speed_modifier

		## 只为第一个槽位构建候选池，后续槽位在前一个锁定后构建
		var candidates: Array = []
		if i == 0:
			candidates = _build_candidate_pool(pool_size)

		slots.append({
			"config": cfg,
			"candidates": candidates,
			"current_idx": 0,
			"interval": interval,
			"timer": 0.0,
			"locked": false,
			"locked_card": null,
			"elapsed": 0.0,
			"total_duration": total_dur,
			"total_changes": total_changes,
			"pool_size": pool_size,
		})

	is_active = true
	visible = true
	GameState.overlay_active = true
	queue_redraw()

## 构建候选池：从牌堆抽取 N 张，随机排列
func _build_candidate_pool(pool_size: int) -> Array:
	var pool: Array = []
	var available = deck_ref.draw_pile.size()
	var actual_size = mini(pool_size, available)
	if actual_size <= 0:
		return pool

	## 从draw_pile随机选取（不移除，只记录索引）
	var indices: Array = []
	for i in range(deck_ref.draw_pile.size()):
		indices.append(i)

	## Fisher-Yates 选取 actual_size 个
	for i in range(actual_size):
		var j = i + (randi() % (indices.size() - i))
		var temp = indices[i]
		indices[i] = indices[j]
		indices[j] = temp

	for i in range(actual_size):
		pool.append(deck_ref.draw_pile[indices[i]])

	return pool

## ========== 帧更新 ==========
func _process(delta: float) -> void:
	if not is_active:
		return

	## 闪光效果衰减
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			flash_slot = -1

	## 更新当前激活槽位
	if active_slot_index < 3:
		var slot = slots[active_slot_index]
		if not slot["locked"]:
			slot["elapsed"] += delta
			slot["timer"] += delta

			## 到达变化间隔 → 切换下一张牌面
			if slot["timer"] >= slot["interval"]:
				slot["timer"] -= slot["interval"]
				if slot["candidates"].size() > 0:
					slot["current_idx"] = (slot["current_idx"] + 1) % slot["candidates"].size()
				queue_redraw()

			## 超时自动锁定
			if slot["elapsed"] >= slot["total_duration"]:
				_lock_current_slot()

	queue_redraw()

## ========== 玩家点击锁定 ==========
func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if active_slot_index >= 3:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		## 检查点击是否在天机抽牌区域内
		var local = get_local_mouse_position()
		var area_top = REEL_Y - CARD_H - 80
		var area_bottom = REEL_Y + CARD_H / 2 + 60
		if local.y >= area_top and local.y <= area_bottom:
			_lock_current_slot()
			get_viewport().set_input_as_handled()

## 锁定当前槽位
func _lock_current_slot() -> void:
	if active_slot_index >= 3:
		return
	var slot = slots[active_slot_index]
	if slot["locked"]:
		return

	slot["locked"] = true

	## 取当前显示的牌
	if slot["candidates"].size() > 0:
		var card_data = slot["candidates"][slot["current_idx"]]
		slot["locked_card"] = card_data
		drawn_cards.append(card_data)

		## 从 draw_pile 中移除这张牌
		var pile_idx = deck_ref.draw_pile.find(card_data)
		if pile_idx >= 0:
			deck_ref.draw_pile.remove_at(pile_idx)

	## 锁定闪光
	flash_slot = active_slot_index
	flash_timer = 0.4

	## 推进到下一个槽位
	active_slot_index += 1

	if active_slot_index >= 3:
		## 全部锁定，短暂延迟后完成
		await get_tree().create_timer(0.6).timeout
		_finish_reel()
	else:
		## 为下一个槽位构建候选池（此时已锁定的牌已从draw_pile移除）
		var next_slot = slots[active_slot_index]
		if next_slot["candidates"].is_empty():
			next_slot["candidates"] = _build_candidate_pool(next_slot["pool_size"])
		queue_redraw()

## 完成天机抽牌
func _finish_reel() -> void:
	is_active = false
	visible = false
	GameState.overlay_active = false
	reel_complete.emit(drawn_cards)

## ========== 重置 ==========
func reset() -> void:
	is_active = false
	visible = false
	GameState.overlay_active = false
	slots.clear()
	drawn_cards.clear()
	active_slot_index = 0
	flash_timer = 0.0
	flash_slot = -1

## ========== 绘制 ==========
func _draw() -> void:
	if not is_active:
		return

	var GC = GameConfig

	## 半透明背景遮罩
	draw_rect(Rect2(-GC.CENTER_X, -GC.CENTER_Y, GC.DESIGN_WIDTH, GC.DESIGN_HEIGHT),
		Color(0.03, 0.06, 0.08, 0.85))

	## 标题
	var title = Loc.i().t("Reel Draw")
	draw_string(ThemeDB.fallback_font,
		Vector2(-120, REEL_Y - CARD_H - 100),
		title, HORIZONTAL_ALIGNMENT_CENTER, 240, TITLE_SIZE,
		Color(0.95, 0.85, 0.4))

	## 副标题 — 显示 BPM
	var bpm_text = str(int(current_bpm)) + " BPM"
	draw_string(ThemeDB.fallback_font,
		Vector2(-60, REEL_Y - CARD_H - 72),
		bpm_text, HORIZONTAL_ALIGNMENT_CENTER, 120, LABEL_SIZE,
		Color(0.6, 0.6, 0.55))

	## 绘制三个槽位
	for i in range(3):
		_draw_slot(i)

	## 操作提示
	if active_slot_index < 3:
		var slot_name = SLOT_CONFIG[active_slot_index]["name"]
		var hint = Loc.i().t("Click to lock") + " " + slot_name
		draw_string(ThemeDB.fallback_font,
			Vector2(-150, REEL_Y + CARD_H / 2 + 50),
			hint, HORIZONTAL_ALIGNMENT_CENTER, 300, HINT_SIZE,
			Color(0.8, 0.8, 0.75, 0.7 + sin(flash_timer * 10) * 0.3))
	else:
		var done_text = Loc.i().t("Complete") + "!"
		draw_string(ThemeDB.fallback_font,
			Vector2(-80, REEL_Y + CARD_H / 2 + 50),
			done_text, HORIZONTAL_ALIGNMENT_CENTER, 160, HINT_SIZE,
			Color(0.3, 0.9, 0.4))

func _draw_slot(index: int) -> void:
	var slot = slots[index]
	var cfg = slot["config"]
	var slot_color: Color = cfg["color"]

	## 槽位X位置：居中排列
	var slot_x = (index - 1) * SLOT_SPACING
	var slot_y = REEL_Y - CARD_H / 2

	## 槽位标签 (A / B / C)
	var label_color = slot_color if (index == active_slot_index or slot["locked"]) else Color(0.4, 0.4, 0.4)
	draw_string(ThemeDB.fallback_font,
		Vector2(slot_x - 8, slot_y - 12),
		cfg["name"], HORIZONTAL_ALIGNMENT_CENTER, 16, SLOT_LABEL_SIZE, label_color)

	## 速度标注
	var speed_text = str(cfg["changes_per_bar"]) + "/bar"
	draw_string(ThemeDB.fallback_font,
		Vector2(slot_x - 25, slot_y - 32),
		speed_text, HORIZONTAL_ALIGNMENT_CENTER, 50, 12,
		Color(0.5, 0.5, 0.5))

	## 卡牌区域背景
	var card_rect = Rect2(slot_x - CARD_W / 2, slot_y, CARD_W, CARD_H)
	var is_current = (index == active_slot_index and not slot["locked"])

	if slot["locked"]:
		## 锁定状态 — 金色边框
		draw_rect(card_rect, Color(0.12, 0.1, 0.08))
		draw_rect(card_rect, Color(0.95, 0.85, 0.4), false, 3.0)
	elif is_current:
		## 当前激活 — 发光边框
		var pulse = 0.6 + sin(slot["elapsed"] * 8.0) * 0.2
		draw_rect(card_rect, Color(0.08, 0.08, 0.1))
		draw_rect(card_rect, Color(slot_color.r, slot_color.g, slot_color.b, pulse), false, 2.5)
	else:
		## 等待中 — 暗色
		draw_rect(card_rect, Color(0.06, 0.06, 0.08))
		draw_rect(card_rect, Color(0.25, 0.25, 0.25), false, 1.5)

	## 闪光效果
	if flash_slot == index and flash_timer > 0:
		var flash_alpha = flash_timer / 0.4 * 0.5
		draw_rect(card_rect, Color(1.0, 1.0, 0.9, flash_alpha))

	## 卡牌内容
	if slot["locked"] and slot["locked_card"] != null:
		_draw_card_face(slot_x, slot_y, slot["locked_card"], true)
	elif is_current and slot["candidates"].size() > 0:
		var card_data = slot["candidates"][slot["current_idx"]]
		_draw_card_face(slot_x, slot_y, card_data, false)
	elif not is_current and not slot["locked"]:
		## 未激活 — 背面
		_draw_card_back(slot_x, slot_y)

	## 计时条（仅当前激活且未锁定）
	if is_current:
		var progress = slot["elapsed"] / slot["total_duration"]
		var bar_y = slot_y + CARD_H + 8
		var bar_w = CARD_W
		## 背景
		draw_rect(Rect2(slot_x - bar_w / 2, bar_y, bar_w, TIMER_BAR_H),
			Color(0.15, 0.15, 0.15))
		## 进度（从绿到红）
		var fill_color = Color(0.3, 0.9, 0.4).lerp(Color(0.9, 0.3, 0.3), progress)
		draw_rect(Rect2(slot_x - bar_w / 2, bar_y, bar_w * clampf(progress, 0, 1), TIMER_BAR_H),
			fill_color)

	## 锁定勾号
	if slot["locked"]:
		draw_string(ThemeDB.fallback_font,
			Vector2(slot_x - 10, slot_y + CARD_H + 22),
			"✓", HORIZONTAL_ALIGNMENT_CENTER, 20, 20,
			Color(0.3, 0.9, 0.4))

## 绘制卡牌正面（简化版 — 与 card.gd 一致的视觉风格）
func _draw_card_face(cx: float, cy: float, data: CardData, is_locked: bool) -> void:
	var rect = Rect2(cx - CARD_W / 2, cy, CARD_W, CARD_H)

	## 底色
	if is_locked:
		draw_rect(rect, Color(1.0, 0.98, 0.92))
	else:
		draw_rect(rect, Color(0.95, 0.95, 0.93))

	## 花色颜色
	var suit_color = data.get_suit_color()
	var rank_text = data.get_rank_text()
	var suit_symbol = data.get_suit_symbol()

	## 左上角：点数 + 花色
	draw_string(ThemeDB.fallback_font,
		Vector2(rect.position.x + 12, rect.position.y + 32),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, suit_color)
	draw_string(ThemeDB.fallback_font,
		Vector2(rect.position.x + 12, rect.position.y + 56),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, suit_color)

	## 中央大花色
	draw_string(ThemeDB.fallback_font,
		Vector2(cx - 18, cy + CARD_H / 2 + 15),
		suit_symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 50, suit_color)

	## 右下角
	draw_string(ThemeDB.fallback_font,
		Vector2(rect.end.x - 35, rect.end.y - 12),
		rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, suit_color)

	## 增强标记
	if data.enhancement != CardData.Enhancement.NONE:
		var badge_text: String = ""
		var badge_color: Color = Color.WHITE
		match data.enhancement:
			CardData.Enhancement.FOIL:
				badge_text = "✦"
				badge_color = Color(0.65, 0.75, 0.9)
			CardData.Enhancement.HOLOGRAPHIC:
				badge_text = "◈"
				badge_color = Color(0.5, 0.8, 1.0)
			CardData.Enhancement.POLYCHROME:
				badge_text = "◆"
				badge_color = Color(0.85, 0.5, 0.95)
		if badge_text != "":
			draw_string(ThemeDB.fallback_font,
				Vector2(rect.end.x - 22, rect.position.y + 26),
				badge_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, badge_color)

## 绘制卡牌背面
func _draw_card_back(cx: float, cy: float) -> void:
	var rect = Rect2(cx - CARD_W / 2, cy, CARD_W, CARD_H)
	draw_rect(rect, Color(0.15, 0.2, 0.35))
	draw_rect(rect, Color(0.3, 0.35, 0.5), false, 2.0)
	## 背面纹饰 — 太极图案用简单十字
	var mid_x = cx
	var mid_y = cy + CARD_H / 2
	draw_string(ThemeDB.fallback_font,
		Vector2(mid_x - 12, mid_y + 10),
		"☰", HORIZONTAL_ALIGNMENT_CENTER, 24, 28,
		Color(0.4, 0.45, 0.6, 0.5))
