## hand.gd
## 手牌管理器 V11 - 自动整理 + 洗牌动画
extends Node2D

signal hand_changed()

const HAND_Y_POSITION: float = 700.0
const CARD_SPACING: float = 150.0
const MAX_HAND_SIZE: int = 8

var cards_in_hand: Array[Node2D] = []
var draw_pile_source: Vector2 = Vector2(800, 1000)

var dragging_card: Node2D = null

## 排序记忆
enum SortMode { RANK, SUIT }
var current_sort_mode: int = SortMode.RANK

## 自动整理延迟
var auto_sort_pending: bool = false
var auto_sort_timer: float = 0.0
var auto_sort_delay: float = 0.45  ## 动态设置，发牌后等待更长

## 洗牌动画
var shuffle_animating: bool = false
var shuffle_cards: Array = []  ## [{node, from, to, timer, delay, arc_height}]
const SHUFFLE_DURATION: float = 0.4
const SHUFFLE_ARC_HEIGHT: float = -40.0  ## 向上弧线高度

func _ready() -> void:
	pass

func add_card(data: CardData, animate: bool = true) -> Node2D:
	var card_node = Node2D.new()
	var card_script = load("res://scripts/card.gd")
	card_node.set_script(card_script)
	add_child(card_node)
	card_node.setup(data)
	cards_in_hand.append(card_node)

	card_node.card_clicked.connect(_on_card_clicked)
	card_node.card_drag_started.connect(_on_card_drag_started)
	card_node.card_drag_ended.connect(_on_card_drag_ended)

	_arrange_cards()

	if animate:
		var local_source = draw_pile_source - global_position
		var delay = (cards_in_hand.size() - 1) * 0.1
		card_node.animate_from(local_source, delay)

	return card_node

func _arrange_cards() -> void:
	var count = cards_in_hand.size()
	if count == 0:
		return

	var spacing = CARD_SPACING
	var total_width = (count - 1) * spacing
	var max_width = 1200.0
	if total_width > max_width:
		spacing = max_width / (count - 1) if count > 1 else 0
		total_width = max_width

	var start_x = -total_width / 2.0

	for i in range(count):
		var card = cards_in_hand[i]
		card.base_position = Vector2(start_x + i * spacing, HAND_Y_POSITION)
		if not card.is_dragging and not card.is_animating and not card.is_exiting:
			if card.is_selected:
				card.position = card.base_position + Vector2(0, card.SELECT_OFFSET)
			else:
				card.position = card.base_position
		card.z_index = i

func _process(delta: float) -> void:
	## 洗牌弧线动画
	if shuffle_animating:
		var all_done = true
		for sc in shuffle_cards:
			sc["timer"] += delta
			var t = clampf((sc["timer"] - sc["delay"]) / SHUFFLE_DURATION, 0.0, 1.0)
			if t < 1.0:
				all_done = false
			## ease-in-out cubic（更丝滑）
			var ease_t: float
			if t < 0.5:
				ease_t = 4.0 * t * t * t
			else:
				ease_t = 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0
			if is_instance_valid(sc["node"]) and not sc["node"].is_dragging:
				## X/Y 线性插值 + Y 弧线偏移
				var base_pos = sc["from"].lerp(sc["to"], ease_t)
				## 抛物线弧线：在 t=0.5 时达到最大高度
				var arc = sc["arc_height"] * 4.0 * t * (1.0 - t)
				sc["node"].position = Vector2(base_pos.x, base_pos.y + arc)
		if all_done:
			shuffle_animating = false
			shuffle_cards.clear()
			_arrange_cards()
		return

	## 自动整理延迟
	if auto_sort_pending:
		auto_sort_timer += delta
		if auto_sort_timer >= auto_sort_delay:
			auto_sort_pending = false
			_animated_sort()
			hand_changed.emit()
		return

	## 拖拽排序
	if dragging_card == null:
		return

	var drag_x = dragging_card.position.x
	var current_index = cards_in_hand.find(dragging_card)
	if current_index < 0:
		return

	if current_index > 0:
		var left_card = cards_in_hand[current_index - 1]
		if drag_x < left_card.base_position.x:
			_swap_cards(current_index, current_index - 1)

	if current_index < cards_in_hand.size() - 1:
		var right_card = cards_in_hand[current_index + 1]
		if drag_x > right_card.base_position.x:
			_swap_cards(current_index, current_index + 1)

func _swap_cards(index_a: int, index_b: int) -> void:
	var temp = cards_in_hand[index_a]
	cards_in_hand[index_a] = cards_in_hand[index_b]
	cards_in_hand[index_b] = temp
	_arrange_cards()

func _on_card_clicked(_card_node: Node2D) -> void:
	hand_changed.emit()

func _on_card_drag_started(card_node: Node2D) -> void:
	dragging_card = card_node

