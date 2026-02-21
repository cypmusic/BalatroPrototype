## tarot_effect.gd
## 法宝牌效果处理器 V0.086 — 适配36种TarotEffect枚举（含幽冥牌）
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

		## ===== 幽冥效果 (Specter) =====

		TarotData.TarotEffect.SPECTER_TRANSFORM_FACE:
			## 招魂幡：销毁1随机手牌→生成3张增强人头牌
			if hand_ref and hand_ref.cards_in_hand.size() > 0:
				var victim = hand_ref.cards_in_hand[randi() % hand_ref.cards_in_hand.size()]
				var victim_name = victim.card_data.get_display_name()
				hand_ref.cards_in_hand.erase(victim)
				victim.queue_free()
				var faces = [CardData.Rank.JACK, CardData.Rank.QUEEN, CardData.Rank.KING]
				var enhancements = [CardData.Enhancement.FOIL, CardData.Enhancement.HOLOGRAPHIC, CardData.Enhancement.POLYCHROME]
				for _i in range(3):
					var new_data = CardData.new()
					new_data.suit = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS,
									CardData.Suit.CLUBS, CardData.Suit.SPADES][randi() % 4]
					new_data.rank = faces[randi() % faces.size()]
					new_data.enhancement = enhancements[randi() % enhancements.size()]
					hand_ref.add_card(new_data, true)
				hand_ref._arrange_cards()
				hand_ref.hand_changed.emit()
				result["message"] = "👻 " + loc.t("Destroyed") + " " + victim_name + " → +3 " + loc.t("enhanced face cards") + "!"
				result["color"] = Color(0.15, 0.12, 0.3)

		TarotData.TarotEffect.SPECTER_TRANSFORM_NUMBER:
			## 生死簿：销毁1随机手牌→生成4张增强数字牌
			if hand_ref and hand_ref.cards_in_hand.size() > 0:
				var victim = hand_ref.cards_in_hand[randi() % hand_ref.cards_in_hand.size()]
				var victim_name = victim.card_data.get_display_name()
				hand_ref.cards_in_hand.erase(victim)
				victim.queue_free()
				var numbers = [CardData.Rank.TWO, CardData.Rank.THREE, CardData.Rank.FOUR,
							CardData.Rank.FIVE, CardData.Rank.SIX, CardData.Rank.SEVEN,
							CardData.Rank.EIGHT, CardData.Rank.NINE, CardData.Rank.TEN]
				var enhancements = [CardData.Enhancement.FOIL, CardData.Enhancement.HOLOGRAPHIC, CardData.Enhancement.POLYCHROME]
				for _i in range(4):
					var new_data = CardData.new()
					new_data.suit = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS,
									CardData.Suit.CLUBS, CardData.Suit.SPADES][randi() % 4]
					new_data.rank = numbers[randi() % numbers.size()]
					new_data.enhancement = enhancements[randi() % enhancements.size()]
					hand_ref.add_card(new_data, true)
				hand_ref._arrange_cards()
				hand_ref.hand_changed.emit()
				result["message"] = "📖 " + loc.t("Destroyed") + " " + victim_name + " → +4 " + loc.t("enhanced number cards") + "!"
				result["color"] = Color(0.15, 0.12, 0.3)

		TarotData.TarotEffect.SPECTER_BATCH_SUIT:
			## 六道轮回：手中所有牌变同一随机花色
			if hand_ref and hand_ref.cards_in_hand.size() > 0:
				var target_suit = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS,
								CardData.Suit.CLUBS, CardData.Suit.SPADES][randi() % 4]
				for card in hand_ref.cards_in_hand:
					card.card_data.suit = target_suit
					card.queue_redraw()
				var suit_data = CardData.new()
				suit_data.suit = target_suit
				var symbol = suit_data.get_suit_symbol()
				result["message"] = "🔄 " + loc.t("All cards became") + " " + symbol + "!"
				result["color"] = Color(0.15, 0.12, 0.3)

		TarotData.TarotEffect.SPECTER_BATCH_RANK:
			## 夺舍：手中所有牌变同一随机点数，手牌上限-1
			if hand_ref and hand_ref.cards_in_hand.size() > 0:
				var ranks = CardData.Rank.values()
				var target_rank = ranks[randi() % ranks.size()]
				for card in hand_ref.cards_in_hand:
					card.card_data.rank = target_rank
					card.queue_redraw()
				GameState.hand_size_modifier -= 1
				result["message"] = "💀 " + loc.t("All cards became same rank") + "! " + loc.t("Hand size") + " -1"
				result["color"] = Color(0.15, 0.12, 0.3)

		TarotData.TarotEffect.SPECTER_CREATE_LEGEND:
			## 封神：创建1张传说级异兽牌（由main.gd处理异兽栏位逻辑）
			result["message"] = "⭐ " + loc.t("Deification") + "! " + loc.t("A Legendary Beast appears!")
			result["color"] = Color(0.95, 0.75, 0.2)
			result["create_legendary"] = true

		TarotData.TarotEffect.SPECTER_UPGRADE_ALL:
			## 天劫：所有牌型等级+1
			var types = PokerHand.HandType.values()
			for ht in types:
				HandLevel.planet_level_up(ht, 20, 1)
			result["message"] = "⚡ " + loc.t("Heavenly Tribulation") + "! " + loc.t("All hand types") + " +1!"
			result["color"] = Color(0.95, 0.75, 0.2)

		TarotData.TarotEffect.SPECTER_DESTROY_FOR_GOLD:
			## 焚身：销毁5张随机手牌→$20
			if hand_ref:
				var destroyed = 0
				var to_destroy = mini(5, hand_ref.cards_in_hand.size())
				for _i in range(to_destroy):
					if hand_ref.cards_in_hand.is_empty():
						break
					var idx = randi() % hand_ref.cards_in_hand.size()
					var card = hand_ref.cards_in_hand[idx]
					hand_ref.cards_in_hand.erase(card)
					card.queue_free()
					destroyed += 1
				if destroyed > 0:
					hand_ref._arrange_cards()
					hand_ref.hand_changed.emit()
				GameState.money += 20
				result["message"] = "🔥 " + loc.t("Destroyed") + " " + str(destroyed) + " " + loc.t("cards") + " → +$20!"
				result["color"] = Color(0.15, 0.12, 0.3)

		TarotData.TarotEffect.SPECTER_JOKER_PHANTOM:
			## 离魂术：随机异兽获得虚相，手牌上限-1（由main.gd处理异兽逻辑）
			GameState.hand_size_modifier -= 1
			result["message"] = "👁️ " + loc.t("Soul Separation") + "! " + loc.t("Hand size") + " -1"
			result["color"] = Color(0.15, 0.12, 0.3)
			result["joker_phantom"] = true

		TarotData.TarotEffect.SPECTER_DUPLICATE_CARDS:
			## 分身术：选1牌→牌组中创建2张副本
			if selected_cards.size() >= 1:
				var src = selected_cards[0]
				for _i in range(2):
					var new_data = CardData.new()
					new_data.suit = src.card_data.suit
					new_data.rank = src.card_data.rank
					new_data.enhancement = src.card_data.enhancement
					new_data.seal = src.card_data.seal
					hand_ref.add_card(new_data, true)
				result["message"] = "🔮 " + loc.t("Cloned") + " " + src.card_data.get_display_name() + " ×2!"
				result["color"] = Color(0.15, 0.12, 0.3)

		TarotData.TarotEffect.SPECTER_JOKER_POLY_PURGE:
			## 阴阳眼：选中异兽获得多彩，销毁其余（由main.gd处理异兽栏位逻辑）
			result["message"] = "👁️ " + loc.t("Yin-Yang Eyes") + "! " + loc.t("Polychrome granted, others destroyed")
			result["color"] = Color(0.15, 0.12, 0.3)
			result["joker_poly_purge"] = true

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
