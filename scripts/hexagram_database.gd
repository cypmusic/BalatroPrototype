## hexagram_database.gd
## 64卦数据库 V0.086 — 天地万象 · Wanxiang
## 包含：卦象数据 + 变爻邻接自动计算 + 路线生成
class_name HexagramDatabase
extends RefCounted

# ==============================
# 八卦基础编码
# ==============================
enum Trigram {
	KUN = 0,   ## ☷ 坤 000
	GEN = 1,   ## ☶ 艮 001
	KAN = 2,   ## ☵ 坎 010
	XUN = 3,   ## ☴ 巽 011
	ZHEN = 4,  ## ☳ 震 100
	LI = 5,    ## ☲ 离 101
	DUI = 6,   ## ☱ 兑 110
	QIAN = 7,  ## ☰ 乾 111
}

## 八卦→四象映射
enum SiXiang { QINGLONG, ZHUQUE, BAIHU, XUANWU }

const TRIGRAM_TO_SIXIANG := {
	Trigram.QIAN: SiXiang.BAIHU,    ## 乾→白虎(金)
	Trigram.KUN:  SiXiang.XUANWU,   ## 坤→玄武(水)
	Trigram.KAN:  SiXiang.XUANWU,   ## 坎→玄武(水)
	Trigram.LI:   SiXiang.ZHUQUE,   ## 离→朱雀(火)
	Trigram.ZHEN: SiXiang.QINGLONG, ## 震→青龙(木)
	Trigram.XUN:  SiXiang.QINGLONG, ## 巽→青龙(木)
	Trigram.GEN:  SiXiang.BAIHU,    ## 艮→白虎(金)
	Trigram.DUI:  SiXiang.ZHUQUE,   ## 兑→朱雀(火)
}

const SIXIANG_NAMES := {
	SiXiang.QINGLONG: "Azure Dragon",
	SiXiang.ZHUQUE:   "Vermillion Bird",
	SiXiang.BAIHU:    "White Tiger",
	SiXiang.XUANWU:   "Black Tortoise",
}

const SIXIANG_EMOJIS := {
	SiXiang.QINGLONG: "♠",
	SiXiang.ZHUQUE:   "♥",
	SiXiang.BAIHU:    "♦",
	SiXiang.XUANWU:   "♣",
}

const SIXIANG_COLORS := {
	SiXiang.QINGLONG: Color(0.2, 0.7, 0.4),   ## 青龙 — 青绿
	SiXiang.ZHUQUE:   Color(0.9, 0.3, 0.25),   ## 朱雀 — 赤红
	SiXiang.BAIHU:    Color(0.9, 0.85, 0.6),    ## 白虎 — 金白
	SiXiang.XUANWU:   Color(0.25, 0.35, 0.55),  ## 玄武 — 深蓝
}

const TRIGRAM_NAMES := {
	Trigram.QIAN: "乾", Trigram.KUN: "坤",
	Trigram.KAN: "坎",  Trigram.LI: "离",
	Trigram.ZHEN: "震", Trigram.XUN: "巽",
	Trigram.GEN: "艮",  Trigram.DUI: "兑",
}

const DIFFICULTY_NAMES := {
	1: "Sprouting",
	2: "Foundation",
	3: "Trial",
	4: "Middle Path",
	5: "Turbulence",
	6: "Crucible",
	7: "Tribulation",
	8: "Destiny",
}

# ==============================
# 二进制索引 → 文王序 对照表
# index = lower_trigram * 8 + upper_trigram
# ==============================
const BIN_TO_KINGWEN := [
	 2, 15,  7, 46, 24, 36, 19, 11,  ## 下坤(000): 坤谦师升复明夷临泰
	23, 52,  4, 18, 27, 22, 41, 26,  ## 下艮(001): 剥艮蒙蛊颐贲损大畜
	 8, 39, 29, 48,  3, 63, 60,  5,  ## 下坎(010): 比蹇坎井屯既济节需
	20, 53, 59, 57, 42, 37, 61,  9,  ## 下巽(011): 观渐涣巽益家人中孚小畜
	16, 62, 40, 32, 51, 55, 54, 34,  ## 下震(100): 豫小过解恒震丰归妹大壮
	35, 56, 64, 50, 21, 30, 38, 14,  ## 下离(101): 晋旅未济鼎噬嗑离睽大有
	45, 31, 47, 28, 17, 49, 58, 43,  ## 下兑(110): 萃咸困大过随革兑夬
	12, 33,  6, 44, 25, 13, 10,  1,  ## 下乾(111): 否遁讼姤无妄同人履乾
]

