## joker_database.gd
## 异兽数据库 V0.085 — 72张异兽牌（30普通 + 24罕见 + 14稀有 + 4传奇）
## 108天罡地煞：72地煞（异兽）+ 36天罡（法宝）= 108
class_name JokerDatabase
extends RefCounted

## ============================================================
## 辅助构造函数 — 减少重复代码
## ============================================================
static func _b(id: String, name: String, desc: String, emoji: String,
	rarity: int, cost: int, trigger: JokerData.TriggerType,
	effect: JokerData.EffectType, cond: JokerData.ConditionType,
	val: float, cond_val: int = 0, val2: float = 0.0,
	cond_vals: Array = []) -> JokerData:
	var j = JokerData.new()
	j.id = id
	j.joker_name = name
	j.description = desc
	j.emoji = emoji
	j.rarity = rarity
	j.cost = cost
	j.trigger = trigger
	j.effect = effect
	j.condition = cond
	j.value = val
	j.condition_value = cond_val
	j.value2 = val2
	if not cond_vals.is_empty():
		j.condition_values = cond_vals
	return j

static func get_all_jokers() -> Array[JokerData]:
	var jokers: Array[JokerData] = []

	## ============================================================
	## 普通异兽 / 凡兽 (Rarity 0) — 30张
	## ============================================================

	## === 青龙♠ 普通 (8) ===

	## B-QGC01 飞诞 — +4 Mult
	jokers.append(_b("fei_dan", "Fei Dan", "+4 Mult", "🐲",
		0, 3, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 4.0))

	## B-QGC02 蛮蛮 — +30 Chips
	jokers.append(_b("man_man", "Man Man", "+30 Chips", "🐲",
		0, 3, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 30.0))

	## B-QGC03 猼訑 — +6 Mult
	jokers.append(_b("bo_tuo", "Bo Tuo", "+6 Mult", "🐲",
		0, 4, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 6.0))

	## B-QGC04 天狗 — 每张计分♠牌+3 Mult
	jokers.append(_b("tian_gou", "Tian Gou", "+3 Mult for each scored Spade", "🐲",
		0, 4, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 3.0,
		CardData.Suit.SPADES))

	## B-QGC05 精卫 — 每次出牌永久+1 Mult
	jokers.append(_b("jing_wei", "Jing Wei", "Permanently +1 Mult each hand played", "🐲",
		0, 4, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.SCALING_MULT, JokerData.ConditionType.NONE, 1.0))

	## B-QGC06 诸犍 — 打出三条时+12 Mult
	jokers.append(_b("zhu_jian", "Zhu Jian", "+12 Mult if Three of a Kind", "🐲",
		0, 3, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.HAND_TYPE, 12.0,
		PokerHand.HandType.THREE_OF_A_KIND))

	## B-QGC07 举父 — 每剩余1次弃牌+4 Mult
	jokers.append(_b("ju_fu", "Ju Fu", "+4 Mult per remaining discard", "🐲",
		0, 3, JokerData.TriggerType.ON_SCORE_CONTEXT,
		JokerData.EffectType.ADD_MULT_PER, JokerData.ConditionType.DISCARDS_REMAINING, 4.0))

	## B-QGC08 凤凰雏 — Boss战时限+4小节
	jokers.append(_b("feng_huang_chu", "Feng Huang Chu", "Boss play timer +4 bars", "🐲",
		0, 3, JokerData.TriggerType.PASSIVE,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 4.0))

	## === 朱雀♥ 普通 (8) ===

	## B-ZQC01 赤鱬 — +5 Mult
	jokers.append(_b("chi_ru", "Chi Ru", "+5 Mult", "🔥",
		0, 3, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 5.0))

	## B-ZQC02 鵸鵌 — +40 Chips
	jokers.append(_b("qi_tu", "Qi Tu", "+40 Chips", "🔥",
		0, 3, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 40.0))

	## B-ZQC03 比翼鸟 — 每张计分♥牌+3 Mult
	jokers.append(_b("bi_yi_niao", "Bi Yi Niao", "+3 Mult for each scored Heart", "🔥",
		0, 4, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 3.0,
		CardData.Suit.HEARTS))

	## B-ZQC04 火鼠 — 打出对子时+8 Mult
	jokers.append(_b("huo_shu", "Huo Shu", "+8 Mult if Pair", "🔥",
		0, 3, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.HAND_CONTAINS_PAIR, 8.0))

	## B-ZQC05 朱鸟 — 每张计分奇数牌+30 Chips
	jokers.append(_b("zhu_niao", "Zhu Niao", "+30 Chips for each odd card scored", "🔥",
		0, 3, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_CHIPS_IF, JokerData.ConditionType.CARD_RANK_ODD, 30.0))

	## B-ZQC06 讙头国人 — 卖出时额外+$6
	jokers.append(_b("huan_tou", "Huan Tou", "+$6 extra when sold", "🔥",
		0, 3, JokerData.TriggerType.ON_SELL,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 6.0))

	## B-ZQC07 夸父 — 弃牌剩余0时+15 Mult
	jokers.append(_b("kua_fu", "Kua Fu", "+15 Mult when 0 discards remain", "🔥",
		0, 4, JokerData.TriggerType.ON_SCORE_CONTEXT,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.DISCARDS_REMAINING, 15.0, 0))

	## B-ZQC08 重明鸟 — 每剩余1次出牌+30 Chips
	jokers.append(_b("chong_ming_niao", "Chong Ming Niao", "+30 Chips per remaining play", "🔥",
		0, 3, JokerData.TriggerType.ON_SCORE_CONTEXT,
		JokerData.EffectType.ADD_CHIPS_PER, JokerData.ConditionType.NONE, 30.0))

	## === 白虎♦ 普通 (7) ===

	## B-BHC01 狌狌 — +4 Mult
	jokers.append(_b("xing_xing", "Xing Xing", "+4 Mult", "⚔️",
		0, 3, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 4.0))

	## B-BHC02 羬羊 — +50 Chips
	jokers.append(_b("qian_yang", "Qian Yang", "+50 Chips", "⚔️",
		0, 4, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 50.0))

	## B-BHC03 金乌 — 每张计分♦牌+3 Mult
	jokers.append(_b("jin_wu", "Jin Wu", "+3 Mult for each scored Diamond", "⚔️",
		0, 4, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 3.0,
		CardData.Suit.DIAMONDS))

	## B-BHC04 白鹿 — 回合结束时+$2
	jokers.append(_b("bai_lu", "Bai Lu", "+$2 at end of round", "⚔️",
		0, 3, JokerData.TriggerType.ON_ROUND_END,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 2.0))

	## B-BHC05 䑏疏 — 回合结束时+$3
	jokers.append(_b("tu_shu", "Tu Shu", "+$3 at end of round", "⚔️",
		0, 4, JokerData.TriggerType.ON_ROUND_END,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 3.0))

	## B-BHC06 豪彘 — 每张计分人头牌+4 Mult
	jokers.append(_b("hao_zhi", "Hao Zhi", "+4 Mult for each face card scored", "⚔️",
		0, 3, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_IS_FACE, 4.0))

	## B-BHC07 凝时兽 — 天机A牌速度减半
	jokers.append(_b("ning_shi_shou", "Ning Shi Shou", "Reel Draw A-slot half speed", "⚔️",
		0, 3, JokerData.TriggerType.ON_REEL_DRAW,
		JokerData.EffectType.REDUCE_REQUIREMENT, JokerData.ConditionType.NONE, 0.5))

	## === 玄武♣ 普通 (7) ===

	## B-XWC01 蠪侄 — +8 Mult
	jokers.append(_b("long_zhi", "Long Zhi", "+8 Mult", "🐢",
		0, 4, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 8.0))

	## B-XWC02 文鳐鱼 — +20 Chips
	jokers.append(_b("wen_yao_yu", "Wen Yao Yu", "+20 Chips", "🐢",
		0, 3, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 20.0))

	## B-XWC03 青鸟 — 每张计分♣牌+3 Mult
	jokers.append(_b("qing_niao", "Qing Niao", "+3 Mult for each scored Club", "🐢",
		0, 4, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 3.0,
		CardData.Suit.CLUBS))

	## B-XWC04 水麒麟 — 打出两对时+15 Mult
	jokers.append(_b("shui_qi_lin", "Shui Qi Lin", "+15 Mult if Two Pair", "🐢",
		0, 4, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.HAND_TYPE, 15.0,
		PokerHand.HandType.TWO_PAIR))

	## B-XWC05 螭龙 — 每张A/2/3/5/8计分+8 Mult (斐波那契)
	jokers.append(_b("chi_long", "Chi Long", "+8 Mult for Fibonacci cards (A/2/3/5/8)", "🐢",
		0, 4, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_RANK_LIST, 8.0,
		0, 0.0, [14, 2, 3, 5, 8]))

	## B-XWC06 白鲨 — 卖出时额外+$6
	jokers.append(_b("bai_sha", "Bai Sha", "+$6 extra when sold", "🐢",
		0, 3, JokerData.TriggerType.ON_SELL,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 6.0))

	## B-XWC07 缓息兽 — Boss战补牌+2小节/张
	jokers.append(_b("huan_xi_shou", "Huan Xi Shou", "Boss: +2 bars per card drawn", "🐢",
		0, 3, JokerData.TriggerType.ON_DISCARD,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 2.0))

	## ============================================================
	## 罕见异兽 / 灵兽 (Rarity 1) — 24张
	## ============================================================

	## === 青龙♠ 罕见 (6) ===

	## B-QGU01 当康 — 每张计分♠牌+4 Mult
	jokers.append(_b("dang_kang", "Dang Kang", "+4 Mult for each scored Spade", "🐲",
		1, 5, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 4.0,
		CardData.Suit.SPADES))

	## B-QGU02 肥遗 — 每打出同花永久+2 Mult
	jokers.append(_b("fei_yi", "Fei Yi", "Permanently +2 Mult per Flush played", "🐲",
		1, 6, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.SCALING_MULT, JokerData.ConditionType.HAND_TYPE, 2.0,
		PokerHand.HandType.FLUSH))

	## B-QGU03 狸力 — 每弃牌永久+3 Chips
	jokers.append(_b("li_li", "Li Li", "Permanently +3 Chips per discard", "🐲",
		1, 5, JokerData.TriggerType.ON_DISCARD,
		JokerData.EffectType.SCALING_CHIPS, JokerData.ConditionType.NONE, 3.0))

	## B-QGU04 化蛇 — Boss战时限+8小节
	jokers.append(_b("hua_she", "Hua She", "Boss play timer +8 bars", "🐲",
		1, 6, JokerData.TriggerType.PASSIVE,
		JokerData.EffectType.ADD_CHIPS, JokerData.ConditionType.NONE, 8.0))

	## B-QGU05 讙 — Boss战自动对齐节拍
	jokers.append(_b("huan", "Huan", "Boss: auto-snap to beat (Good guarantee)", "🐲",
		1, 5, JokerData.TriggerType.ON_BEAT_HIT,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 0.0))

	## B-QGU06 鹿蜀 — 打出顺子时×2 Mult
	jokers.append(_b("lu_shu", "Lu Shu", "x2 Mult when playing Straight", "🐲",
		1, 6, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.MULTIPLY_MULT_IF, JokerData.ConditionType.HAND_TYPE, 2.0,
		PokerHand.HandType.STRAIGHT))

	## === 朱雀♥ 罕见 (6) ===

	## B-ZQU01 鸾鸟 — 每张计分♥牌+4 Mult
	jokers.append(_b("luan_niao", "Luan Niao", "+4 Mult for each scored Heart", "🔥",
		1, 5, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 4.0,
		CardData.Suit.HEARTS))

	## B-ZQU02 毕方鸣 — 持有$20+时×1.5 Mult
	jokers.append(_b("bi_fang_ming", "Bi Fang Ming", "x1.5 Mult when holding $20+", "🔥",
		1, 6, JokerData.TriggerType.ON_SCORE_CONTEXT,
		JokerData.EffectType.MULTIPLY_MULT_IF, JokerData.ConditionType.MONEY_THRESHOLD, 1.5,
		20))

	## B-ZQU03 飞廉 — 每张计分偶数牌+8 Mult
	jokers.append(_b("fei_lian", "Fei Lian", "+8 Mult for each even card scored", "🔥",
		1, 6, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_RANK_EVEN, 8.0))

	## B-ZQU04 祸斗 — 卖出后下一手×3 Mult
	jokers.append(_b("huo_dou", "Huo Dou", "After selling, next hand x3 Mult", "🔥",
		1, 6, JokerData.TriggerType.ON_SELL,
		JokerData.EffectType.SELF_DESTROY_GAIN, JokerData.ConditionType.NONE, 3.0))

	## B-ZQU05 朱獳 — Perfect节拍Bonus→130%
	jokers.append(_b("zhu_nao", "Zhu Nao", "Perfect beat bonus: 130%", "🔥",
		1, 5, JokerData.TriggerType.ON_BEAT_HIT,
		JokerData.EffectType.ADD_MULT, JokerData.ConditionType.NONE, 1.3))

	## B-ZQU06 驺吾 — 打出含对子的牌型时×1.5 Mult
	jokers.append(_b("zou_wu", "Zou Wu", "x1.5 Mult when hand contains Pair", "🔥",
		1, 5, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.MULTIPLY_MULT_IF, JokerData.ConditionType.HAND_CONTAINS_PAIR, 1.5))

	## === 白虎♦ 罕见 (6) ===

	## B-BHU01 狻猊 — 每张计分♦牌+4 Mult
	jokers.append(_b("suan_ni", "Suan Ni", "+4 Mult for each scored Diamond", "⚔️",
		1, 5, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 4.0,
		CardData.Suit.DIAMONDS))

	## B-BHU02 獬豸 — 每张计分人头牌+$1
	jokers.append(_b("xie_zhi", "Xie Zhi", "+$1 for each face card scored", "⚔️",
		1, 5, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.CARD_IS_FACE, 1.0))

	## B-BHU03 穷奇 — 回合结束时+$4
	jokers.append(_b("qiong_qi", "Qiong Qi", "+$4 at end of round", "⚔️",
		1, 6, JokerData.TriggerType.ON_ROUND_END,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 4.0))

	## B-BHU04 睚眦 — 天机A牌只出人头牌
	jokers.append(_b("ya_zi", "Ya Zi", "Reel A-slot: face cards only", "⚔️",
		1, 6, JokerData.TriggerType.ON_REEL_DRAW,
		JokerData.EffectType.ADD_JOKER_SLOT, JokerData.ConditionType.CARD_IS_FACE, 0.0))

	## B-BHU05 猰貐 — 天机A牌只出♦花色
	jokers.append(_b("ya_yu", "Ya Yu", "Reel A-slot: only Diamonds", "⚔️",
		1, 5, JokerData.TriggerType.ON_REEL_DRAW,
		JokerData.EffectType.ADD_JOKER_SLOT, JokerData.ConditionType.CARD_SUIT, 0.0,
		CardData.Suit.DIAMONDS))

	## B-BHU06 麒麟 — 每张计分人头牌+50 Chips
	jokers.append(_b("qi_lin", "Qi Lin", "+50 Chips for each face card scored", "⚔️",
		1, 6, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_CHIPS_IF, JokerData.ConditionType.CARD_IS_FACE, 50.0))

	## === 玄武♣ 罕见 (6) ===

	## B-XWU01 玄蛇 — 每张计分♣牌+4 Mult
	jokers.append(_b("xuan_she", "Xuan She", "+4 Mult for each scored Club", "🐢",
		1, 5, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.ADD_MULT_IF, JokerData.ConditionType.CARD_SUIT, 4.0,
		CardData.Suit.CLUBS))

	## B-XWU02 巴蛇 — ♠计分牌重触发1次
	jokers.append(_b("ba_she", "Ba She", "Spade cards retrigger once", "🐢",
		1, 6, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.RETRIGGER, JokerData.ConditionType.CARD_SUIT, 1.0,
		CardData.Suit.SPADES))

	## B-XWU03 赢鱼 — 偶数牌重触发1次
	jokers.append(_b("ying_yu", "Ying Yu", "Even cards retrigger once", "🐢",
		1, 6, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.RETRIGGER, JokerData.ConditionType.CARD_RANK_EVEN, 1.0))

	## B-XWU04 腾蛇 — 复制左侧异兽效果
	jokers.append(_b("teng_she", "Teng She", "Copy left Beast's effect", "🐢",
		1, 6, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.COPY_EFFECT, JokerData.ConditionType.NONE, 0.0))

	## B-XWU05 冉遗鱼 — 补牌时额外天机A级抽牌
	jokers.append(_b("ran_yi_yu", "Ran Yi Yu", "+1 extra A-tier Reel Draw on redraw", "🐢",
		1, 6, JokerData.TriggerType.ON_DISCARD,
		JokerData.EffectType.ADD_JOKER_SLOT, JokerData.ConditionType.NONE, 1.0))

	## B-XWU06 蛟龙 — 回合结束时+$4
	jokers.append(_b("jiao_long", "Jiao Long", "+$4 at end of round", "🐢",
		1, 5, JokerData.TriggerType.ON_ROUND_END,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 4.0))

	## ============================================================
	## 稀有异兽 / 神兽 (Rarity 2) — 14张
	## ============================================================

	## === 青龙♠ 稀有 (3) ===

	## B-QGR01 应龙 — 每击败Boss永久+×0.2 Mult
	jokers.append(_b("ying_long", "Ying Long", "Per boss beaten: permanently +x0.2 Mult", "🐲",
		2, 8, JokerData.TriggerType.PASSIVE,
		JokerData.EffectType.SCALING_MULT, JokerData.ConditionType.NONE, 0.2))

	## B-QGR02 烛龙 — Boss战中每小节+3 Mult
	jokers.append(_b("zhu_long", "Zhu Long", "Boss: +3 Mult per bar (max +48)", "🐲",
		2, 8, JokerData.TriggerType.ON_BEAT_HIT,
		JokerData.EffectType.SCALING_MULT, JokerData.ConditionType.NONE, 3.0))

	## B-QGR03 句芒 — ×1.5 Mult
	jokers.append(_b("gou_mang", "Gou Mang", "x1.5 Mult", "🐲",
		2, 7, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.MULTIPLY_MULT, JokerData.ConditionType.NONE, 1.5))

	## === 朱雀♥ 稀有 (3) ===

	## B-ZQR01 九尾狐 — 打出葫芦或更强时×3 Mult
	jokers.append(_b("jiu_wei_hu", "Jiu Wei Hu", "x3 Mult on Full House or better", "🔥",
		2, 8, JokerData.TriggerType.ON_HAND_PLAYED,
		JokerData.EffectType.MULTIPLY_MULT_IF, JokerData.ConditionType.HAND_TYPE, 3.0,
		PokerHand.HandType.FULL_HOUSE))

	## B-ZQR02 朱厌 — 每轮首手×2 Mult
	jokers.append(_b("zhu_yan", "Zhu Yan", "x2 Mult on first hand each round", "🔥",
		2, 7, JokerData.TriggerType.ON_SCORE_CONTEXT,
		JokerData.EffectType.MULTIPLY_MULT_IF, JokerData.ConditionType.CARDS_PLAYED_COUNT, 2.0, 0))

	## B-ZQR03 毒蜮 — 3盲注后自毁，全牌组永久+1 Mult
	jokers.append(_b("du_yu", "Du Yu", "After 3 blinds: self-destruct, all cards +1 Mult", "🔥",
		2, 7, JokerData.TriggerType.ON_BLIND_START,
		JokerData.EffectType.SELF_DESTROY_GAIN, JokerData.ConditionType.NONE, 1.0, 0, 3.0))

	## === 白虎♦ 稀有 (4) ===

	## B-BHR01 貔貅 — 利息上限$10
	jokers.append(_b("pi_xiu", "Pi Xiu", "Interest cap raised to $10", "⚔️",
		2, 8, JokerData.TriggerType.PASSIVE,
		JokerData.EffectType.EARN_MONEY, JokerData.ConditionType.NONE, 10.0))

	## B-BHR02 狰 — 每张低牌(2-5)计分×1.3 Mult
	jokers.append(_b("zheng", "Zheng", "x1.3 Mult for each low card (2-5) scored", "⚔️",
		2, 8, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.MULTIPLY_MULT_IF, JokerData.ConditionType.CARD_RANK_LIST, 1.3,
		0, 0.0, [2, 3, 4, 5]))

	## B-BHR03 英招 — 天机C牌预见后续2张
	jokers.append(_b("ying_zhao", "Ying Zhao", "Reel C-slot: preview next 2 cards", "⚔️",
		2, 7, JokerData.TriggerType.ON_REEL_DRAW,
		JokerData.EffectType.ADD_JOKER_SLOT, JokerData.ConditionType.NONE, 2.0))

	## B-BHR04 陆吾 — 复制最强加法效果
	jokers.append(_b("lu_wu", "Lu Wu", "Copy strongest additive Beast effect", "⚔️",
		2, 8, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.COPY_EFFECT, JokerData.ConditionType.NONE, 0.0))

	## === 玄武♣ 稀有 (4) ===

	## B-XWR01 旋龟 — 人头牌(J/Q/K)重触发1次
	jokers.append(_b("xuan_gui", "Xuan Gui", "Face cards retrigger once", "🐢",
		2, 7, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.RETRIGGER, JokerData.ConditionType.CARD_IS_FACE, 1.0))

	## B-XWR02 鲛人 — ♣计分牌重触发1次
	jokers.append(_b("jiao_ren", "Jiao Ren", "Club cards retrigger once", "🐢",
		2, 7, JokerData.TriggerType.ON_CARD_SCORED,
		JokerData.EffectType.RETRIGGER, JokerData.ConditionType.CARD_SUIT, 1.0,
		CardData.Suit.CLUBS))

	## B-XWR03 相柳 — Boss战BPM降一档
	jokers.append(_b("xiang_liu", "Xiang Liu", "Boss BPM reduced by 1 tier", "🐢",
		2, 7, JokerData.TriggerType.PASSIVE,
		JokerData.EffectType.REDUCE_REQUIREMENT, JokerData.ConditionType.NONE, 8.0))

	## B-XWR04 蠃鱼 — 每轮变为已卖出异兽
	jokers.append(_b("luo_yu", "Luo Yu", "Each round: become a random sold Beast", "🐢",
		2, 7, JokerData.TriggerType.ON_ROUND_END,
		JokerData.EffectType.COPY_EFFECT, JokerData.ConditionType.NONE, 0.0))

	## ============================================================
	## 传奇异兽 / 太古神兽 (Rarity 3) — 4张
	## ============================================================

	## B-QGL01 饕餮 — 每卖出异兽永久+其卖价 Mult
	jokers.append(_b("tao_tie", "Taotie, the Insatiable",
		"Sell a Beast: permanently +Mult equal to sell price", "🟡",
		3, 12, JokerData.TriggerType.ON_SELL,
		JokerData.EffectType.SCALING_MULT, JokerData.ConditionType.NONE, 0.0))

	## B-ZQL01 毕方 — 卖出时复制左侧异兽
	jokers.append(_b("bi_fang", "Bifang, the Fire Herald",
		"When sold, copy the Beast to the left", "🟡",
		3, 10, JokerData.TriggerType.ON_SELL,
		JokerData.EffectType.SELF_DESTROY_GAIN, JokerData.ConditionType.NONE, 0.0))

	## B-BHL01 白泽 — 天机抽牌变4次
	jokers.append(_b("bai_ze", "Baize, the All-Knowing",
		"Reel Draw becomes 4 draws (A/B/C/D)", "🟡",
		3, 12, JokerData.TriggerType.PASSIVE,
		JokerData.EffectType.ADD_JOKER_SLOT, JokerData.ConditionType.NONE, 1.0))

	## B-XWL01 玄龟 — 所有计分牌重触发1次
	jokers.append(_b("xuan_gui_l", "Xuangui, the Eternal Shell",
		"All scoring cards retrigger once", "🟡",
		3, 12, JokerData.TriggerType.ON_SCORE,
		JokerData.EffectType.RETRIGGER, JokerData.ConditionType.NONE, 1.0))

	return jokers