func _on_card_drag_ended(card_node: Node2D) -> void:
	dragging_card = null
	_arrange_cards()
	var idx = cards_in_hand.find(card_node)
	if idx >= 0:
		card_node.z_index = idx
	hand_changed.emit()

func sort_by_suit() -> void:
	current_sort_mode = SortMode.SUIT
	_animated_sort()
	hand_changed.emit()

func sort_by_rank() -> void:
	current_sort_mode = SortMode.RANK
	_animated_sort()
	hand_changed.emit()

## 切换排序模式（合并按钮用）
func toggle_sort() -> void:
	if current_sort_mode == SortMode.RANK:
		current_sort_mode = SortMode.SUIT
	else:
		current_sort_mode = SortMode.RANK
	_animated_sort()
	hand_changed.emit()

## 花色排序优先级：♠=0, ♥=1, ♣=2, ♦=3
func _suit_order(suit: int) -> int:
	match suit:
		3: return 0  ## SPADES
		0: return 1  ## HEARTS
		2: return 2  ## CLUBS
		1: return 3  ## DIAMONDS
		_: return suit

## 数字排序优先级：A最大(排最左), 然后K, Q, J, 10...2
func _rank_order(rank: int) -> int:
	if rank == 1: return 14  ## ACE 排最前
	return rank  ## K=13, Q=12... 2=2

## 根据当前模式排序（不带动画）
func _apply_sort() -> void:
	if current_sort_mode == SortMode.SUIT:
		cards_in_hand.sort_custom(func(a, b):
			var sa = _suit_order(a.card_data.suit)
			var sb = _suit_order(b.card_data.suit)
			if sa != sb:
				return sa < sb
			return _rank_order(a.card_data.rank) > _rank_order(b.card_data.rank)
		)
	else:
		cards_in_hand.sort_custom(func(a, b):
			var ra = _rank_order(a.card_data.rank)
			var rb = _rank_order(b.card_data.rank)
			if ra != rb:
				return ra > rb
			return _suit_order(a.card_data.suit) < _suit_order(b.card_data.suit)
		)

## 带弧线滑动动画的排序
func _animated_sort() -> void:
	var old_positions: Dictionary = {}
	for card in cards_in_hand:
		old_positions[card] = card.position

	_apply_sort()
	_arrange_cards()

	shuffle_animating = true
	shuffle_cards.clear()
	var move_count = 0
	for i in range(cards_in_hand.size()):
		var card = cards_in_hand[i]
		var new_pos = card.base_position
		if card.is_selected:
			new_pos += Vector2(0, card.SELECT_OFFSET)
		var old_pos = old_positions.get(card, new_pos)
		var dist = old_pos.distance_to(new_pos)
		if dist > 2.0:
			card.position = old_pos
			## 弧线高度根据移动距离缩放
			var arc_h = SHUFFLE_ARC_HEIGHT * clampf(dist / 400.0, 0.3, 1.0)
			shuffle_cards.append({
				"node": card,
				"from": old_pos,
				"to": new_pos,
				"timer": 0.0,
				"delay": move_count * 0.025,
				"arc_height": arc_h,
			})
			move_count += 1
	if shuffle_cards.is_empty():
		shuffle_animating = false

## 请求自动整理（新牌抽入后延迟调用）
func request_auto_sort() -> void:
	auto_sort_pending = true
	auto_sort_timer = 0.0
	## 计算等待时间：最后一张牌的delay + 动画时间 + 小缓冲
	var animating_count = 0
	for card in cards_in_hand:
		if card.is_animating:
			animating_count += 1
	## 入场间隔0.1s × 张数 + 动画0.35s + 缓冲0.1s
	auto_sort_delay = animating_count * 0.1 + 0.45

func get_selected_cards() -> Array[Node2D]:
	var selected: Array[Node2D] = []
	for card in cards_in_hand:
		if card.is_selected:
			selected.append(card)
	return selected

## 移除选中卡牌但不 queue_free，返回卡牌节点列表（用于弃牌动画）
func remove_selected_cards_for_animation() -> Array[Node2D]:
	var removed: Array[Node2D] = []
	for card in cards_in_hand:
		if card.is_selected:
			removed.append(card)

	for card in removed:
		cards_in_hand.erase(card)
		card.is_selected = false

	_arrange_cards()
	hand_changed.emit()
	return removed

## 旧版兼容（直接删除）
func remove_selected_cards() -> Array[Node2D]:
	var removed: Array[Node2D] = []
	for card in cards_in_hand:
		if card.is_selected:
			removed.append(card)

	for card in removed:
		cards_in_hand.erase(card)
		card.queue_free()

	_arrange_cards()
	hand_changed.emit()
	return removed

func get_selection_preview() -> Dictionary:
	var selected = get_selected_cards()
	if selected.is_empty():
		return {}
	return PokerHand.calculate_score(selected)