## 文王序 → 二进制索引（反查表，运行时构建）
static var _kingwen_to_bin := {}

# ==============================
# 64卦详细数据
# ==============================
const HEXAGRAM_DATA := {
	## --- 难度1：起始·萌芽 ---
	1:  { "name": "乾",   "difficulty": 1, "keyword": "刚健",   "effect_id": "mult_pct_15",       "effect_desc": "倍率+15%" },
	2:  { "name": "坤",   "difficulty": 1, "keyword": "柔顺",   "effect_id": "hand_size_1",        "effect_desc": "手牌数+1" },
	11: { "name": "泰",   "difficulty": 1, "keyword": "通泰",   "effect_id": "shop_discount_1",    "effect_desc": "所有商品-$1" },
	19: { "name": "临",   "difficulty": 1, "keyword": "亲临",   "effect_id": "beast_rate_10",      "effect_desc": "异兽出现率+10%" },
	25: { "name": "无妄", "difficulty": 1, "keyword": "天真",   "effect_id": "first_play_chips_20","effect_desc": "首次出牌+20筹码" },
	34: { "name": "大壮", "difficulty": 1, "keyword": "壮盛",   "effect_id": "mult_pct_10",        "effect_desc": "倍率+10%" },
	43: { "name": "夬",   "difficulty": 1, "keyword": "决断",   "effect_id": "discard_1",          "effect_desc": "弃牌数+1" },
	58: { "name": "兑",   "difficulty": 1, "keyword": "喜悦",   "effect_id": "income_2",           "effect_desc": "金币收入+$2" },

	## --- 难度2：初成·立基 ---
	9:  { "name": "小畜", "difficulty": 2, "keyword": "蓄养",   "effect_id": "discard_money_1",    "effect_desc": "弃牌时+$1/张" },
	14: { "name": "大有", "difficulty": 2, "keyword": "大有",   "effect_id": "income_3",           "effect_desc": "金币收入+$3" },
	26: { "name": "大畜", "difficulty": 2, "keyword": "积蓄",   "effect_id": "interest_cap_3",     "effect_desc": "利息上限+$3" },
	35: { "name": "晋",   "difficulty": 2, "keyword": "进步",   "effect_id": "level_exp_150",      "effect_desc": "牌型升级经验×1.5" },
	42: { "name": "益",   "difficulty": 2, "keyword": "增益",   "effect_id": "artifact_boost_25",  "effect_desc": "法宝效果+25%" },
	45: { "name": "萃",   "difficulty": 2, "keyword": "聚合",   "effect_id": "reroll_discount_1",  "effect_desc": "商店刷新-$1" },
	53: { "name": "渐",   "difficulty": 2, "keyword": "渐进",   "effect_id": "first_mult_5",       "effect_desc": "每回合首次出牌+5倍率" },
	57: { "name": "巽",   "difficulty": 2, "keyword": "柔顺入", "effect_id": "flush_chips_15",     "effect_desc": "同花牌+15筹码" },

	## --- 难度3：渐长·试炼 ---
	5:  { "name": "需",   "difficulty": 3, "keyword": "等待",   "effect_id": "boss_target_m10",    "effect_desc": "Boss盲注目标-10%" },
	15: { "name": "谦",   "difficulty": 3, "keyword": "谦逊",   "effect_id": "beast_cost_m2",      "effect_desc": "所有异兽费用-$2" },
	20: { "name": "观",   "difficulty": 3, "keyword": "观察",   "effect_id": "shop_items_1",       "effect_desc": "商店可见商品+1" },
	31: { "name": "咸",   "difficulty": 3, "keyword": "感应",   "effect_id": "star_drop_15",       "effect_desc": "星宿牌掉落率+15%" },
	37: { "name": "家人", "difficulty": 3, "keyword": "家道",   "effect_id": "flush_pair_mult_10", "effect_desc": "同花色对+10倍率" },
	41: { "name": "损",   "difficulty": 3, "keyword": "减损",   "effect_id": "discard_m1_mult_20", "effect_desc": "弃牌-1但倍率+20%" },
	52: { "name": "艮",   "difficulty": 3, "keyword": "止静",   "effect_id": "no_discard_mult_130","effect_desc": "不弃牌时倍率×1.3" },
	61: { "name": "中孚", "difficulty": 3, "keyword": "诚信",   "effect_id": "pair_chips_15",      "effect_desc": "手牌有对子时+15筹码" },

	## --- 难度4：中道·分野 ---
	8:  { "name": "比",   "difficulty": 4, "keyword": "亲附",   "effect_id": "adj_beast_20",       "effect_desc": "相邻异兽效果+20%" },
	16: { "name": "豫",   "difficulty": 4, "keyword": "欢豫",   "effect_id": "free_play_20",       "effect_desc": "出牌后有20%几率不消耗手数" },
	32: { "name": "恒",   "difficulty": 4, "keyword": "恒久",   "effect_id": "scaling_double",     "effect_desc": "异兽递增效果翻倍" },
	46: { "name": "升",   "difficulty": 4, "keyword": "上升",   "effect_id": "blind_mult_5pct",    "effect_desc": "每过一个盲注倍率+5%" },
	48: { "name": "井",   "difficulty": 4, "keyword": "汲养",   "effect_id": "round_start_2",      "effect_desc": "每回合开始获$2" },
	50: { "name": "鼎",   "difficulty": 4, "keyword": "革新",   "effect_id": "artifact_use_2",     "effect_desc": "法宝牌可使用2次" },
	51: { "name": "震",   "difficulty": 4, "keyword": "震动",   "effect_id": "first_card_150",     "effect_desc": "首张计分牌×1.5" },
	63: { "name": "既济", "difficulty": 4, "keyword": "已成",   "effect_id": "base_chips_20",      "effect_desc": "所有牌型基础筹码+20" },

	## --- 难度5：变局·风云 ---
	6:  { "name": "讼",   "difficulty": 5, "keyword": "争讼",   "effect_id": "boss_hard_reward",   "effect_desc": "Boss效果加强但奖金×1.5" },
	10: { "name": "履",   "difficulty": 5, "keyword": "践行",   "effect_id": "exact5_mult_130",    "effect_desc": "出牌恰好5张时×1.3" },
	13: { "name": "同人", "difficulty": 5, "keyword": "同心",   "effect_id": "mono_suit_mult_2",   "effect_desc": "全部同花色时倍率×2" },
	30: { "name": "离",   "difficulty": 5, "keyword": "附丽",   "effect_id": "red_chips_20",       "effect_desc": "红色牌(♥♦)+20筹码" },
	38: { "name": "睽",   "difficulty": 5, "keyword": "乖违",   "effect_id": "diverse_suit_mult",  "effect_desc": "不同花色越多倍率越高(+5/种)" },
	49: { "name": "革",   "difficulty": 5, "keyword": "变革",   "effect_id": "replace_beast_1",    "effect_desc": "可重新选择1张异兽替换" },
	55: { "name": "丰",   "difficulty": 5, "keyword": "丰盛",   "effect_id": "chips_mult_10",      "effect_desc": "筹码和倍率各+10" },
	64: { "name": "未济", "difficulty": 5, "keyword": "未成",   "effect_id": "discard_mult_3",     "effect_desc": "每次弃牌+3倍率" },

	## --- 难度6：险境·淬炼 ---
	3:  { "name": "屯",   "difficulty": 6, "keyword": "艰难",   "effect_id": "hand_m1_chips_15",   "effect_desc": "手牌-1但每张计分牌+15筹码" },
	4:  { "name": "蒙",   "difficulty": 6, "keyword": "蒙昧",   "effect_id": "blind_boss",         "effect_desc": "不显示Boss效果（盲打）" },
	18: { "name": "蛊",   "difficulty": 6, "keyword": "整治",   "effect_id": "destroy_for_reward", "effect_desc": "可销毁1张手牌获$5+倍率" },
	29: { "name": "坎",   "difficulty": 6, "keyword": "重险",   "effect_id": "ban_2_suits",        "effect_desc": "Boss禁用2种花色" },
	39: { "name": "蹇",   "difficulty": 6, "keyword": "艰行",   "effect_id": "play_m1_mult_150",   "effect_desc": "出牌数-1但倍率×1.5" },
	44: { "name": "姤",   "difficulty": 6, "keyword": "遭遇",   "effect_id": "lock_1_card",        "effect_desc": "随机1张手牌被锁（不可出）" },
	47: { "name": "困",   "difficulty": 6, "keyword": "困穷",   "effect_id": "money_m50_mult_130", "effect_desc": "金币-50%但倍率×1.3" },
	59: { "name": "涣",   "difficulty": 6, "keyword": "涣散",   "effect_id": "shuffle_hand",       "effect_desc": "手牌随机打乱位置" },

	## --- 难度7：天劫·极限 ---
	12: { "name": "否",   "difficulty": 7, "keyword": "闭塞",   "effect_id": "shop_price_3",       "effect_desc": "商店商品+$3" },
	22: { "name": "贲",   "difficulty": 7, "keyword": "文饰",   "effect_id": "enhanced_x2_plain_m20","effect_desc": "增强牌效果×2但普通牌-20筹码" },
	23: { "name": "剥",   "difficulty": 7, "keyword": "剥落",   "effect_id": "lose_card_per_round","effect_desc": "每回合随机失去1张手牌" },
	27: { "name": "颐",   "difficulty": 7, "keyword": "养正",   "effect_id": "must_have_ak",       "effect_desc": "出牌必须含A或K" },
	33: { "name": "遁",   "difficulty": 7, "keyword": "退避",   "effect_id": "no_skip_reward",     "effect_desc": "跳过盲注不给奖励" },
	36: { "name": "明夷", "difficulty": 7, "keyword": "光明损伤","effect_id": "blind_score",        "effect_desc": "计分面板不显示中间过程" },
	56: { "name": "旅",   "difficulty": 7, "keyword": "旅行",   "effect_id": "beast_slot_m1",      "effect_desc": "异兽栏位-1" },
	62: { "name": "小过", "difficulty": 7, "keyword": "小有过越","effect_id": "max_play_3",         "effect_desc": "只能出≤3张牌" },

	## --- 难度8：终局·天命 ---
	7:  { "name": "师",   "difficulty": 8, "keyword": "统师",   "effect_id": "all_clubs",          "effect_desc": "手牌全部由♣组成" },
	17: { "name": "随",   "difficulty": 8, "keyword": "随从",   "effect_id": "beast_reverse",      "effect_desc": "异兽效果顺序反转" },
	21: { "name": "噬嗑", "difficulty": 8, "keyword": "咬合",   "effect_id": "boss_hp_150",        "effect_desc": "Boss血量×1.5" },
	24: { "name": "复",   "difficulty": 8, "keyword": "回复",   "effect_id": "lose_mult_15pct",    "effect_desc": "每输一手+15%倍率（背水一战）" },
	28: { "name": "大过", "difficulty": 8, "keyword": "大过越", "effect_id": "play_m2_mult_2",     "effect_desc": "出牌数-2但倍率×2" },
	40: { "name": "解",   "difficulty": 8, "keyword": "解除",   "effect_id": "boss_double",        "effect_desc": "Boss有2个效果叠加" },
	54: { "name": "归妹", "difficulty": 8, "keyword": "归妹",   "effect_id": "play_cost_2",        "effect_desc": "每出一手消耗$2" },
	60: { "name": "节",   "difficulty": 8, "keyword": "节制",   "effect_id": "hand_limit_5",       "effect_desc": "手牌上限5张" },
}

