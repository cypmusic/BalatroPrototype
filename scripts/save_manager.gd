## save_manager.gd
## 存档管理器 V1 — AutoLoad 单例
## 在盲注选择阶段自动存档，支持继续游戏
## Project Settings → AutoLoad 注册为 "SaveManager"
extends Node

const SAVE_PATH: String = "user://savegame.json"

## ========== 存档 ==========

## 存档时机：进入盲注选择界面时（回合之间的安全点）
func save_game(main_ref: Node2D) -> void:
	var data: Dictionary = {}

	## 1. 版本 + 游戏进程
	data["save_version"] = GameConfig.VERSION
	data["current_ante"] = GameState.current_ante
	data["blind_index"] = GameState.blind_index
	data["money"] = GameState.money
	data["used_boss_names"] = GameState.used_boss_names.duplicate()

	## 2. ante_boss（当前 Ante 的 Boss 信息）
	if GameState.ante_boss != null:
		data["ante_boss"] = {
			"name": GameState.ante_boss.name,
			"effect": int(GameState.ante_boss.effect),
			"description": GameState.ante_boss.description,
			"emoji": GameState.ante_boss.emoji,
		}
	else:
		data["ante_boss"] = null

	## 3. 牌型升级系统（HandLevel 的全部状态）
	var hand_levels: Dictionary = {}
	for type in PokerHand.HandType.values():
		hand_levels[str(type)] = {
			"level": HandLevel.levels.get(type, 1),
			"play_count": HandLevel.play_counts.get(type, 0),
			"planet_chips": HandLevel.planet_bonus_chips.get(type, 0),
			"planet_mult": HandLevel.planet_bonus_mult.get(type, 0),
		}
	data["hand_levels"] = hand_levels

	## 4. 持有的小丑牌（保存 id 列表）
	var joker_ids: Array = []
	for joker in main_ref.joker_slot.get_owned_jokers():
		joker_ids.append(joker.id)
	data["joker_ids"] = joker_ids

	## 5. 持有的消耗品（保存 type + id）
	var consumables: Array = []
	for item in main_ref.consumable_slot.get_held_items():
		if item["type"] == "planet":
			consumables.append({"type": "planet", "id": item["data"].id})
		else:
			consumables.append({"type": "tarot", "id": item["data"].id})
	data["consumables"] = consumables

	## 6. 牌组状态（塔罗牌可能改过花色/销毁过牌）
	var deck_cards: Array = []
	for card_data in main_ref.deck.cards:
		deck_cards.append({"suit": int(card_data.suit), "rank": int(card_data.rank)})
	data["deck_cards"] = deck_cards

	## 7. 时间戳
	data["save_time"] = Time.get_datetime_string_from_system()

	## 写入
	var json_str = JSON.stringify(data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		print("[SaveManager] Saved — Ante %d, Blind %d, $%d" % [
			data["current_ante"], data["blind_index"], data["money"]])
	else:
		push_error("[SaveManager] Save failed: " + str(FileAccess.get_open_error()))


## ========== 读档 ==========

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game(main_ref: Node2D) -> bool:
	if not has_save():
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[SaveManager] Cannot open save file")
		return false

	var json_str = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_str) != OK:
		push_error("[SaveManager] Parse error: " + json.get_error_message())
		return false

	var data: Dictionary = json.data
	print("[SaveManager] Loading save (version: %s)" % data.get("save_version", "?"))

	## 1. 游戏进程
	GameState.current_ante = int(data.get("current_ante", 1))
	GameState.blind_index = int(data.get("blind_index", 0))
	GameState._money = int(data.get("money", GameConfig.STARTING_MONEY))
	GameState.used_boss_names = data.get("used_boss_names", [])

	## 2. ante_boss
	var boss_data = data.get("ante_boss")
	if boss_data != null and boss_data is Dictionary:
		GameState.ante_boss = BlindData.BossBlind.new(
			str(boss_data.get("name", "")),
			int(boss_data.get("effect", 0)) as BlindData.BossEffect,
			str(boss_data.get("description", "")),
			str(boss_data.get("emoji", "")))
	else:
		GameState.ante_boss = null

	## 3. 牌型升级
	HandLevel.reset()
	var hand_levels = data.get("hand_levels", {})
	for type_str in hand_levels:
		var t: int = int(type_str)
		var info: Dictionary = hand_levels[type_str]
		HandLevel.levels[t] = int(info.get("level", 1))
		HandLevel.play_counts[t] = int(info.get("play_count", 0))
		HandLevel.planet_bonus_chips[t] = int(info.get("planet_chips", 0))
		HandLevel.planet_bonus_mult[t] = int(info.get("planet_mult", 0))

	## 4. 小丑牌
	while main_ref.joker_slot.get_owned_jokers().size() > 0:
		main_ref.joker_slot.remove_joker(0)
	var all_jokers = JokerDatabase.get_all_jokers()
	for jid in data.get("joker_ids", []):
		for j in all_jokers:
			if j.id == jid:
				main_ref.joker_slot.add_joker(j)
				break

	## 5. 消耗品
	main_ref.consumable_slot.clear_all()
	var all_planets = PlanetDatabase.get_all_planets()
	var all_tarots = TarotDatabase.get_all_tarots()
	for item in data.get("consumables", []):
		if item.get("type") == "planet":
			for p in all_planets:
				if p.id == item.get("id"):
					main_ref.consumable_slot.add_planet(p)
					break
		elif item.get("type") == "tarot":
			for t in all_tarots:
				if t.id == item.get("id"):
					main_ref.consumable_slot.add_tarot(t)
					break

	## 6. 牌组
	var deck_cards = data.get("deck_cards", [])
	if deck_cards.size() > 0:
		main_ref.deck.cards.clear()
		for cd in deck_cards:
			var card = CardData.new()
			card.suit = int(cd.get("suit", 0))
			card.rank = int(cd.get("rank", 1))
			main_ref.deck.cards.append(card)
	main_ref.deck.shuffle()

	## 7. 清理动画/交互状态
	GameState.is_score_animating = false
	GameState.is_discarding = false
	GameState.is_round_ended = false
	GameState.is_game_won = false

	print("[SaveManager] Loaded — Ante %d, Blind %d, $%d, %d jokers" % [
		GameState.current_ante, GameState.blind_index,
		GameState.money, main_ref.joker_slot.get_owned_jokers().size()])
	return true


## ========== 删档 ==========

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveManager] Save deleted")


## ========== 存档摘要（标题菜单显示用）==========

func get_save_info() -> Dictionary:
	if not has_save():
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}

	var json_str = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_str) != OK:
		return {}

	var d: Dictionary = json.data
	return {
		"ante": int(d.get("current_ante", 1)),
		"blind_index": int(d.get("blind_index", 0)),
		"money": int(d.get("money", 0)),
		"joker_count": d.get("joker_ids", []).size(),
		"save_time": d.get("save_time", ""),
	}
