## card_lore.gd
## 卡牌典故数据 V0.085 — 72异兽四象/效果类型/山海经典故
class_name CardLore
extends RefCounted

## 四象分类
enum SiXiang {
	AZURE_DRAGON,      ## 青龙 — 东方♠ — 木·生长
	VERMILLION_BIRD,   ## 朱雀 — 南方♥ — 火·攻击
	WHITE_TIGER,       ## 白虎 — 西方♦ — 金·经济
	BLACK_TORTOISE,    ## 玄武 — 北方♣ — 水·防御
}

## 效果类型分类
enum EffectCategory {
	ADDITIVE,     ## ① 基础加法型 — 直接 +Chips/+Mult
	SCALING,      ## ② 递增/累积型 — 永久成长
	CONDITIONAL,  ## ③ 条件加成型 — 按数量/状态加成
	MULTIPLIER,   ## ④ 倍率型 — ×Mult
	ECONOMY,      ## ⑤ 经济型 — 赚钱
	RETRIGGER,    ## ⑥ 重触发型 — 再次计分
	UTILITY,      ## ⑦ 特殊功能型 — 复制/天机/减速
	PASSIVE,      ## ⑧ 被动/触发型 — 特殊触发条件
}

## ============================================================
## 四象详情
## ============================================================

static func get_si_xiang_info(sx: SiXiang) -> Dictionary:
	match sx:
		SiXiang.AZURE_DRAGON:
			return {
				"name_en": "Azure Dragon", "name_cn": "青龙",
				"suit_cn": "♠", "element_cn": "木·生长",
				"emoji": "🐉", "color": Color(0.2, 0.7, 0.4),
			}
		SiXiang.VERMILLION_BIRD:
			return {
				"name_en": "Vermillion Bird", "name_cn": "朱雀",
				"suit_cn": "♥", "element_cn": "火·攻击",
				"emoji": "🐦", "color": Color(0.9, 0.3, 0.3),
			}
		SiXiang.WHITE_TIGER:
			return {
				"name_en": "White Tiger", "name_cn": "白虎",
				"suit_cn": "♦", "element_cn": "金·经济",
				"emoji": "🐯", "color": Color(0.8, 0.8, 0.8),
			}
		SiXiang.BLACK_TORTOISE:
			return {
				"name_en": "Black Tortoise", "name_cn": "玄武",
				"suit_cn": "♣", "element_cn": "水·防御",
				"emoji": "🐢", "color": Color(0.3, 0.4, 0.7),
			}
		_:
			return {"name_en": "?", "name_cn": "?", "suit_cn": "?",
				"element_cn": "?", "emoji": "?", "color": Color.WHITE}

## ============================================================
## 效果类型名称
## ============================================================

static func get_category_name(cat: EffectCategory, lang: String) -> String:
	match cat:
		EffectCategory.ADDITIVE:
			return "基础加法型" if lang == "中文" else "Additive"
		EffectCategory.SCALING:
			return "递增/累积型" if lang == "中文" else "Scaling"
		EffectCategory.CONDITIONAL:
			return "条件加成型" if lang == "中文" else "Conditional"
		EffectCategory.MULTIPLIER:
			return "倍率型" if lang == "中文" else "Multiplier"
		EffectCategory.ECONOMY:
			return "经济型" if lang == "中文" else "Economy"
		EffectCategory.RETRIGGER:
			return "重触发型" if lang == "中文" else "Retrigger"
		EffectCategory.UTILITY:
			return "特殊功能型" if lang == "中文" else "Utility"
		EffectCategory.PASSIVE:
			return "被动/触发型" if lang == "中文" else "Passive"
		_:
			return "未知" if lang == "中文" else "Unknown"

static func get_category_emoji(cat: EffectCategory) -> String:
	match cat:
		EffectCategory.ADDITIVE: return "①"
		EffectCategory.SCALING: return "②"
		EffectCategory.CONDITIONAL: return "③"
		EffectCategory.MULTIPLIER: return "④"
		EffectCategory.ECONOMY: return "⑤"
		EffectCategory.RETRIGGER: return "⑥"
		EffectCategory.UTILITY: return "⑦"
		EffectCategory.PASSIVE: return "⑧"
		_: return "?"