# ==============================
# 核心方法
# ==============================

## 初始化反查表
static func _init_lookup() -> void:
	if _kingwen_to_bin.size() > 0:
		return
	for i in range(64):
		_kingwen_to_bin[BIN_TO_KINGWEN[i]] = i

## 文王序 → 二进制索引
static func kingwen_to_bin(kw: int) -> int:
	_init_lookup()
	return _kingwen_to_bin.get(kw, -1)

## 二进制索引 → 文王序
static func bin_to_kingwen(idx: int) -> int:
	if idx < 0 or idx >= 64:
		return -1
	return BIN_TO_KINGWEN[idx]

## 获取卦的上卦（外卦）
static func get_upper_trigram(bin_idx: int) -> int:
	return bin_idx % 8

## 获取卦的下卦（内卦）
static func get_lower_trigram(bin_idx: int) -> int:
	@warning_ignore("integer_division")
	return bin_idx / 8

## 获取卦的四象归属（基于上卦）
static func get_sixiang(kingwen: int) -> int:
	var bin_idx = kingwen_to_bin(kingwen)
	var upper = get_upper_trigram(bin_idx)
	return TRIGRAM_TO_SIXIANG.get(upper, SiXiang.XUANWU)

## 获取卦的上/下卦名称
static func get_trigram_names(kingwen: int) -> Dictionary:
	var bin_idx = kingwen_to_bin(kingwen)
	var upper = get_upper_trigram(bin_idx)
	var lower = get_lower_trigram(bin_idx)
	return {
		"upper": TRIGRAM_NAMES.get(upper, "?"),
		"lower": TRIGRAM_NAMES.get(lower, "?"),
	}

