## tarot_database.gd
## 塔罗牌数据库 - 12 张塔罗牌
class_name TarotDatabase
extends RefCounted

static func get_all_tarots() -> Array[TarotData]:
	var tarots: Array[TarotData] = []

	## 1. The Fool - 复制 1 张选中手牌
	var t1 = TarotData.new()
	t1.id = "fool"
	t1.tarot_name = "The Fool"
	t1.description = "Copy 1 selected card"
	t1.emoji = "🃏"
	t1.effect = TarotData.TarotEffect.COPY_CARD
	t1.cost = 4
	t1.needs_selection = true
	t1.min_select = 1
	t1.max_select = 1
	tarots.append(t1)

	## 2. The Magician - 随机变花色
	var t2 = TarotData.new()
	t2.id = "magician"
	t2.tarot_name = "The Magician"
	t2.description = "Change 1 card to random suit"
	t2.emoji = "🎩"
	t2.effect = TarotData.TarotEffect.RANDOM_SUIT
	t2.cost = 3
	t2.needs_selection = true
	t2.min_select = 1
	t2.max_select = 1
	tarots.append(t2)

	## 3. The Lovers - ≤3张变♥
	var t3 = TarotData.new()
	t3.id = "lovers"
	t3.tarot_name = "The Lovers"
	t3.description = "Change up to 3 cards to ♥"
	t3.emoji = "💕"
	t3.effect = TarotData.TarotEffect.CHANGE_TO_HEARTS
	t3.cost = 3
	t3.needs_selection = true
	t3.min_select = 1
	t3.max_select = 3
	tarots.append(t3)

	## 4. The Chariot - ≤3张变♠
	var t4 = TarotData.new()
	t4.id = "chariot"
	t4.tarot_name = "The Chariot"
	t4.description = "Change up to 3 cards to ♠"
	t4.emoji = "⚔️"
	t4.effect = TarotData.TarotEffect.CHANGE_TO_SPADES
	t4.cost = 3
	t4.needs_selection = true
	t4.min_select = 1
	t4.max_select = 3
	tarots.append(t4)

	## 5. The Tower - ≤3张变♣
	var t5 = TarotData.new()
	t5.id = "tower"
	t5.tarot_name = "The Tower"
	t5.description = "Change up to 3 cards to ♣"
	t5.emoji = "🗼"
	t5.effect = TarotData.TarotEffect.CHANGE_TO_CLUBS
	t5.cost = 3
	t5.needs_selection = true
	t5.min_select = 1
	t5.max_select = 3
	tarots.append(t5)

	## 6. The Star - ≤3张变♦
	var t6 = TarotData.new()
	t6.id = "star"
	t6.tarot_name = "The Star"
	t6.description = "Change up to 3 cards to ♦"
	t6.emoji = "⭐"
	t6.effect = TarotData.TarotEffect.CHANGE_TO_DIAMONDS
	t6.cost = 3
	t6.needs_selection = true
	t6.min_select = 1
	t6.max_select = 3
	tarots.append(t6)

	## 7. Death - 销毁 1 张选中牌
	var t7 = TarotData.new()
	t7.id = "death"
	t7.tarot_name = "Death"
	t7.description = "Destroy 1 selected card"
	t7.emoji = "💀"
	t7.effect = TarotData.TarotEffect.DESTROY_CARD
	t7.cost = 2
	t7.needs_selection = true
	t7.min_select = 1
	t7.max_select = 1
	tarots.append(t7)

	## 8. The Hermit - 获得 $5
	var t8 = TarotData.new()
	t8.id = "hermit"
	t8.tarot_name = "The Hermit"
	t8.description = "Gain $5"
	t8.emoji = "🔮"
	t8.effect = TarotData.TarotEffect.GAIN_MONEY
	t8.cost = 2
	t8.needs_selection = false
	t8.min_select = 0
	t8.max_select = 0
	tarots.append(t8)

	## 9. Judgement - 左牌变成右牌副本
	var t9 = TarotData.new()
	t9.id = "judgement"
	t9.tarot_name = "Judgement"
	t9.description = "Left card becomes copy of right card"
	t9.emoji = "⚖️"
	t9.effect = TarotData.TarotEffect.CLONE_CARD
	t9.cost = 3
	t9.needs_selection = true
	t9.min_select = 2
	t9.max_select = 2
	tarots.append(t9)

	## 10. The World - 获得2张随机塔罗牌
	var t10 = TarotData.new()
	t10.id = "world"
	t10.tarot_name = "The World"
	t10.description = "Create 2 random Tarot cards"
	t10.emoji = "🌎"
	t10.effect = TarotData.TarotEffect.SPAWN_TAROT
	t10.cost = 4
	t10.needs_selection = false
	t10.min_select = 0
	t10.max_select = 0
	tarots.append(t10)

	## 11. The Sun - 获得2张随机星球牌
	var t11 = TarotData.new()
	t11.id = "sun"
	t11.tarot_name = "The Sun"
	t11.description = "Create 2 random Planet cards"
	t11.emoji = "☀️"
	t11.effect = TarotData.TarotEffect.SPAWN_PLANET
	t11.cost = 4
	t11.needs_selection = false
	t11.min_select = 0
	t11.max_select = 0
	tarots.append(t11)

	## 12. Wheel of Fortune - 随机升级一种牌型2级
	var t12 = TarotData.new()
	t12.id = "wheel"
	t12.tarot_name = "Wheel of Fortune"
	t12.description = "Level up a random hand type ×2"
	t12.emoji = "🎰"
	t12.effect = TarotData.TarotEffect.RANDOM_LEVEL_UP
	t12.cost = 3
	t12.needs_selection = false
	t12.min_select = 0
	t12.max_select = 0
	tarots.append(t12)

	return tarots

static func get_random_tarots(count: int) -> Array[TarotData]:
	var all = get_all_tarots()
	all.shuffle()
	var result: Array[TarotData] = []
	for i in range(mini(count, all.size())):
		result.append(all[i])
	return result
