## tarot_effect.gd
## 法宝牌效果处理器 V0.085 — 适配26种新TarotEffect枚举
## 静态函数处理所有法宝牌效果，返回结果描述
class_name TarotEffectProcessor
extends RefCounted

## 执行法宝牌效果
## 返回 { "message": String, "color": Color }
static func apply(tarot: TarotData, selected_cards: Array,
		hand_ref: Node2D, consumable_slot_ref: Node2D, deck_ref: Node = null) -> Dictionary:

	var result := {"message": "", "color": Color(0.7, 0.35, 0.75)}
	var loc = Loc.i()

	match tarot.effect:
		## ===== 神器效果 (Relic) =====
		TarotData.TarotEffect.CHANGE_SUIT_RANDOM:
			if selected_cards.size() >= 1:
				var card = selected_cards[0]
				var suits = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS,
							CardData.Suit.CLUBS, CardData.Suit.SPADES]
				suits.erase(card.card_data.suit)
				card.card_data.suit = suits[randi() % suits.size()]
				card.is_selected = false
				card.queue_redraw()
				result["message"] = "🎩 " + loc.t("Changed to") + " " + card.card_data.get_suit_symbol() + "!"

		TarotData.TarotEffect.CHANGE_SUIT_SPADES:
			result = _change_suit(selected_cards, CardData.Suit.SPADES, "♠", loc)

		TarotData.TarotEffect.CHANGE_SUIT_HEARTS:
			result = _change_suit(selected_cards, CardData.Suit.HEARTS, "♥", loc)

		TarotData.TarotEffect.CHANGE_SUIT_DIAMONDS:
			result = _change_suit(selected_cards, CardData.Suit.DIAMONDS, "♦", loc)

		TarotData.TarotEffect.CHANGE_SUIT_CLUBS:
			result = _change_suit(selected_cards, CardData.Suit.CLUBS, "♣", loc)

		TarotData.TarotEffect.DESTROY_CARD:
			if selected_cards.size() >= 1:
				var card = selected_cards[0]
				var name_text = card.card_data.get_display_name()
				hand_ref.cards_in_hand.erase(card)
				card.queue_free()
				hand_ref._arrange_cards()
				hand_ref.hand_changed.emit()
				result["message"] = "💀 " + loc.t("Destroyed") + " " + name_text + "!"
				result["color"] = Color(0.9, 0.3, 0.3)

		TarotData.TarotEffect.COPY_TO_DECK:
			if selected_cards.size() >= 1:
				var src = selected_cards[0]
				var new_data = CardData.new()
				new_data.suit = src.card_data.suit
				new_data.rank = src.card_data.rank
				hand_ref.add_card(new_data, true)
				result["message"] = "🪞 " + loc.t("Copied") + " " + src.card_data.get_display_name() + "!"

		TarotData.TarotEffect.COPY_LEFT_TO_RIGHT:
			if selected_cards.size() >= 2:
				var left_idx = hand_ref.cards_in_hand.find(selected_cards[0])
				var right_idx = hand_ref.cards_in_hand.find(selected_cards[1])
				var src_card: Node2D
				var dst_card: Node2D
				if left_idx < right_idx:
					dst_card = selected_cards[0]
					src_card = selected_cards[1]
				else:
					dst_card = selected_cards[1]
					src_card = selected_cards[0]
				dst_card.card_data.suit = src_card.card_data.suit
				dst_card.card_data.rank = src_card.card_data.rank
				dst_card.is_selected = false
				src_card.is_selected = false
				dst_card.queue_redraw()
				src_card.queue_redraw()
				result["message"] = "⚖️ " + loc.t("Transformed to") + " " + src_card.card_data.get_display_name() + "!"

		TarotData.TarotEffect.GAIN_MONEY:
			GameState.money += 5
			result["message"] = "💰 " + loc.t(tarot.tarot_name) + " +$5!"
			result["color"] = Color(0.95, 0.8, 0.2)

		## ===== 增强效果（由 main.gd 直接处理 ADD_ENHANCEMENT_FOIL/HOLO/POLY）=====
		## ADD_ENHANCEMENT_FOIL, ADD_ENHANCEMENT_HOLO, ADD_ENHANCEMENT_POLY
		## 这三个在 main.gd _on_tarot_used() 中直接处理，不会到达这里

		## ===== 灵印效果 =====
		TarotData.TarotEffect.ADD_SEAL_AZURE_DRAGON:
			result = _add_seal(selected_cards, CardData.Seal.AZURE_DRAGON, "🐉", loc)

		TarotData.TarotEffect.ADD_SEAL_VERMILLION_BIRD:
			result = _add_seal(selected_cards, CardData.Seal.VERMILLION_BIRD, "🐦", loc)

		TarotData.TarotEffect.ADD_SEAL_WHITE_TIGER:
			result = _add_seal(selected_cards, CardData.Seal.WHITE_TIGER, "🐯", loc)

		TarotData.TarotEffect.ADD_SEAL_BLACK_TORTOISE:
			result = _add_seal(selected_cards, CardData.Seal.BLACK_TORTOISE, "🐢", loc)

		## ===== 阵法效果 (Formation) =====
		TarotData.TarotEffect.CONVERT_ADD_TO_MULT:
			## 诛仙阵：将所有 +Mult 异兽转为 ×Mult（由 joker_effect 检查）
			result["message"] = "⚔️ " + loc.t(tarot.tarot_name) + "! " + loc.t("+Mult → ×Mult")
			result["color"] = Color(0.85, 0.25, 0.25)

		TarotData.TarotEffect.DISABLE_HAND_TYPES:
			## 十绝阵：禁用2种牌型，其余×2 Chips
			result["message"] = "🚫 " + loc.t(tarot.tarot_name) + "! " + loc.t("2 hand types disabled, rest ×2 Chips")
			result["color"] = Color(0.85, 0.25, 0.25)

		TarotData.TarotEffect.SHOP_DISCOUNT:
			## 万仙阵：商店半价
			result["message"] = "🏪 " + loc.t(tarot.tarot_name) + "! " + loc.t("Shop prices halved")
			result["color"] = Color(0.85, 0.25, 0.25)

		TarotData.TarotEffect.ADD_DISCARDS:
			## 九曲黄河阵：+3弃牌
			GameState.discards_remaining += 3
			result["message"] = "🌊 " + loc.t(tarot.tarot_name) + "! +3 " + loc.t("Discards")
			result["color"] = Color(0.85, 0.25, 0.25)

		TarotData.TarotEffect.BOOST_SUIT_HEARTS:
			## 红水阵：♥ +30 Chips +4 Mult
			result["message"] = "❤️ " + loc.t(tarot.tarot_name) + "! ♥ +30C +4M"
			result["color"] = Color(0.85, 0.25, 0.25)

		TarotData.TarotEffect.GENERATE_ARTIFACTS:
			## 天绝阵：生成2张法宝
			var empty = consumable_slot_ref.get_empty_slots()
			var to_add = mini(2, empty)
			if to_add <= 0:
				result["message"] = "🔮 " + loc.t("No empty slots!")
				result["color"] = Color(0.9, 0.3, 0.3)
			else:
				var new_tarots = TarotDatabase.get_random_tarots(to_add)
				var names: PackedStringArray = []
				for t in new_tarots:
					consumable_slot_ref.add_tarot(t)
					names.append(loc.t(t.tarot_name))
				result["message"] = "🔮 " + loc.t("Created") + " " + ", ".join(names) + "!"

		TarotData.TarotEffect.GENERATE_CONSTELLATIONS:
			## 地烈阵：生成2张星宿
			var empty = consumable_slot_ref.get_empty_slots()
			var to_add = mini(2, empty)
			if to_add <= 0:
				result["message"] = "⭐ " + loc.t("No empty slots!")
				result["color"] = Color(0.9, 0.3, 0.3)
			else:
				var new_planets = PlanetDatabase.get_random_planets(to_add)
				var names: PackedStringArray = []
				for p in new_planets:
					consumable_slot_ref.add_planet(p)
					names.append(loc.t(p.planet_name))
				result["message"] = "⭐ " + loc.t("Created") + " " + ", ".join(names) + "!"
				result["color"] = Color(0.2, 0.6, 0.95)

		TarotData.TarotEffect.LEVEL_UP_HAND_TYPE:
			## 风吼阵：随机牌型升级×2
			var types = PokerHand.HandType.values()
			var random_type = types[randi() % types.size()]
			HandLevel.planet_level_up(random_type, 20, 2)
			HandLevel.planet_level_up(random_type, 20, 2)
			var hname = PokerHand.get_hand_name(random_type)
			var lvl = HandLevel.get_level_info(random_type)["level"]
			result["message"] = "🎰 " + loc.t(hname) + " → Lv." + str(lvl) + "!"
			result["color"] = Color(0.95, 0.8, 0.2)
			result["level_up"] = {"hand_name": hname, "level": lvl}

		TarotData.TarotEffect.BOOST_SUIT_CLUBS:
			## 寒冰阵：♣ +30 Chips +4 Mult
			result["message"] = "♣️ " + loc.t(tarot.tarot_name) + "! ♣ +30C +4M"
			result["color"] = Color(0.85, 0.25, 0.25)

		TarotData.TarotEffect.BOOST_ALL_CARDS:
			## 落魂阵：全手牌 +2 Mult
			result["message"] = "👻 " + loc.t(tarot.tarot_name) + "! " + loc.t("All cards +2 Mult")
			result["color"] = Color(0.85, 0.25, 0.25)

	return result


## 批量改花色
static func _change_suit(cards: Array, new_suit: int, symbol: String, loc: Loc) -> Dictionary:
	var changed = 0
	for card in cards:
		card.card_data.suit = new_suit
		card.is_selected = false
		card.queue_redraw()
		changed += 1
	return {
		"message": loc.t("Changed") + " " + str(changed) + " " + loc.t("card(s) to") + " " + symbol + "!",
		"color": Color(0.7, 0.35, 0.75),
	}


## 添加灵印
static func _add_seal(cards: Array, seal: int, emoji: String, loc: Loc) -> Dictionary:
	if cards.size() < 1:
		return {"message": "", "color": Color(0.7, 0.35, 0.75)}
	var card = cards[0]
	card.card_data.seal = seal
	card.is_selected = false
	card.queue_redraw()
	## 使用实例方法获取印名
	var seal_name = card.card_data.get_seal_name()
	return {
		"message": emoji + " " + loc.t(seal_name) + "! " + card.card_data.get_display_name(),
		"color": Color(0.3, 0.8, 0.6),
	}