## 获取随机 N 张异兽牌（用于商店，按稀有度加权）
static func get_random_jokers(count: int, exclude_ids: Array = [], ante: int = 1) -> Array[JokerData]:
	var all = get_all_jokers()
	var available: Array[JokerData] = []
	for j in all:
		if not exclude_ids.has(j.id):
			available.append(j)

	## 稀有度权重按Ante调整
	var weights = _get_rarity_weights(ante)
	var weighted: Array[JokerData] = []
	for j in available:
		var w = weights[j.rarity] if j.rarity < weights.size() else 1
		for i in range(w):
			weighted.append(j)

	weighted.shuffle()
	var result: Array[JokerData] = []
	var picked_ids: Array = []
	for j in weighted:
		if j.id not in picked_ids:
			result.append(j)
			picked_ids.append(j.id)
		if result.size() >= count:
			break

	return result

## 稀有度权重表（百分比近似为整数权重）
static func _get_rarity_weights(ante: int) -> Array:
	if ante <= 2:
		return [80, 18, 2, 0]   ## 普通80% 罕见18% 稀有2% 传奇0%
	elif ante <= 4:
		return [70, 22, 7, 1]
	elif ante <= 6:
		return [55, 28, 14, 3]
	else:
		return [40, 30, 22, 8]

## 根据 ID 查找
static func get_joker_by_id(joker_id: String) -> JokerData:
	for j in get_all_jokers():
		if j.id == joker_id:
			return j
	return null

## 获取指定稀有度的异兽
static func get_jokers_by_rarity(rarity: int) -> Array[JokerData]:
	var result: Array[JokerData] = []
	for j in get_all_jokers():
		if j.rarity == rarity:
			result.append(j)
	return result