## ============================================================
## 72异兽典故数据
## ============================================================

static var _lore_cache: Dictionary = {}

static func get_beast_lore(joker_id: String) -> Dictionary:
	if _lore_cache.is_empty():
		_build_lore_cache()
	if _lore_cache.has(joker_id):
		return _lore_cache[joker_id]
	return {"si_xiang": SiXiang.AZURE_DRAGON, "category": EffectCategory.ADDITIVE,
		"lore_cn": "未记载", "lore_en": "No record found."}

static func _build_lore_cache() -> void:
	var S = SiXiang
	var C = EffectCategory
	var data: Array = [

		## ============================================================
		## 青龙♠ 普通 (8)
		## ============================================================
		["fei_dan", S.AZURE_DRAGON, C.ADDITIVE,
			"《山海经·西山经》载：玉山有兽，状如牛而白尾，其音如詨，见则天下大水。",
			"The Shan Hai Jing records: On Jade Mountain dwells a beast like an ox with a white tail, whose cry heralds great floods."],
		["man_man", S.AZURE_DRAGON, C.ADDITIVE,
			"《山海经·南山经》载：崇吾之山有鸟，状如凫而一翼一目，相得乃飞，见则天下大水。",
			"A bird of Mount Chongwu, like a duck with one wing and one eye; only in pairs can they fly."],
		["bo_tuo", S.AZURE_DRAGON, C.ADDITIVE,
			"《山海经·西山经》载：羭次之山有兽，状如人面长唇，黑身有毛，见人则笑。",
			"From the Western Mountains: a beast with a human face and long lips, black-furred, that laughs upon seeing people."],
		["tian_gou", S.AZURE_DRAGON, C.ADDITIVE,
			"《山海经·西山经》载：阴山有兽，状如狸而白首，名天狗，其音如榴榴，可以御凶。",
			"On Mount Yin dwells a beast like a fox with a white head, called Tian Gou, whose cry wards off evil."],
		["jing_wei", S.AZURE_DRAGON, C.SCALING,
			"《山海经·北山经》载：炎帝之女名女娃，溺于东海，化为精卫，常衔西山之木石以堙东海。",
			"Yan Di's daughter drowned in the Eastern Sea and became Jingwei, forever carrying stones to fill the ocean."],
		["zhu_jian", S.AZURE_DRAGON, C.ADDITIVE,
			"《山海经·西山经》载：崦嵫之山有兽，状如豹而长尾，人首牛耳一目，善行。",
			"A beast of Mount Yanzi, leopard-like with a long tail, human head and ox ears, swift of foot."],
		["ju_fu", S.AZURE_DRAGON, C.CONDITIONAL,
			"《山海经·海外南经》载：举父国人皆大力，能举百钧之物，以力闻名于世。",
			"People of the Jufu Kingdom possess great strength, able to lift hundreds of jin, famed throughout the world."],
		["feng_huang_chu", S.AZURE_DRAGON, C.PASSIVE,
			"《山海经·南山经》载：丹穴之山有鸟，状如鸡，五采而文，是为凤凰之雏，见则天下安宁。",
			"On Danxue Mountain nests a chick like a rooster painted in five colors — a phoenix fledgling whose appearance heralds peace."],

		## ============================================================
		## 朱雀♥ 普通 (8)
		## ============================================================
		["chi_ru", S.VERMILLION_BIRD, C.ADDITIVE,
			"《山海经·南山经》载：英水之中有赤鱬，状如鱼而人面，其音如鸳鸯，食之不疥。",
			"In the Ying River swims the Chi Ru, fish-like with a human face, whose call resembles mandarin ducks."],
		["qi_tu", S.VERMILLION_BIRD, C.ADDITIVE,
			"《山海经·西山经》载：翠山有鸟，状如鹊赤目，其名鵸鵌，食之可以御火。",
			"On Cui Mountain perches the Qi Tu, magpie-like with red eyes; eating it grants immunity to fire."],
		["bi_yi_niao", S.VERMILLION_BIRD, C.ADDITIVE,
			"《山海经·海外南经》载：比翼鸟在南方，青赤两色各一翼一目，须并翼方能飞行。",
			"The Paired-Wing Birds of the south: one green, one red, each with one wing and one eye — they fly only together."],
		["huo_shu", S.VERMILLION_BIRD, C.ADDITIVE,
			"《山海经·南山经》载：火鼠生于火山石下，其毛可织为火浣布，入火不燃。",
			"The Fire Rat lives beneath volcanic stones; its fur can be woven into fireproof cloth."],
		["zhu_niao", S.VERMILLION_BIRD, C.ADDITIVE,
			"《山海经·南山经》载：朱鸟为南方之神鸟，火之精也，司掌炎夏万物生长。",
			"The Vermillion Bird is the divine bird of the south, essence of fire, presiding over summer's growth."],
		["huan_tou", S.VERMILLION_BIRD, C.ECONOMY,
			"《山海经·海外南经》载：讙头国人人面鸟喙有翼，方食鱼行海上，以商贾闻。",
			"People of Huantou Kingdom have human faces with bird beaks and wings; they trade fish across the seas."],
		["kua_fu", S.VERMILLION_BIRD, C.CONDITIONAL,
			"《山海经·海外北经》载：夸父与日逐走，渴欲得饮，饮于河渭不足，北饮大泽，道渴而死。",
			"Kuafu raced the sun, drank the Yellow River and Wei River dry, and perished of thirst on his journey north."],
		["chong_ming_niao", S.VERMILLION_BIRD, C.CONDITIONAL,
			"《山海经·海内北经》载：重明鸟双瞳四目，形似鸡，鸣声如凤，能搏逐猛兽。",
			"The Double-Brightness Bird has double pupils, four eyes total, rooster-shaped, with a phoenix cry that can drive away fierce beasts."],

		## ============================================================
		## 白虎♦ 普通 (7)
		## ============================================================
		["xing_xing", S.WHITE_TIGER, C.ADDITIVE,
			"《山海经·南山经》载：狌狌状如禺而白耳，伏行人走，食之善走。",
			"The Xing Xing resembles an ape with white ears; it can walk upright like a human. Eating it grants swiftness."],
		["qian_yang", S.WHITE_TIGER, C.ADDITIVE,
			"《山海经·西山经》载：嶓冢之山有兽，状如羊而马尾，名羬羊，其脂可以已腊。",
			"On Mount Bozhong dwells the Qian Yang, sheep-like with a horse tail; its fat can cure frostbite."],
		["jin_wu", S.WHITE_TIGER, C.ADDITIVE,
			"《山海经·大荒东经》载：汤谷有扶桑，十日所浴，居于水中，有金乌负日而行。",
			"In the Valley of Soup grows the Fusang tree where ten suns bathe; the Golden Crow carries the sun across the sky."],
		["bai_lu", S.WHITE_TIGER, C.ECONOMY,
			"《山海经》载：白鹿乃祥瑞之兽，寿千岁而通灵，见之者必有福祉降临。",
			"The White Deer is an auspicious beast, living a thousand years with spiritual wisdom; those who see it are blessed."],
		["tu_shu", S.WHITE_TIGER, C.ECONOMY,
			"《山海经·中山经》载：其兽多䑏疏，状如马一角有错，可以辟火。",
			"The Tu Shu resembles a horse with a single patterned horn; it can ward off fire."],
		["hao_zhi", S.WHITE_TIGER, C.ADDITIVE,
			"《山海经·南山经》载：亶爰之山有兽，状如彘而毫大如筓，名豪彘，击之有声。",
			"On Mount Dan'yuan lives the Hao Zhi, pig-like with quills large as hairpins that ring when struck."],
		["ning_shi_shou", S.WHITE_TIGER, C.UTILITY,
			"传说凝时兽能凝滞时光，使周遭万物缓行，乃白虎座下守时之灵。",
			"Legend tells of a beast that can freeze time, slowing all things around it — a time-keeping spirit under the White Tiger."],

		## ============================================================
		## 玄武♣ 普通 (7)
		## ============================================================
		["long_zhi", S.BLACK_TORTOISE, C.ADDITIVE,
			"《山海经·中山经》载：蠪侄状如狐而九尾九首虎爪，其音如婴儿，是食人。",
			"The Long Zhi resembles a fox with nine tails, nine heads, and tiger claws; its cry sounds like a baby."],
		["wen_yao_yu", S.BLACK_TORTOISE, C.ADDITIVE,
			"《山海经·西山经》载：文鳐鱼状如鲤鱼，鸟翼鱼尾，苍文白首，出入有光，见则天下大穰。",
			"The Wen Yao Fish is carp-like with bird wings and a fish tail; it glows as it moves and its appearance foretells abundance."],
		["qing_niao", S.BLACK_TORTOISE, C.ADDITIVE,
			"《山海经·大荒西经》载：西王母使三青鸟为取食，居于昆仑之北。",
			"The Green Bird serves as messenger for the Queen Mother of the West, dwelling north of Kunlun Mountain."],
		["shui_qi_lin", S.BLACK_TORTOISE, C.ADDITIVE,
			"水麒麟为麒麟之水属化身，性情温和，出没于深水大泽，是丰收之兆。",
			"The Water Qilin is the aquatic incarnation of the Qilin, gentle in nature, appearing in deep waters as an omen of harvest."],
		["chi_long", S.BLACK_TORTOISE, C.ADDITIVE,
			"《山海经》载：螭龙无角曰螭，性善水，常盘踞于柱梁之上，守护一方。",
			"The hornless dragon is called Chi; it loves water and often coils atop pillars, guarding the realm."],
		["bai_sha", S.BLACK_TORTOISE, C.ECONOMY,
			"传说白鲨游弋于北冥深海，腹含明珠，渔人若得之，可换万金。",
			"The White Shark roams the depths of the Northern Sea, carrying a luminous pearl worth ten thousand gold."],
		["huan_xi_shou", S.BLACK_TORTOISE, C.PASSIVE,
			"缓息兽能调缓呼吸吐纳，令周遭时光流速减缓，乃玄武座下延时之灵。",
			"The Huan Xi Shou slows the breath of time itself, extending moments — a time-stretching spirit of the Black Tortoise."],

		## ============================================================
		## 青龙♠ 罕见 (6)
		## ============================================================
		["dang_kang", S.AZURE_DRAGON, C.ADDITIVE,
			"《山海经·东山经》载：钦山有兽，状如豚而有牙，名当康，其鸣自叫，见则天下大穰。",
			"On Mount Qin lives the Dang Kang, pig-like with tusks; its cry heralds a great harvest across the land."],
		["fei_yi", S.AZURE_DRAGON, C.SCALING,
			"《山海经·西山经》载：太华之山有蛇，名肥遗，六足四翼，见则天下大旱。",
			"On Mount Taihua dwells Fei Yi, a serpent with six legs and four wings; its appearance portends great drought."],
		["li_li", S.AZURE_DRAGON, C.SCALING,
			"《山海经·南山经》载：柜山有兽，状如豚有距，名狸力，其鸣自叫，见则其县多土功。",
			"On Mount Gui lives the Li Li, pig-like with spurs; its appearance means great construction works are coming."],
		["hua_she", S.AZURE_DRAGON, C.PASSIVE,
			"《山海经·中山经》载：化蛇人面豺身鸟翼，行如蛇，其音如叱呼，见则其邑大水。",
			"The Hua She has a human face, jackal body, and bird wings; it moves like a snake and its cry brings floods."],
		["huan", S.AZURE_DRAGON, C.PASSIVE,
			"《山海经·西山经》载：翼望之山有兽，状如狸而一目三尾，名讙，其音如百声。",
			"On Mount Yiwang lives the Huan, cat-like with one eye and three tails; its voice contains a hundred sounds."],
		["lu_shu", S.AZURE_DRAGON, C.MULTIPLIER,
			"《山海经·南山经》载：杻阳之山有兽，状如马而白首，名鹿蜀，其文如虎，佩之宜子孙。",
			"On Mount Niuyang dwells the Lu Shu, horse-like with a white head and tiger markings; wearing it blesses descendants."],

		## ============================================================
		## 朱雀♥ 罕见 (6)
		## ============================================================
		["luan_niao", S.VERMILLION_BIRD, C.ADDITIVE,
			"《山海经·西山经》载：女床之山有鸟，状如翟而五采文，名鸾鸟，见则天下安宁。",
			"On Mount Nuchuang perches the Luan Bird, pheasant-like in five colors; its appearance brings peace to all."],
		["bi_fang_ming", S.VERMILLION_BIRD, C.MULTIPLIER,
			"《山海经·西山经》载：章莪之山有鸟，状如鹤，一足赤文青质而白喙，名毕方，见则其邑有讹火。",
			"The Bi Fang is crane-like with one foot, blue body with red patterns; its presence heralds wildfire."],
		["fei_lian", S.VERMILLION_BIRD, C.ADDITIVE,
			"《楚辞》载：飞廉为风之神，鹿身雀首蛇尾豹文，司掌八方之风。",
			"Fei Lian is the Wind God — deer body, sparrow head, snake tail, leopard spots — master of winds from eight directions."],
		["huo_dou", S.VERMILLION_BIRD, C.PASSIVE,
			"《山海经·南山经》载：祸斗状如犬，食人，见则其邑大火，为不祥之兽。",
			"The Huo Dou is dog-like and man-eating; its appearance brings great fire, an ominous beast."],
		["zhu_nao", S.VERMILLION_BIRD, C.PASSIVE,
			"《山海经·北山经》载：朱獳状如狐而鱼翼，其音如豚，见则其国有恐。",
			"The Zhu Nao is fox-like with fish fins; its pig-like cry brings dread to the nation."],
		["zou_wu", S.VERMILLION_BIRD, C.MULTIPLIER,
			"《山海经·海内北经》载：驺吾虎身残纹五色驺尾，日行千里，性仁不食生物。",
			"The Zou Wu has a tiger body with colorful patterns; it travels a thousand li daily and, being benevolent, eats no living things."],

		## ============================================================
		## 白虎♦ 罕见 (6)
		## ============================================================
		["suan_ni", S.WHITE_TIGER, C.ADDITIVE,
			"《山海经》载：狻猊形如狮，好烟火坐，故于香炉盖上刻之，龙九子之五也。",
			"Suan Ni is lion-shaped and loves sitting in smoke and fire — carved atop incense burners. Fifth of the nine dragon sons."],
		["xie_zhi", S.WHITE_TIGER, C.ECONOMY,
			"《山海经》载：獬豸似牛而一角，能辨曲直，见人斗则触不直者。",
			"The Xie Zhi resembles a bull with one horn; it can discern right from wrong, charging the unjust."],
		["qiong_qi", S.WHITE_TIGER, C.ECONOMY,
			"《山海经·西山经》载：邽山有兽，状如牛而猬毛，名穷奇，食人从首始。",
			"On Mount Gui lives Qiong Qi, ox-like with hedgehog fur; one of the Four Fiends of ancient legend."],
		["ya_zi", S.WHITE_TIGER, C.UTILITY,
			"《山海经》载：睚眦龙首豺身，性刚烈好杀，故刻于刀环剑柄之上，龙九子之二。",
			"Ya Zi has a dragon head and jackal body, fierce and bloodthirsty — carved on sword hilts. Second of the nine dragon sons."],
		["ya_yu", S.WHITE_TIGER, C.UTILITY,
			"《山海经·北山经》载：猰貐状如人面牛身马足，其音如婴儿，为凶兽。",
			"The Ya Yu has a human face, ox body, and horse hooves; its cry sounds like a baby — a fearsome beast."],
		["qi_lin", S.WHITE_TIGER, C.ADDITIVE,
			"《山海经》载：麒麟龙首马身鹿角牛尾，不践生虫，不折生草，乃仁兽之王。",
			"The Qilin has a dragon head, horse body, deer antlers, and ox tail — it treads on no insect and breaks no grass. King of benevolent beasts."],

		## ============================================================
		## 玄武♣ 罕见 (6)
		## ============================================================
		["xuan_she", S.BLACK_TORTOISE, C.ADDITIVE,
			"传说玄蛇盘踞于北方幽暗之地，黑鳞如墨，寒气逼人，乃玄武座下蛇将。",
			"The Dark Serpent coils in the northern shadows, black-scaled as ink, radiating cold — a serpent general under the Black Tortoise."],
		["ba_she", S.BLACK_TORTOISE, C.RETRIGGER,
			"《山海经·海内南经》载：巴蛇食象，三岁而出其骨，长数百丈，居于洞庭之野。",
			"Ba She swallows elephants whole, taking three years to digest; hundreds of zhang long, it dwells in the wilds of Dongting."],
		["ying_yu", S.BLACK_TORTOISE, C.RETRIGGER,
			"《山海经·南山经》载：赢鱼状如鱼而鸟翼，苍文白首赤喙，出入有光，见则天下大穰。",
			"The Ying Yu is fish-like with bird wings; blue-patterned, white-headed, red-beaked, glowing as it swims — its appearance portends abundance."],
		["teng_she", S.BLACK_TORTOISE, C.UTILITY,
			"腾蛇为上古飞蛇，能乘雾飞行，与龙同类而无角无足，善于变幻。",
			"The Teng She is an ancient flying serpent that rides upon mist — kin to dragons but hornless and legless, master of transformation."],
		["ran_yi_yu", S.BLACK_TORTOISE, C.UTILITY,
			"《山海经·西山经》载：英鞮之山有鱼，名冉遗鱼，状如蛇而六足有目，食之不眯不疫。",
			"On Mount Yingdi swims the Ran Yi Fish, snake-like with six legs; eating it prevents nightmares and plague."],
		["jiao_long", S.BLACK_TORTOISE, C.ECONOMY,
			"《山海经》载：蛟龙居于深渊，能兴云布雨，龙之眷属也，修行千年可化真龙。",
			"The Jiao Long dwells in deep waters, commanding clouds and rain — kin to dragons, it may become a true dragon after a millennium."],

		## ============================================================
		## 青龙♠ 稀有 (3)
		## ============================================================
		["ying_long", S.AZURE_DRAGON, C.SCALING,
			"《山海经·大荒东经》载：应龙为黄帝之神龙，有翼善飞，曾助黄帝斩蚩尤于涿鹿之野。",
			"Ying Long is the divine winged dragon of the Yellow Emperor, who helped slay Chi You on the fields of Zhuolu."],
		["zhu_long", S.AZURE_DRAGON, C.SCALING,
			"《山海经·海外北经》载：烛龙人面蛇身赤色，身长千里，睁目为昼，闭目为夜。",
			"Zhu Long has a human face and serpent body, a thousand li long — opening its eyes brings day, closing them brings night."],
		["gou_mang", S.AZURE_DRAGON, C.MULTIPLIER,
			"《山海经》载：句芒为东方之神，鸟身人面，乘两龙，司掌春天与万物生长。",
			"Gou Mang is the God of the East — bird body, human face, riding two dragons, governing spring and the growth of all things."],

		## ============================================================
		## 朱雀♥ 稀有 (3)
		## ============================================================
		["jiu_wei_hu", S.VERMILLION_BIRD, C.MULTIPLIER,
			"《山海经·南山经》载：青丘之山有兽，状如狐而九尾，其音如婴儿，能食人。",
			"On Mount Qingqiu dwells a beast like a fox with nine tails, crying like a baby — the legendary Nine-Tailed Fox."],
		["zhu_yan", S.VERMILLION_BIRD, C.MULTIPLIER,
			"《山海经·西山经》载：朱厌状如猿而白首赤足，名朱厌，见则天下大兵。",
			"The Zhu Yan resembles an ape with a white head and red feet; its appearance presages great war."],
		["du_yu", S.VERMILLION_BIRD, C.PASSIVE,
			"《山海经·中山经》载：毒蜮含沙射影，中人则病，居于水中，甚为阴毒。",
			"The Du Yu lurks in water, shooting shadows with sand — those struck fall ill. Deeply sinister and venomous."],

		## ============================================================
		## 白虎♦ 稀有 (4)
		## ============================================================
		["pi_xiu", S.WHITE_TIGER, C.ECONOMY,
			"《山海经》载：貔貅龙头马身麟脚，口大无肛，能吞万物而不泄，为招财之兽。",
			"Pi Xiu has a dragon head, horse body, and qilin feet — a great mouth that swallows all but excretes nothing. Supreme wealth-gathering beast."],
		["zheng", S.WHITE_TIGER, C.MULTIPLIER,
			"《山海经·西山经》载：章莪之山有兽，状如赤豹五尾一角，其音如击石，名狰。",
			"On Mount Zhang'e lives Zheng, like a red leopard with five tails and one horn; its voice sounds like striking stone."],
		["ying_zhao", S.WHITE_TIGER, C.UTILITY,
			"《山海经》载：英招马身人面虎文鸟翼，徇于四海，司掌天帝苑囿。",
			"Ying Zhao has a horse body, human face, tiger stripes, and bird wings — it patrols the four seas, guarding the Emperor's gardens."],
		["lu_wu", S.WHITE_TIGER, C.UTILITY,
			"《山海经·西山经》载：陆吾人面虎身九尾，司天之九部及帝之囿时，昆仑山神也。",
			"Lu Wu has a human face, tiger body, and nine tails — guardian of Heaven's nine domains and keeper of Kunlun Mountain."],

		## ============================================================
		## 玄武♣ 稀有 (4)
		## ============================================================
		["xuan_gui", S.BLACK_TORTOISE, C.RETRIGGER,
			"《山海经·南山经》载：旋龟出于杻阳之山，状如龟而鸟首虺尾，其音如判木。",
			"The Xuan Gui emerges from Mount Niuyang, turtle-like with a bird head and snake tail; its sound is like splitting wood."],
		["jiao_ren", S.BLACK_TORTOISE, C.RETRIGGER,
			"《山海经·海内南经》载：鲛人居于南海水中，织绡泣珠，其珠价值连城。",
			"The Jiao Ren dwell in the Southern Sea, weaving silk and weeping pearls of immeasurable value."],
		["xiang_liu", S.BLACK_TORTOISE, C.UTILITY,
			"《山海经·大荒北经》载：相柳九首蛇身自环，食于九山，所呕之处为泽为溪。",
			"Xiang Liu has nine heads on a serpent body coiled in a ring — it feeds from nine mountains, and where it vomits, swamps and streams form."],
		["luo_yu", S.BLACK_TORTOISE, C.UTILITY,
			"《山海经·北山经》载：蠃鱼状如鱼而人面，其音如鸳鸯，食之已疫。",
			"The Luo Yu is fish-like with a human face; its cry resembles mandarin ducks, and eating it cures plague."],

		## ============================================================
		## 传奇 (4)
		## ============================================================
		["tao_tie", S.AZURE_DRAGON, C.SCALING,
			"《山海经·北次二经》载：饕餮羊身人面，眼在腋下，虎齿人爪，贪食无厌，为四凶之一。",
			"Taotie has a sheep body and human face, eyes under its arms, tiger teeth and human claws — insatiably gluttonous, one of the Four Fiends."],
		["bi_fang", S.VERMILLION_BIRD, C.PASSIVE,
			"《山海经·西山经》载：毕方状如鹤，一足赤文青质白喙，不食五谷而食火焰。",
			"Bi Fang resembles a crane with one foot, blue body with red markings — it feeds not on grain but on flame itself."],
		["bai_ze", S.WHITE_TIGER, C.UTILITY,
			"《山海经》载：白泽通万物之情，知鬼神之事，黄帝巡狩东海遇之，白泽言天下鬼神万一千五百二十种。",
			"Bai Ze knows all creatures and spirits — when the Yellow Emperor found it by the Eastern Sea, it described 11,520 types of supernatural beings."],
		["xuan_gui_l", S.BLACK_TORTOISE, C.RETRIGGER,
			"传说玄龟乃上古神龟，寿逾万年，背负天地之柱，不灭不朽，为玄武之化身。",
			"The Eternal Shell is an ancient divine turtle, living over ten thousand years, bearing the Pillar of Heaven — indestructible avatar of the Black Tortoise."],
	]

	for entry in data:
		_lore_cache[entry[0]] = {
			"si_xiang": entry[1],
			"category": entry[2],
			"lore_cn": entry[3],
			"lore_en": entry[4],
		}
