## spectral_database.gd
## 幽冥牌数据库 V1 — 10张幽冥牌
class_name SpectralDatabase
extends RefCounted

static func get_all_spectrals() -> Array[SpectralData]:
	var spectrals: Array[SpectralData] = []

	## 1. 招魂幡 — 销毁1张随机牌→生成3张随机增强人头牌
	var s1 = SpectralData.new()
	s1.id = "soul_banner"
	s1.spectral_name = "Soul-Calling Banner"
	s1.description = "Destroy 1 random card, create 3 random enhanced face cards"
	s1.emoji = "👻"
	s1.effect = SpectralData.SpectralEffect.CARD_TRANSFORM_FACE
	s1.cost = 4
	spectrals.append(s1)

	## 2. 生死簿 — 销毁1张随机牌→生成4张随机增强数字牌
	var s2 = SpectralData.new()
	s2.id = "book_of_life_death"
	s2.spectral_name = "Book of Life and Death"
	s2.description = "Destroy 1 random card, create 4 random enhanced number cards"
	s2.emoji = "📖"
	s2.effect = SpectralData.SpectralEffect.CARD_TRANSFORM_NUMBER
	s2.cost = 4
	spectrals.append(s2)

	## 3. 六道轮回 — 手中所有牌变为同一随机花色
	var s3 = SpectralData.new()
	s3.id = "six_paths"
	s3.spectral_name = "Six Paths of Reincarnation"
	s3.description = "All cards in hand become a single random suit"
	s3.emoji = "🔄"
	s3.effect = SpectralData.SpectralEffect.BATCH_SUIT_CHANGE
	s3.cost = 4
	spectrals.append(s3)

	## 4. 夺舍 — 手中所有牌变为同一随机点数，手牌上限-1
	var s4 = SpectralData.new()
	s4.id = "soul_possession"
	s4.spectral_name = "Soul Possession"
	s4.description = "All cards become single random rank, -1 hand size permanently"
	s4.emoji = "💀"
	s4.effect = SpectralData.SpectralEffect.BATCH_RANK_CHANGE
	s4.cost = 4
	spectrals.append(s4)

	## 5. 封神 — 创建1张传说级异兽牌
	var s5 = SpectralData.new()
	s5.id = "deification"
	s5.spectral_name = "Deification"
	s5.description = "Create 1 Legendary Beast card"
	s5.emoji = "⭐"
	s5.effect = SpectralData.SpectralEffect.CREATE_LEGENDARY_JOKER
	s5.cost = 4
	spectrals.append(s5)

	## 6. 天劫 — 所有牌型等级+1
	var s6 = SpectralData.new()
	s6.id = "heavenly_tribulation"
	s6.spectral_name = "Heavenly Tribulation"
	s6.description = "Level up ALL hand types by 1"
	s6.emoji = "⚡"
	s6.effect = SpectralData.SpectralEffect.UPGRADE_ALL_HANDS
	s6.cost = 4
	spectrals.append(s6)

	## 7. 焚身 — 销毁手中5张随机牌→获得$20
	var s7 = SpectralData.new()
	s7.id = "self_immolation"
	s7.spectral_name = "Self-Immolation"
	s7.description = "Destroy 5 random cards, gain $20"
	s7.emoji = "🔥"
	s7.effect = SpectralData.SpectralEffect.DESTROY_FOR_COINS
	s7.cost = 4
	spectrals.append(s7)

	## 8. 离魂术 — 随机1只异兽获得虚相(不占栏位)，手牌上限-1
	var s8 = SpectralData.new()
	s8.id = "soul_separation"
	s8.spectral_name = "Soul Separation"
	s8.description = "Random Beast gains Phantom (no slot), -1 hand size"
	s8.emoji = "👁️"
	s8.effect = SpectralData.SpectralEffect.JOKER_PHANTOM
	s8.cost = 4
	spectrals.append(s8)

	## 9. 分身术 — 选择1张手牌→牌组中创建2张副本
	var s9 = SpectralData.new()
	s9.id = "clone_technique"
	s9.spectral_name = "Clone Technique"
	s9.description = "Select 1 card, create 2 exact copies in deck"
	s9.emoji = "🔮"
	s9.effect = SpectralData.SpectralEffect.DUPLICATE_CARDS
	s9.needs_card_selection = true
	s9.cost = 4
	spectrals.append(s9)

	## 10. 阴阳眼 — 选中1只异兽获得多彩(×1.5)，销毁其余
	var s10 = SpectralData.new()
	s10.id = "yin_yang_eyes"
	s10.spectral_name = "Yin-Yang Eyes"
	s10.description = "Selected Beast gains Polychrome (×1.5), destroy all others"
	s10.emoji = "👁️"
	s10.effect = SpectralData.SpectralEffect.JOKER_POLYCHROME_DESTROY
	s10.needs_joker_selection = true
	s10.cost = 4
	spectrals.append(s10)

	return spectrals

static func get_spectral_by_id(spectral_id: String) -> SpectralData:
	for s in get_all_spectrals():
		if s.id == spectral_id:
			return s
	return null

static func get_random_spectral(count: int = 1) -> Array[SpectralData]:
	var all = get_all_spectrals()
	all.shuffle()
	var result: Array[SpectralData] = []
	for i in range(mini(count, all.size())):
		result.append(all[i])
	return result
