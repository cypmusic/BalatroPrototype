## tarot_database.gd
## 法宝数据库 V0.086 — 36张法宝牌（16神器 + 10阵法 + 10幽冥）
## 36天罡：神器(精密改造) + 阵法(环境改变) + 幽冥(极端高风险)
class_name TarotDatabase
extends RefCounted

static func get_all_tarots() -> Array[TarotData]:
	var tarots: Array[TarotData] = []

	## ============================================================
	## 法宝·神器 (16张) — Relics
	## ============================================================

	## A-R01 翻天印 — 1张牌随机变花色
	var t = TarotData.new()
	t.id = "seal_of_heaven"
	t.tarot_name = "Seal of Heaven's Overthrow"
	t.description = "Change 1 card to random suit"
	t.emoji = "🎴"
	t.effect = TarotData.TarotEffect.CHANGE_SUIT_RANDOM
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R02 太极图 — ≤3张变♠
	t = TarotData.new()
	t.id = "taiji_diagram"
	t.tarot_name = "Diagram of the Supreme Ultimate"
	t.description = "Change up to 3 cards to ♠"
	t.emoji = "☯"
	t.effect = TarotData.TarotEffect.CHANGE_SUIT_SPADES
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 3
	tarots.append(t)

	## A-R03 乾坤圈 — ≤3张变♥
	t = TarotData.new()
	t.id = "qiankun_ring"
	t.tarot_name = "Ring of Heaven and Earth"
	t.description = "Change up to 3 cards to ♥"
	t.emoji = "⭕"
	t.effect = TarotData.TarotEffect.CHANGE_SUIT_HEARTS
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 3
	tarots.append(t)

	## A-R04 混元金斗 — ≤3张变♦
	t = TarotData.new()
	t.id = "primordial_vessel"
	t.tarot_name = "Primordial Golden Vessel"
	t.description = "Change up to 3 cards to ♦"
	t.emoji = "🏺"
	t.effect = TarotData.TarotEffect.CHANGE_SUIT_DIAMONDS
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 3
	tarots.append(t)

	## A-R05 定海珠 — ≤3张变♣
	t = TarotData.new()
	t.id = "sea_calming_pearl"
	t.tarot_name = "Sea-Calming Pearls"
	t.description = "Change up to 3 cards to ♣"
	t.emoji = "💎"
	t.effect = TarotData.TarotEffect.CHANGE_SUIT_CLUBS
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 3
	tarots.append(t)

	## A-R06 斩仙剑 — 销毁1张牌
	t = TarotData.new()
	t.id = "immortal_sword"
	t.tarot_name = "Immortal-Slaying Sword"
	t.description = "Destroy 1 selected card"
	t.emoji = "🗡️"
	t.effect = TarotData.TarotEffect.DESTROY_CARD
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R07 照妖镜 — 复制1张牌到牌组
	t = TarotData.new()
	t.id = "demon_mirror"
	t.tarot_name = "Demon-Revealing Mirror"
	t.description = "Copy 1 card into your deck"
	t.emoji = "🪞"
	t.effect = TarotData.TarotEffect.COPY_TO_DECK
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R08 山河社稷图 — 左牌变右牌副本
	t = TarotData.new()
	t.id = "mountain_river_map"
	t.tarot_name = "Map of Mountains and Rivers"
	t.description = "Left card becomes copy of right card"
	t.emoji = "🗺️"
	t.effect = TarotData.TarotEffect.COPY_LEFT_TO_RIGHT
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 2
	t.max_select = 2
	tarots.append(t)

	## A-R09 九龙神火罩 — 添加箔片(+50 Chips)
	t = TarotData.new()
	t.id = "nine_dragon_canopy"
	t.tarot_name = "Nine-Dragon Divine Fire Canopy"
	t.description = "Add Foil to 1 card (+50 Chips)"
	t.emoji = "🔥"
	t.effect = TarotData.TarotEffect.ADD_ENHANCEMENT_FOIL
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R10 风火轮 — 添加全息(+10 Mult)
	t = TarotData.new()
	t.id = "wind_fire_wheels"
	t.tarot_name = "Wind-Fire Wheels"
	t.description = "Add Holographic to 1 card (+10 Mult)"
	t.emoji = "🌀"
	t.effect = TarotData.TarotEffect.ADD_ENHANCEMENT_HOLO
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R11 玲珑宝塔 — 添加多彩(×1.5 Mult)
	t = TarotData.new()
	t.id = "exquisite_pagoda"
	t.tarot_name = "Exquisite Pagoda"
	t.description = "Add Polychrome to 1 card (x1.5 Mult)"
	t.emoji = "🗼"
	t.effect = TarotData.TarotEffect.ADD_ENHANCEMENT_POLY
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R12 落宝金钱 — 获得$5
	t = TarotData.new()
	t.id = "treasure_coin"
	t.tarot_name = "Treasure-Felling Gold Coin"
	t.description = "Gain $5"
	t.emoji = "💰"
	t.effect = TarotData.TarotEffect.GAIN_MONEY
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 3
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-R13 青龙符 — 添加青龙印
	t = TarotData.new()
	t.id = "azure_dragon_talisman"
	t.tarot_name = "Azure Dragon Talisman"
	t.description = "Add Azure Dragon Seal to 1 card"
	t.emoji = "🐉"
	t.effect = TarotData.TarotEffect.ADD_SEAL_AZURE_DRAGON
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 4
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R14 朱雀符 — 添加朱雀印
	t = TarotData.new()
	t.id = "vermillion_bird_talisman"
	t.tarot_name = "Vermillion Bird Talisman"
	t.description = "Add Vermillion Bird Seal to 1 card"
	t.emoji = "🔥"
	t.effect = TarotData.TarotEffect.ADD_SEAL_VERMILLION_BIRD
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 4
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R15 白虎符 — 添加白虎印
	t = TarotData.new()
	t.id = "white_tiger_talisman"
	t.tarot_name = "White Tiger Talisman"
	t.description = "Add White Tiger Seal to 1 card"
	t.emoji = "🐅"
	t.effect = TarotData.TarotEffect.ADD_SEAL_WHITE_TIGER
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 4
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-R16 玄武符 — 添加玄武印
	t = TarotData.new()
	t.id = "black_tortoise_talisman"
	t.tarot_name = "Black Tortoise Talisman"
	t.description = "Add Black Tortoise Seal to 1 card"
	t.emoji = "🐢"
	t.effect = TarotData.TarotEffect.ADD_SEAL_BLACK_TORTOISE
	t.artifact_type = TarotData.ArtifactType.RELIC
	t.cost = 4
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## ============================================================
	## 法宝·阵法 (10张) — Formations
	## ============================================================

	## A-F01 诛仙阵 — +Mult全部变×Mult
	t = TarotData.new()
	t.id = "immortal_execution"
	t.tarot_name = "Immortal-Execution Formation"
	t.description = "All +Mult becomes xMult this round"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.CONVERT_ADD_TO_MULT
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F02 十绝阵 — 禁2牌型,余×2 Chips
	t = TarotData.new()
	t.id = "ten_lethal"
	t.tarot_name = "Ten Lethal Formations"
	t.description = "Disable 2 hand types; others gain x2 Chips"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.DISABLE_HAND_TYPES
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F03 万仙阵 — 商店半价
	t = TarotData.new()
	t.id = "ten_thousand_immortals"
	t.tarot_name = "Formation of Ten Thousand Immortals"
	t.description = "Next shop: all items 50% off"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.SHOP_DISCOUNT
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F04 九曲黄河阵 — +3弃牌
	t = TarotData.new()
	t.id = "nine_bend_river"
	t.tarot_name = "Nine-Bend Yellow River Formation"
	t.description = "+3 discards this round"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.ADD_DISCARDS
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F05 红水阵 — ♥+30 Chips+4 Mult
	t = TarotData.new()
	t.id = "crimson_water"
	t.tarot_name = "Crimson Water Formation"
	t.description = "All Hearts gain +30 Chips, +4 Mult this round"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.BOOST_SUIT_HEARTS
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F06 天绝阵 — 生成2张随机法宝
	t = TarotData.new()
	t.id = "heaven_severing"
	t.tarot_name = "Heaven-Severing Formation"
	t.description = "Create 2 random Artifact cards"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.GENERATE_ARTIFACTS
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F07 地烈阵 — 生成2张随机星宿
	t = TarotData.new()
	t.id = "earth_splitting"
	t.tarot_name = "Earth-Splitting Formation"
	t.description = "Create 2 random Constellation cards"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.GENERATE_CONSTELLATIONS
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F08 风吼阵 — 随机1牌型升2级
	t = TarotData.new()
	t.id = "howling_wind"
	t.tarot_name = "Howling Wind Formation"
	t.description = "Level up 1 random hand type by 2"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.LEVEL_UP_HAND_TYPE
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F09 寒冰阵 — ♣+30 Chips+4 Mult
	t = TarotData.new()
	t.id = "glacial_ice"
	t.tarot_name = "Glacial Ice Formation"
	t.description = "All Clubs gain +30 Chips, +4 Mult this round"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.BOOST_SUIT_CLUBS
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-F10 落魂阵 — 所有计分牌+2 Mult
	t = TarotData.new()
	t.id = "soul_shattering"
	t.tarot_name = "Soul-Shattering Formation"
	t.description = "All scored cards gain +2 Mult this round"
	t.emoji = "⚔️"
	t.effect = TarotData.TarotEffect.BOOST_ALL_CARDS
	t.artifact_type = TarotData.ArtifactType.FORMATION
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## ============================================================
	## 法宝·幽冥 (10张) — Specters (十殿阎罗)
	## 极端改造，高风险高回报。仅从幽冥牌包获取。
	## ============================================================

	## A-S01 招魂幡 — 销毁1随机牌→生成3张增强人头牌
	t = TarotData.new()
	t.id = "soul_banner"
	t.tarot_name = "Soul-Calling Banner"
	t.description = "Destroy 1 random card, create 3 enhanced face cards"
	t.emoji = "👻"
	t.effect = TarotData.TarotEffect.SPECTER_TRANSFORM_FACE
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S02 生死簿 — 销毁1随机牌→生成4张增强数字牌
	t = TarotData.new()
	t.id = "book_of_life_death"
	t.tarot_name = "Book of Life and Death"
	t.description = "Destroy 1 random card, create 4 enhanced number cards"
	t.emoji = "📖"
	t.effect = TarotData.TarotEffect.SPECTER_TRANSFORM_NUMBER
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S03 六道轮回 — 手中所有牌变同一随机花色
	t = TarotData.new()
	t.id = "six_paths"
	t.tarot_name = "Six Paths of Reincarnation"
	t.description = "All cards in hand become a single random suit"
	t.emoji = "🔄"
	t.effect = TarotData.TarotEffect.SPECTER_BATCH_SUIT
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S04 夺舍 — 手中所有牌变同一随机点数，手牌上限-1
	t = TarotData.new()
	t.id = "soul_possession"
	t.tarot_name = "Soul Possession"
	t.description = "All cards become single random rank. -1 hand size"
	t.emoji = "💀"
	t.effect = TarotData.TarotEffect.SPECTER_BATCH_RANK
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S05 封神 — 创建1张传说级异兽牌
	t = TarotData.new()
	t.id = "deification"
	t.tarot_name = "Deification"
	t.description = "Create 1 Legendary Beast card"
	t.emoji = "⭐"
	t.effect = TarotData.TarotEffect.SPECTER_CREATE_LEGEND
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S06 天劫 — 所有牌型等级+1
	t = TarotData.new()
	t.id = "heavenly_tribulation"
	t.tarot_name = "Heavenly Tribulation"
	t.description = "Level up ALL hand types by 1"
	t.emoji = "⚡"
	t.effect = TarotData.TarotEffect.SPECTER_UPGRADE_ALL
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S07 焚身 — 销毁5张随机牌→$20
	t = TarotData.new()
	t.id = "self_immolation"
	t.tarot_name = "Self-Immolation"
	t.description = "Destroy 5 random cards, gain $20"
	t.emoji = "🔥"
	t.effect = TarotData.TarotEffect.SPECTER_DESTROY_FOR_GOLD
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S08 离魂术 — 随机异兽获得虚相(不占栏位)，手牌上限-1
	t = TarotData.new()
	t.id = "soul_separation"
	t.tarot_name = "Soul Separation"
	t.description = "Random Beast gains Phantom (no slot). -1 hand size"
	t.emoji = "👁️"
	t.effect = TarotData.TarotEffect.SPECTER_JOKER_PHANTOM
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	## A-S09 分身术 — 选1牌→牌组中创建2张副本
	t = TarotData.new()
	t.id = "clone_technique"
	t.tarot_name = "Clone Technique"
	t.description = "Select 1 card, create 2 exact copies in deck"
	t.emoji = "🔮"
	t.effect = TarotData.TarotEffect.SPECTER_DUPLICATE_CARDS
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = true
	t.min_select = 1
	t.max_select = 1
	tarots.append(t)

	## A-S10 阴阳眼 — 选中1异兽获得多彩(×1.5)，销毁其余
	t = TarotData.new()
	t.id = "yin_yang_eyes"
	t.tarot_name = "Yin-Yang Eyes"
	t.description = "Selected Beast gains Polychrome (x1.5). Destroy all others"
	t.emoji = "👁️"
	t.effect = TarotData.TarotEffect.SPECTER_JOKER_POLY_PURGE
	t.artifact_type = TarotData.ArtifactType.SPECTER
	t.cost = 4
	t.needs_selection = false
	t.needs_joker_selection = true
	t.min_select = 0
	t.max_select = 0
	tarots.append(t)

	return tarots