## 获取六爻二进制字符串（用于UI显示）
static func get_yao_string(kingwen: int) -> String:
	var bin_idx = kingwen_to_bin(kingwen)
	if bin_idx < 0:
		return "??????"
	@warning_ignore("integer_division")
	var lower = bin_idx / 8
	var upper = bin_idx % 8
	var result = ""
	## 从初爻(上卦低位)到上爻(下卦高位)
	for i in range(3):
		result += "⚊" if (upper >> i) & 1 == 1 else "⚋"
	for i in range(3):
		result += "⚊" if (lower >> i) & 1 == 1 else "⚋"
	return result

# ================================
# 变爻计算 — 核心路线生成逻辑
# ================================

## 获取变一爻后的邻居卦（文王序）
## yao_pos: 0=初爻, 1=二爻, ..., 5=上爻
static func get_yao_change_neighbor(kingwen: int, yao_pos: int) -> int:
	var bin_idx = kingwen_to_bin(kingwen)
	if bin_idx < 0 or yao_pos < 0 or yao_pos > 5:
		return -1
	var neighbor_bin = bin_idx ^ (1 << yao_pos)
	return bin_to_kingwen(neighbor_bin)

## 获取一个卦的全部6个变爻邻居（文王序数组）
static func get_all_neighbors(kingwen: int) -> Array[int]:
	var neighbors: Array[int] = []
	for yao in range(6):
		neighbors.append(get_yao_change_neighbor(kingwen, yao))
	return neighbors

