## planet_database.gd
## 星球牌数据库 - 9 张星球牌，每张对应一种牌型
class_name PlanetDatabase
extends RefCounted

static func get_all_planets() -> Array[PlanetData]:
	var planets: Array[PlanetData] = []

	## 🌑 Moon - High Card（最弱牌型，升级收益较大）
	var p1 = PlanetData.new()
	p1.id = "moon"
	p1.planet_name = "Moon"
	p1.description = "Upgrades High Card"
	p1.emoji = "🌑"
	p1.hand_type = PokerHand.HandType.HIGH_CARD
	p1.cost = 3
	p1.level_chips = 15
	p1.level_mult = 1
	planets.append(p1)

	## ☿ Mercury - Pair
	var p2 = PlanetData.new()
	p2.id = "mercury"
	p2.planet_name = "Mercury"
	p2.description = "Upgrades Pair"
	p2.emoji = "☿"
	p2.hand_type = PokerHand.HandType.PAIR
	p2.cost = 3
	p2.level_chips = 15
	p2.level_mult = 1
	planets.append(p2)

	## ♅ Uranus - Two Pair
	var p3 = PlanetData.new()
	p3.id = "uranus"
	p3.planet_name = "Uranus"
	p3.description = "Upgrades Two Pair"
	p3.emoji = "♅"
	p3.hand_type = PokerHand.HandType.TWO_PAIR
	p3.cost = 3
	p3.level_chips = 20
	p3.level_mult = 1
	planets.append(p3)

	## ♀ Venus - Three of a Kind
	var p4 = PlanetData.new()
	p4.id = "venus"
	p4.planet_name = "Venus"
	p4.description = "Upgrades Three of a Kind"
	p4.emoji = "♀"
	p4.hand_type = PokerHand.HandType.THREE_OF_A_KIND
	p4.cost = 3
	p4.level_chips = 20
	p4.level_mult = 2
	planets.append(p4)

	## ♄ Saturn - Straight
	var p5 = PlanetData.new()
	p5.id = "saturn"
	p5.planet_name = "Saturn"
	p5.description = "Upgrades Straight"
	p5.emoji = "♄"
	p5.hand_type = PokerHand.HandType.STRAIGHT
	p5.cost = 4
	p5.level_chips = 25
	p5.level_mult = 2
	planets.append(p5)

	## ♃ Jupiter - Flush
	var p6 = PlanetData.new()
	p6.id = "jupiter"
	p6.planet_name = "Jupiter"
	p6.description = "Upgrades Flush"
	p6.emoji = "♃"
	p6.hand_type = PokerHand.HandType.FLUSH
	p6.cost = 4
	p6.level_chips = 25
	p6.level_mult = 2
	planets.append(p6)

	## 🌍 Earth - Full House
	var p7 = PlanetData.new()
	p7.id = "earth"
	p7.planet_name = "Earth"
	p7.description = "Upgrades Full House"
	p7.emoji = "🌍"
	p7.hand_type = PokerHand.HandType.FULL_HOUSE
	p7.cost = 4
	p7.level_chips = 25
	p7.level_mult = 2
	planets.append(p7)

	## ♂ Mars - Four of a Kind
	var p8 = PlanetData.new()
	p8.id = "mars"
	p8.planet_name = "Mars"
	p8.description = "Upgrades Four of a Kind"
	p8.emoji = "♂"
	p8.hand_type = PokerHand.HandType.FOUR_OF_A_KIND
	p8.cost = 4
	p8.level_chips = 30
	p8.level_mult = 3
	planets.append(p8)

	## ♆ Neptune - Straight Flush
	var p9 = PlanetData.new()
	p9.id = "neptune"
	p9.planet_name = "Neptune"
	p9.description = "Upgrades Straight Flush"
	p9.emoji = "♆"
	p9.hand_type = PokerHand.HandType.STRAIGHT_FLUSH
	p9.cost = 4
	p9.level_chips = 35
	p9.level_mult = 3
	planets.append(p9)

	return planets

## 获取随机 N 张星球牌（用于商店）
static func get_random_planets(count: int) -> Array[PlanetData]:
	var all = get_all_planets()
	all.shuffle()
	var result: Array[PlanetData] = []
	for i in range(mini(count, all.size())):
		result.append(all[i])
	return result
