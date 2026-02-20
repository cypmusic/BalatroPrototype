## planet_database.gd
## 星宿数据库 V0.085 — 二十八宿，每宿对应一种牌型
## 注意: 需要 poker_hand.gd 中的 HandType 枚举完成扩展后才能正确引用所有28种牌型
class_name PlanetDatabase
extends RefCounted

static func get_all_planets() -> Array[PlanetData]:
	var planets: Array[PlanetData] = []

	## ============================================================
	## 东方青龙七宿 (♠) — 基础牌型
	## ============================================================

	## 角宿 — High Card
	var p = PlanetData.new()
	p.id = "jiao"
	p.planet_name = "Horn Star"
	p.description = "Upgrades High Card"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.HIGH_CARD
	p.cost = 3
	p.level_chips = 15
	p.level_mult = 1
	planets.append(p)

	## 亢宿 — Pair
	p = PlanetData.new()
	p.id = "kang"
	p.planet_name = "Neck Star"
	p.description = "Upgrades Pair"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.PAIR
	p.cost = 3
	p.level_chips = 15
	p.level_mult = 1
	planets.append(p)

	## 氐宿 — Two Pair
	p = PlanetData.new()
	p.id = "di"
	p.planet_name = "Root Star"
	p.description = "Upgrades Two Pair"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.TWO_PAIR
	p.cost = 3
	p.level_chips = 20
	p.level_mult = 1
	planets.append(p)

	## 房宿 — Three of a Kind
	p = PlanetData.new()
	p.id = "fang"
	p.planet_name = "Chamber Star"
	p.description = "Upgrades Three of a Kind"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.THREE_OF_A_KIND
	p.cost = 3
	p.level_chips = 20
	p.level_mult = 2
	planets.append(p)

	## 心宿 — Straight
	p = PlanetData.new()
	p.id = "xin"
	p.planet_name = "Heart Star"
	p.description = "Upgrades Straight"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.STRAIGHT
	p.cost = 4
	p.level_chips = 25
	p.level_mult = 2
	planets.append(p)

	## 尾宿 — Flush
	p = PlanetData.new()
	p.id = "wei_e"
	p.planet_name = "Tail Star"
	p.description = "Upgrades Flush"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.FLUSH
	p.cost = 4
	p.level_chips = 25
	p.level_mult = 2
	planets.append(p)

	## 箕宿 — Full House
	p = PlanetData.new()
	p.id = "ji"
	p.planet_name = "Winnow Star"
	p.description = "Upgrades Full House"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.FULL_HOUSE
	p.cost = 4
	p.level_chips = 25
	p.level_mult = 2
	planets.append(p)

	## ============================================================
	## 北方玄武七宿 (♣) — 中阶牌型
	## ============================================================

	## 斗宿 — Four of a Kind
	p = PlanetData.new()
	p.id = "dou"
	p.planet_name = "Dipper Star"
	p.description = "Upgrades Four of a Kind"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.FOUR_OF_A_KIND
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 牛宿 — Straight Flush
	p = PlanetData.new()
	p.id = "niu"
	p.planet_name = "Ox Star"
	p.description = "Upgrades Straight Flush"
	p.emoji = "⭐"
	p.hand_type = PokerHand.HandType.STRAIGHT_FLUSH
	p.cost = 4
	p.level_chips = 35
	p.level_mult = 3
	planets.append(p)

	## 女宿 — Five of a Kind (6-card)
	p = PlanetData.new()
	p.id = "nv"
	p.planet_name = "Maiden Star"
	p.description = "Upgrades Five of a Kind"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FIVE_OF_A_KIND
	p.cost = 4
	p.level_chips = 35
	p.level_mult = 3
	planets.append(p)

	## 虚宿 — Flush House (6-card)
	p = PlanetData.new()
	p.id = "xu"
	p.planet_name = "Void Star"
	p.description = "Upgrades Flush House"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FLUSH_HOUSE
	p.cost = 4
	p.level_chips = 35
	p.level_mult = 3
	planets.append(p)

	## 危宿 — Flush Five (6-card)
	p = PlanetData.new()
	p.id = "wei_n"
	p.planet_name = "Danger Star"
	p.description = "Upgrades Flush Five"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FLUSH_FIVE
	p.cost = 5
	p.level_chips = 40
	p.level_mult = 3
	planets.append(p)

	## 室宿 — Double Three (6-card)
	p = PlanetData.new()
	p.id = "shi"
	p.planet_name = "Hall Star"
	p.description = "Upgrades Double Three"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.DOUBLE_THREE
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 壁宿 — Triple Pair (6-card)
	p = PlanetData.new()
	p.id = "bi"
	p.planet_name = "Wall Star"
	p.description = "Upgrades Triple Pair"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.TRIPLE_PAIR
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 2
	planets.append(p)

	## ============================================================
	## 西方白虎七宿 (♦) — 高阶牌型
	## ============================================================

	## 奎宿 — Four-One-One (6-card)
	p = PlanetData.new()
	p.id = "kui"
	p.planet_name = "Stride Star"
	p.description = "Upgrades Four-One-One"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FOUR_ONE_ONE
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 娄宿 — Full House Plus (6-card)
	p = PlanetData.new()
	p.id = "lou"
	p.planet_name = "Mound Star"
	p.description = "Upgrades Full House Plus"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FULL_HOUSE_PLUS
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 胃宿 — Straight Six (6-card)
	p = PlanetData.new()
	p.id = "wei_w"
	p.planet_name = "Stomach Star"
	p.description = "Upgrades Straight Six"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.STRAIGHT_SIX
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 昴宿 — Flush Six (6-card)
	p = PlanetData.new()
	p.id = "mao"
	p.planet_name = "Hairy Star"
	p.description = "Upgrades Flush Six"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FLUSH_SIX
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 毕宿 — Straight Flush Six (6-card)
	p = PlanetData.new()
	p.id = "bi_w"
	p.planet_name = "Net Star"
	p.description = "Upgrades Straight Flush Six"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.STRAIGHT_FLUSH_SIX
	p.cost = 5
	p.level_chips = 40
	p.level_mult = 4
	planets.append(p)

	## 觜宿 — Full Flush (6-card)
	p = PlanetData.new()
	p.id = "zi"
	p.planet_name = "Beak Star"
	p.description = "Upgrades Full Flush"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.FULL_FLUSH
	p.cost = 5
	p.level_chips = 40
	p.level_mult = 4
	planets.append(p)

	## 参宿 — Royal Flush (5-card)
	p = PlanetData.new()
	p.id = "shen"
	p.planet_name = "Trident Star"
	p.description = "Upgrades Royal Flush"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.ROYAL_FLUSH
	p.cost = 5
	p.level_chips = 40
	p.level_mult = 4
	planets.append(p)

	## ============================================================
	## 南方朱雀七宿 (♥) — 至高牌型
	## ============================================================

	## 井宿 — Four-Two (6-card)
	p = PlanetData.new()
	p.id = "jing"
	p.planet_name = "Well Star"
	p.description = "Upgrades Four-Two"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.FOUR_TWO
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 鬼宿 — Two-Three (6-card)
	p = PlanetData.new()
	p.id = "gui"
	p.planet_name = "Ghost Star"
	p.description = "Upgrades Two-Three"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.TWO_THREE
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 柳宿 — Pair-Four (6-card)
	p = PlanetData.new()
	p.id = "liu"
	p.planet_name = "Willow Star"
	p.description = "Upgrades Pair-Four"
	p.emoji = "🌟"
	p.hand_type = PokerHand.HandType.PAIR_FOUR
	p.cost = 4
	p.level_chips = 30
	p.level_mult = 3
	planets.append(p)

	## 星宿 — Royal Flush Six (6-card)
	p = PlanetData.new()
	p.id = "xing"
	p.planet_name = "Star Star"
	p.description = "Upgrades Royal Flush Six"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.ROYAL_FLUSH_SIX
	p.cost = 5
	p.level_chips = 45
	p.level_mult = 4
	planets.append(p)

	## 张宿 — Six of a Kind (6-card)
	p = PlanetData.new()
	p.id = "zhang"
	p.planet_name = "Spread Star"
	p.description = "Upgrades Six of a Kind"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.SIX_OF_A_KIND
	p.cost = 5
	p.level_chips = 45
	p.level_mult = 4
	planets.append(p)

	## 翼宿 — Flush Six of a Kind (6-card)
	p = PlanetData.new()
	p.id = "yi"
	p.planet_name = "Wing Star"
	p.description = "Upgrades Flush Six of a Kind"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.FLUSH_SIX_KIND
	p.cost = 5
	p.level_chips = 50
	p.level_mult = 4
	planets.append(p)

	## 轸宿 — Royal Six of a Kind (6-card ultimate)
	p = PlanetData.new()
	p.id = "zhen"
	p.planet_name = "Chariot Star"
	p.description = "Upgrades Royal Six of a Kind"
	p.emoji = "💫"
	p.hand_type = PokerHand.HandType.ROYAL_SIX_KIND
	p.cost = 5
	p.level_chips = 50
	p.level_mult = 5
	planets.append(p)

	return planets

## 获取随机 N 张星宿牌（用于商店）
static func get_random_planets(count: int) -> Array[PlanetData]:
	var all = get_all_planets()
	all.shuffle()
	var result: Array[PlanetData] = []
	for i in range(mini(count, all.size())):
		result.append(all[i])
	return result

## 根据牌型获取对应星宿
static func get_planet_for_hand(hand_type: PokerHand.HandType) -> PlanetData:
	for p in get_all_planets():
		if p.hand_type == hand_type:
			return p
	return null

## 仅获取5卡基础牌型的星宿（前9个）
static func get_base_planets() -> Array[PlanetData]:
	var all = get_all_planets()
	var result: Array[PlanetData] = []
	for i in range(mini(9, all.size())):
		result.append(all[i])
	return result
