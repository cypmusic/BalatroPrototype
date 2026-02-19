## tarot_effect.gd
## 塔罗牌效果处理器 V1 — 从 main.gd 抽取
## 静态函数处理所有塔罗牌效果，返回结果描述
class_name TarotEffectProcessor
extends RefCounted

## 执行塔罗牌效果
## 返回 { "message": String, "color": Color }
static func apply(tarot: TarotData, selected_cards: Array,
		hand_ref: Node2D, consumable_slot_ref: Node2D, deck_ref: Node = null) -> Dictionary:

	var result := {"message": "", "color": Color(0.7, 0.35, 0.75)}
	var loc = Loc.i()

	match tarot.effect:
		TarotData.TarotEffect.COPY_CARD:
			if selected_cards.size() >= 1:
				var src = selected_cards[0]
				var new_data = CardData.new()
				new_data.suit = src.card_data.suit
				new_data.rank = src.card_data.rank
				hand_ref.add_card(new_data, true)
				result["message"] = "🃏 Copied " + src.card_data.get_display_name() + "!"

		TarotData.TarotEffect.RANDOM_SUIT:
			if selected_cards.size() >= 1:
				var card = selected_cards[0]
				var suits = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS,
							CardData.Suit.CLUBS, CardData.Suit.SPADES]
				suits.erase(card.card_data.suit)
				card.card_data.suit = suits[randi() % suits.size()]
				card.is_selected = false
				card.queue_redraw()
				result["message"] = "🎩 Changed to " + card.card_data.get_suit_symbol() + "!"

		TarotData.TarotEffect.CHANGE_TO_HEARTS:
			result = _change_suit(selected_cards, CardData.Suit.HEARTS, "♥")

		TarotData.TarotEffect.CHANGE_TO_SPADES:
			result = _change_suit(selected_cards, CardData.Suit.SPADES, "♠")

		TarotData.TarotEffect.CHANGE_TO_CLUBS:
			result = _change_suit(selected_cards, CardData.Suit.CLUBS, "♣")

		TarotData.TarotEffect.CHANGE_TO_DIAMONDS:
			result = _change_suit(selected_cards, CardData.Suit.DIAMONDS, "♦")

		TarotData.TarotEffect.DESTROY_CARD:
			if selected_cards.size() >= 1:
				var card = selected_cards[0]
				var name_text = card.card_data.get_display_name()
				hand_ref.cards_in_hand.erase(card)
				card.queue_free()
				hand_ref._arrange_cards()
				hand_ref.hand_changed.emit()
				result["message"] = "💀 Destroyed " + name_text + "!"
				result["color"] = Color(0.9, 0.3, 0.3)

		TarotData.TarotEffect.GAIN_MONEY:
			GameState.money += 5
			result["message"] = "🔮 " + loc.t("The Hermit") + " +$5!"
			result["color"] = Color(0.95, 0.8, 0.2)

		TarotData.TarotEffect.CLONE_CARD:
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
				result["message"] = "⚖️ Card transformed to " + src_card.card_data.get_display_name() + "!"

		TarotData.TarotEffect.SPAWN_TAROT:
			var empty = consumable_slot_ref.get_empty_slots()
			var to_add = mini(2, empty)
			if to_add <= 0:
				result["message"] = "🌎 " + loc.t("No empty slots!")
				result["color"] = Color(0.9, 0.3, 0.3)
			else:
				var new_tarots = TarotDatabase.get_random_tarots(to_add)
				var names: PackedStringArray = []
				for t in new_tarots:
					consumable_slot_ref.add_tarot(t)
					names.append(t.tarot_name)
				result["message"] = "🌎 Created " + ", ".join(names) + "!"

		TarotData.TarotEffect.SPAWN_PLANET:
			var empty = consumable_slot_ref.get_empty_slots()
			var to_add = mini(2, empty)
			if to_add <= 0:
				result["message"] = "☀️ " + loc.t("No empty slots!")
				result["color"] = Color(0.9, 0.3, 0.3)
			else:
				var new_planets = PlanetDatabase.get_random_planets(to_add)
				var names: PackedStringArray = []
				for p in new_planets:
					consumable_slot_ref.add_planet(p)
					names.append(p.planet_name)
				result["message"] = "☀️ Created " + ", ".join(names) + "!"
				result["color"] = Color(0.2, 0.6, 0.95)

		TarotData.TarotEffect.RANDOM_LEVEL_UP:
			var types = PokerHand.HandType.values()
			var random_type = types[randi() % types.size()]
			HandLevel.planet_level_up(random_type, 20, 2)
			HandLevel.planet_level_up(random_type, 20, 2)
			var hname = PokerHand.get_hand_name(random_type)
			var lvl = HandLevel.get_level_info(random_type)["level"]
			result["message"] = "🎰 " + loc.t(hname) + " → Lv." + str(lvl) + "!"
			result["color"] = Color(0.95, 0.8, 0.2)
			result["level_up"] = {"hand_name": hname, "level": lvl}

	return result


## 批量改花色
static func _change_suit(cards: Array, new_suit: int, symbol: String) -> Dictionary:
	var changed = 0
	for card in cards:
		card.card_data.suit = new_suit
		card.is_selected = false
		card.queue_redraw()
		changed += 1
	return {
		"message": "Changed " + str(changed) + " card(s) to " + symbol + "!",
		"color": Color(0.7, 0.35, 0.75),
	}