## 获取可用的路线分岔（筛选难度合适的邻居）
static func get_route_branches(kingwen: int,
		allow_same_level: bool = true,
		allow_next_level: bool = true,
		min_branches: int = 2,
		max_branches: int = 3) -> Array[int]:

	var current_diff = HEXAGRAM_DATA[kingwen]["difficulty"]
	var all_neighbors = get_all_neighbors(kingwen)
	var valid: Array[int] = []

	for n in all_neighbors:
		if n < 1 or n > 64:
			continue
		if not HEXAGRAM_DATA.has(n):
			continue
		var n_diff = HEXAGRAM_DATA[n]["difficulty"]
		if allow_next_level and n_diff == current_diff + 1:
			valid.append(n)
		elif allow_same_level and n_diff == current_diff:
			valid.append(n)

	## 如果可用分岔不够，放宽条件（允许+2难度）
	if valid.size() < min_branches:
		for n in all_neighbors:
			if n < 1 or n > 64 or valid.has(n):
				continue
			if not HEXAGRAM_DATA.has(n):
				continue
			var n_diff = HEXAGRAM_DATA[n]["difficulty"]
			if n_diff == current_diff + 2:
				valid.append(n)
			if valid.size() >= max_branches:
				break

	## 如果还不够，允许-1难度
	if valid.size() < min_branches:
		for n in all_neighbors:
			if n < 1 or n > 64 or valid.has(n):
				continue
			if not HEXAGRAM_DATA.has(n):
				continue
			var n_diff = HEXAGRAM_DATA[n]["difficulty"]
			if n_diff == current_diff - 1 and n_diff >= 1:
				valid.append(n)
			if valid.size() >= max_branches:
				break

	## 随机打乱后截取
	valid.shuffle()
	if valid.size() > max_branches:
		valid.resize(max_branches)

	return valid

# ================================
# 路线生成
# ================================