## 获取随机N张法宝牌（用于商店，排除幽冥牌——幽冥仅从幽冥牌包获取）
static func get_random_tarots(count: int) -> Array[TarotData]:
	var pool: Array[TarotData] = []
	for t in get_all_tarots():
		if t.artifact_type != TarotData.ArtifactType.SPECTER:
			pool.append(t)
	pool.shuffle()
	var result: Array[TarotData] = []
	for i in range(mini(count, pool.size())):
		result.append(pool[i])
	return result

## 仅获取神器
static func get_random_relics(count: int) -> Array[TarotData]:
	var relics: Array[TarotData] = []
	for t in get_all_tarots():
		if t.artifact_type == TarotData.ArtifactType.RELIC:
			relics.append(t)
	relics.shuffle()
	var result: Array[TarotData] = []
	for i in range(mini(count, relics.size())):
		result.append(relics[i])
	return result

## 仅获取阵法
static func get_random_formations(count: int) -> Array[TarotData]:
	var formations: Array[TarotData] = []
	for t in get_all_tarots():
		if t.artifact_type == TarotData.ArtifactType.FORMATION:
			formations.append(t)
	formations.shuffle()
	var result: Array[TarotData] = []
	for i in range(mini(count, formations.size())):
		result.append(formations[i])
	return result

## 仅获取幽冥牌（用于幽冥牌包）
static func get_random_specters(count: int) -> Array[TarotData]:
	var specters: Array[TarotData] = []
	for t in get_all_tarots():
		if t.artifact_type == TarotData.ArtifactType.SPECTER:
			specters.append(t)
	specters.shuffle()
	var result: Array[TarotData] = []
	for i in range(mini(count, specters.size())):
		result.append(specters[i])
	return result

## 根据ID查找法宝
static func get_tarot_by_id(tarot_id: String) -> TarotData:
	for t in get_all_tarots():
		if t.id == tarot_id:
			return t
	return null