## 生成一条完整的8卦路线（用于单局游戏）
## 返回 Array[int]，每个元素是文王序
static func generate_route() -> Array[int]:
	var route: Array[int] = []

	## 第1卦：从难度1的8个卦中随机选一个
	var tier1 = get_hexagrams_by_difficulty(1)
	tier1.shuffle()
	route.append(tier1[0])

	## 第2-8卦：从当前卦的变爻邻居中选择
	for step in range(1, 8):
		var current = route[step - 1]
		var branches = get_route_branches(current, true, true, 2, 3)
		if branches.size() > 0:
			route.append(branches[0])  ## 自动路线取第一个分岔
		else:
			## fallback: 直接从目标难度池随机选
			var target_diff = mini(step + 1, 8)
			var pool = get_hexagrams_by_difficulty(target_diff)
			pool.shuffle()
			route.append(pool[0])

	return route

## 获取指定难度的所有卦
static func get_hexagrams_by_difficulty(diff: int) -> Array[int]:
	var result: Array[int] = []
	for kw in HEXAGRAM_DATA:
		if HEXAGRAM_DATA[kw]["difficulty"] == diff:
			result.append(kw)
	return result

## 获取卦象数据
static func get_hexagram(kingwen: int) -> Dictionary:
	return HEXAGRAM_DATA.get(kingwen, {})

## 获取卦名
static func get_name(kingwen: int) -> String:
	var data = get_hexagram(kingwen)
	return data.get("name", "???")

## 获取四象名称
static func get_sixiang_name(kingwen: int) -> String:
	var sx = get_sixiang(kingwen)
	return SIXIANG_NAMES.get(sx, "???")

## 获取四象颜色
static func get_sixiang_color(kingwen: int) -> Color:
	var sx = get_sixiang(kingwen)
	return SIXIANG_COLORS.get(sx, Color.WHITE)

## 获取四象Emoji
static func get_sixiang_emoji(kingwen: int) -> String:
	var sx = get_sixiang(kingwen)
	return SIXIANG_EMOJIS.get(sx, "?")

## 获取难度等级名称
static func get_difficulty_name(diff: int) -> String:
	return DIFFICULTY_NAMES.get(diff, "???")

# ================================
# 交互接口
# ================================

## 根据当前卦的四象，调整商店出现的异兽和星宿牌权重
static func get_shop_weight_modifier(kingwen: int) -> Dictionary:
	var sx = get_sixiang(kingwen)
	var modifier := {
		"beast_suit_bonus": "",
		"star_suit_bonus": "",
		"bonus_pct": 0.25,
	}
	match sx:
		SiXiang.QINGLONG:
			modifier["beast_suit_bonus"] = "spades"
			modifier["star_suit_bonus"] = "spades"
		SiXiang.ZHUQUE:
			modifier["beast_suit_bonus"] = "hearts"
			modifier["star_suit_bonus"] = "hearts"
		SiXiang.BAIHU:
			modifier["beast_suit_bonus"] = "diamonds"
			modifier["star_suit_bonus"] = "diamonds"
		SiXiang.XUANWU:
			modifier["beast_suit_bonus"] = "clubs"
			modifier["star_suit_bonus"] = "clubs"
	return modifier

## 根据走过的路线的四象分布，决定最终Boss类型
static func determine_final_boss(route: Array[int]) -> int:
	var counts := {
		SiXiang.QINGLONG: 0,
		SiXiang.ZHUQUE: 0,
		SiXiang.BAIHU: 0,
		SiXiang.XUANWU: 0,
	}
	for kw in route:
		var sx = get_sixiang(kw)
		counts[sx] += 1

	var max_sx = SiXiang.QINGLONG
	var max_count = 0
	for sx in counts:
		if counts[sx] > max_count:
			max_count = counts[sx]
			max_sx = sx

	return max_sx

## 连通性验证（调试用）
static func validate_connectivity() -> String:
	var report := ""
	for diff in range(1, 8):
		var hexagrams = get_hexagrams_by_difficulty(diff)
		for kw in hexagrams:
			var neighbors = get_all_neighbors(kw)
			var has_next = false
			var has_same = false
			for n in neighbors:
				if not HEXAGRAM_DATA.has(n):
					continue
				var n_diff = HEXAGRAM_DATA[n]["difficulty"]
				if n_diff == diff + 1:
					has_next = true
				if n_diff == diff:
					has_same = true
			if not has_next and not has_same:
				report += "DEAD END: %s(D%d)\n" % [HEXAGRAM_DATA[kw]["name"], diff]
			elif not has_next:
				report += "WEAK: %s(D%d) same-level only\n" % [HEXAGRAM_DATA[kw]["name"], diff]
	if report == "":
		report = "All 64 hexagrams connected!"
	return report
