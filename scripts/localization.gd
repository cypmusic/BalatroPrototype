## localization.gd
## 完整本地化系统 - 覆盖游戏全部文本
extends RefCounted
class_name Loc

const CN_FONT_PATH: String = "res://assets/fonts/zpix.ttf"

static var _instance: Loc = null

static func i() -> Loc:
	if _instance == null:
		_instance = Loc.new()
		_instance._load_font()
	return _instance

var current_language: String = "English"
var cn_font: Font = null

func _load_font() -> void:
	if ResourceLoader.exists(CN_FONT_PATH):
		cn_font = load(CN_FONT_PATH)

func apply_font_to_label(label: Label, size: int = -1) -> void:
	if current_language == "中文" and cn_font:
		label.add_theme_font_override("font", cn_font)
	if size > 0:
		label.add_theme_font_size_override("font_size", size)

func apply_font_to_button(button: Button, size: int = -1) -> void:
	if current_language == "中文" and cn_font:
		button.add_theme_font_override("font", cn_font)
	if size > 0:
		button.add_theme_font_size_override("font_size", size)

func apply_font_to_rtl(rtl: RichTextLabel, size: int = -1) -> void:
	if current_language == "中文" and cn_font:
		rtl.add_theme_font_override("normal_font", cn_font)
	if size > 0:
		rtl.add_theme_font_size_override("normal_font_size", size)

## ========== 翻译表 ==========

var translations: Dictionary = {

	## ===== 菜单 / 通用 UI =====
	"PAUSED": {"中文": "暂停"},
	"Continue": {"中文": "继续游戏"},
	"Return to Title": {"中文": "回到主菜单"},
	"New Game": {"中文": "新游戏"},
	"Settings": {"中文": "设置"},
	"Collection": {"中文": "收藏"},
	"Tutorial": {"中文": "教程"},
	"Quit Game": {"中文": "退出游戏"},
	"Back": {"中文": "返回"},
	"Start Game": {"中文": "开始游戏"},
	"PROTOTYPE": {"中文": "原型版"},

	## ===== 设置 =====
	"SETTINGS": {"中文": "设置"},
	"Master Volume": {"中文": "主音量"},
	"SFX Volume": {"中文": "音效音量"},
	"Music Volume": {"中文": "音乐音量"},
	"Language": {"中文": "语言"},
	"Graphics settings coming soon...": {"中文": "图形设置即将推出..."},

	## ===== 收藏 =====
	"COLLECTION": {"中文": "收藏"},
	"Joker Cards": {"中文": "小丑牌"},
	"Planet Cards": {"中文": "星球牌"},
	"Tarot Cards": {"中文": "塔罗牌"},

	## ===== 教程 =====
	"HOW TO PLAY": {"中文": "游戏说明"},
	"Goal": {"中文": "目标"},
	"Reach the target score before running out of hands.": {"中文": "在出牌次数用完前达到目标分数。"},
	"Hands": {"中文": "出牌"},
	"Select up to 5 cards to play poker hands.": {"中文": "选择最多5张牌组成牌型出牌。"},
	"Scoring": {"中文": "计分"},
	"Chips × Mult = Score. Better hands = more points.": {"中文": "筹码 × 倍率 = 得分。牌型越好分数越高。"},
	"Discard": {"中文": "弃牌"},
	"Discard unwanted cards to draw new ones.": {"中文": "弃掉不需要的牌，抽取新牌。"},
	"Jokers": {"中文": "小丑牌"},
	"Buy Jokers in the shop for permanent bonuses.": {"中文": "在商店购买小丑牌获得永久加成。"},
	"Planets": {"中文": "星球牌"},
	"Planet cards level up hand types permanently.": {"中文": "星球牌可永久提升牌型等级。"},
	"Tarots": {"中文": "塔罗牌"},
	"Tarot cards modify your hand cards.": {"中文": "塔罗牌可修改手牌。"},
	"Shop": {"中文": "商店"},
	"After each round, buy Jokers and consumables.": {"中文": "每回合后可购买小丑牌和消耗品。"},
	"Blinds": {"中文": "盲注"},
	"Small → Big → Boss. Skip for rewards.": {"中文": "小盲 → 大盲 → Boss。跳过可获奖励。"},
	"Victory": {"中文": "胜利"},
	"Clear all 8 Antes to win!": {"中文": "通过全部8回合即可获胜！"},

	## ===== 盲注选择界面 =====
	"ANTE": {"中文": "回合"},
	"Small Blind": {"中文": "小盲注"},
	"Big Blind": {"中文": "大盲注"},
	"Boss Blind": {"中文": "Boss盲注"},
	"Target": {"中文": "目标"},
	"Reward": {"中文": "奖励"},
	"Play": {"中文": "挑战"},
	"Skip": {"中文": "跳过"},
	"Skip reward": {"中文": "跳过奖励"},
	"Free Tarot": {"中文": "免费塔罗牌"},
	"Free Planet": {"中文": "免费星球牌"},
	"$3 Bonus": {"中文": "$3 奖金"},
	"Level Up": {"中文": "牌型升级"},

	## ===== 游戏主界面 =====
	"Play Hand": {"中文": "出牌"},
	"Select cards and Play": {"中文": "选牌并出牌"},
	"Round Score": {"中文": "本轮得分"},
	"Hands Left": {"中文": "剩余出牌"},
	"Discards Left": {"中文": "剩余弃牌"},
	"Sort by Rank": {"中文": "按点数排序"},
	"Sort by Suit": {"中文": "按花色排序"},
	"Money": {"中文": "金钱"},
	"Ante": {"中文": "回合"},

	## ===== 商店 =====
	"SHOP": {"中文": "商店"},
	"JOKERS": {"中文": "小丑牌"},
	"Use": {"中文": "使用"},
	"Use tarots during gameplay!": {"中文": "塔罗牌需在对局中使用！"},
	"Left: Use": {"中文": "左键使用"},
	"Right: Sell": {"中文": "右键出售"},
	"Select": {"中文": "选择"},
	"cards": {"中文": "张牌"},
	"CONSUMABLES": {"中文": "消耗品"},
	"YOUR JOKERS": {"中文": "持有小丑"},
	"YOUR CONSUMABLES": {"中文": "持有消耗品"},
	"Reroll": {"中文": "刷新"},
	"Next Round": {"中文": "下一回合"},
	"Not enough money!": {"中文": "金钱不足！"},
	"Joker slots full!": {"中文": "小丑栏已满！"},
	"Consumable slots full!": {"中文": "消耗品栏已满！"},
	"Purchased": {"中文": "已购买"},
	"Sold": {"中文": "已卖出"},
	"click to sell": {"中文": "点击出售"},
	"Sell": {"中文": "出售"},

	## ===== 回合结果 =====
	"ROUND WON!": {"中文": "回合胜利！"},
	"GAME OVER": {"中文": "游戏结束"},
	"You reached": {"中文": "你达到了"},
	"Target was": {"中文": "目标是"},
	"Cash earned": {"中文": "获得金钱"},
	"Interest": {"中文": "利息"},
	"Total": {"中文": "总计"},

	## ===== 胜利庆祝 =====
	"CONGRATULATIONS!": {"中文": "恭喜通关！"},
	"Click to return to title": {"中文": "点击返回标题画面"},
	"All 8 Antes Cleared!": {"中文": "全部8个回合已通过！"},
	"Click anywhere to continue...": {"中文": "点击任意处继续..."},

	## ===== 牌型名称 =====
	"High Card": {"中文": "高牌"},
	"Pair": {"中文": "对子"},
	"Two Pair": {"中文": "两对"},
	"Three of a Kind": {"中文": "三条"},
	"Straight": {"中文": "顺子"},
	"Flush": {"中文": "同花"},
	"Full House": {"中文": "葫芦"},
	"Four of a Kind": {"中文": "四条"},
	"Straight Flush": {"中文": "同花顺"},
	"Royal Flush": {"中文": "皇家同花顺"},
	"Five of a Kind": {"中文": "五条"},
	"Flush House": {"中文": "同花葫芦"},
	"Flush Five": {"中文": "同花五条"},

	## ===== 小丑牌名称 =====
	"Joker": {"中文": "小丑"},
	"Greedy Joker": {"中文": "贪婪小丑"},
	"Lusty Joker": {"中文": "色欲小丑"},
	"Wrathful Joker": {"中文": "愤怒小丑"},
	"Glutton Joker": {"中文": "暴食小丑"},
	"Jolly Joker": {"中文": "欢乐小丑"},
	"Zany Joker": {"中文": "疯狂小丑"},
	"The Duo": {"中文": "双人组"},
	"Sly Joker": {"中文": "狡猾小丑"},
	"Banner": {"中文": "旗帜"},
	"Mystic Summit": {"中文": "神秘峰顶"},
	"Fibonacci": {"中文": "斐波那契"},
	"Scary Face": {"中文": "骇人面孔"},
	"Even Steven": {"中文": "偶数史蒂文"},
	"Odd Todd": {"中文": "奇数托德"},
	"The Trio": {"中文": "三人组"},

	## ===== 小丑牌描述 =====
	"+4 Mult": {"中文": "+4 倍率"},
	"+3 Mult for each ♦ scored": {"中文": "每张计分♦ +3倍率"},
	"+3 Mult for each ♥ scored": {"中文": "每张计分♥ +3倍率"},
	"+3 Mult for each ♠ scored": {"中文": "每张计分♠ +3倍率"},
	"+3 Mult for each ♣ scored": {"中文": "每张计分♣ +3倍率"},
	"+8 Mult if hand is Pair": {"中文": "打出对子时 +8倍率"},
	"+12 Mult if Three of a Kind": {"中文": "打出三条时 +12倍率"},
	"×2 Mult if hand contains a Pair": {"中文": "牌型含对子时 ×2倍率"},
	"+50 Chips": {"中文": "+50 筹码"},
	"+30 Chips per discard remaining": {"中文": "每剩余1次弃牌 +30筹码"},
	"+15 Mult when 0 discards remaining": {"中文": "剩余弃牌为0时 +15倍率"},
	"+8 Mult for each A,2,3,5,8 scored": {"中文": "每张计分A/2/3/5/8 +8倍率"},
	"+30 Chips for each face card scored": {"中文": "每张计分人头牌 +30筹码"},
	"+4 Mult for each even card scored": {"中文": "每张计分偶数牌 +4倍率"},
	"+30 Chips for each odd card scored": {"中文": "每张计分奇数牌 +30筹码"},
	"×3 Mult if hand contains Three of a Kind": {"中文": "牌型含三条时 ×3倍率"},

	## ----- 卡牌增强 -----
	"Foil": {"中文": "箔片"},
	"Holographic": {"中文": "全息"},
	"Polychrome": {"中文": "多彩"},
	"Enhancement": {"中文": "增强"},

	## ----- 增强类塔罗牌名称 -----
	"The Empress": {"中文": "女皇"},
	"The Emperor": {"中文": "皇帝"},
	"Temperance": {"中文": "节制"},
	"The High Priestess": {"中文": "女祭司"},
	"The Hierophant": {"中文": "教皇"},
	"Justice": {"中文": "正义"},
	"Strength": {"中文": "力量"},
	"The Hanged Man": {"中文": "倒吊人"},
	"The Devil": {"中文": "恶魔"},
	"The Moon": {"中文": "月亮"},

	## ----- 增强类塔罗牌描述 -----
	"Add Foil to 1 card (+50 Chips)": {"中文": "为1张牌添加箔片 (+50筹码)"},
	"Add Holo to 1 card (+10 Mult)": {"中文": "为1张牌添加全息 (+10倍率)"},
	"Add Holographic to 1 card (+10 Mult)": {"中文": "为1张牌添加全息 (+10倍率)"},
	"Add Polychrome to 1 card (×1.5 Mult)": {"中文": "为1张牌添加多彩 (×1.5倍率)"},
	"Enhance 1 card with Bonus (+30 Chips)": {"中文": "为1张牌添加奖励 (+30筹码)"},
	"Enhance 1 card with Mult (+4 Mult)": {"中文": "为1张牌添加倍率 (+4倍率)"},
	"Enhance 1 card with Wild": {"中文": "为1张牌添加万能（可当任意花色）"},
	"Enhance 1 card with Glass (×2 Mult, may break)": {"中文": "为1张牌添加玻璃 (×2倍率，可能碎裂)"},
	"Enhance 1 card with Steel (×1.5 Mult while in hand)": {"中文": "为1张牌添加钢铁 (在手时×1.5倍率)"},
	"Enhance 1 card with Stone (+50 Chips, no rank)": {"中文": "为1张牌添加石头 (+50筹码，无点数)"},
	"Enhance 1 card with Gold ($3 when held)": {"中文": "为1张牌添加金箔 (持有时+$3)"},

	## ----- Voucher 系统 -----
	"VOUCHER": {"中文": "优惠券"},
	"Voucher": {"中文": "优惠券"},

	## ----- Voucher 名称 -----
	"Overstock": {"中文": "库存过剩"},
	"Clearance Sale": {"中文": "清仓大甩卖"},
	"Hone": {"中文": "磨砺"},
	"Reroll Surplus": {"中文": "刷新盈余"},
	"Crystal Ball": {"中文": "水晶球"},
	"Telescope": {"中文": "望远镜"},
	"Grabber": {"中文": "抓取者"},
	"Wasteful": {"中文": "挥霍者"},

	## ----- Voucher 描述 -----
	"+1 Joker slot": {"中文": "+1小丑栏位"},
	"10% discount on shop items": {"中文": "商店物品打9折"},
	"+1 Hand per round": {"中文": "每回合+1手牌"},
	"-$2 Reroll cost": {"中文": "刷新费用-$2"},
	"+1 Consumable slot": {"中文": "+1消耗品栏位"},
	"Interest cap raised to $10": {"中文": "利息上限提升至$10"},
	"+1 Hand per round (stacks)": {"中文": "每回合+1手牌(可叠加)"},
	"+1 Discard per round": {"中文": "每回合+1弃牌"},

	## ----- TAB 状态面板 -----
	"Game Status": {"中文": "本局状态"},
	"Run Status": {"中文": "本局状态"},
	"Owned Vouchers": {"中文": "已拥有优惠券"},
	"None": {"中文": "无"},
	"Deck Tracker": {"中文": "牌库追踪"},
	"Played": {"中文": "已出"},
	"Remaining": {"中文": "剩余"},

	## ----- 右键出售 -----
	"Right click to sell": {"中文": "右键出售"},

	## ===== 塔罗牌名称 =====
	"The Fool": {"中文": "愚者"},
	"The Magician": {"中文": "魔术师"},
	"The Lovers": {"中文": "恋人"},
	"The Chariot": {"中文": "战车"},
	"The Tower": {"中文": "塔"},
	"The Star": {"中文": "星星"},
	"Death": {"中文": "死神"},
	"The Hermit": {"中文": "隐者"},
	"Judgement": {"中文": "审判"},
	"The World": {"中文": "世界"},
	"The Sun": {"中文": "太阳"},
	"Wheel of Fortune": {"中文": "命运之轮"},

	## ===== 塔罗牌描述 =====
	"Copy 1 selected card": {"中文": "复制1张选中的牌"},
	"Change 1 card to random suit": {"中文": "将1张牌变为随机花色"},
	"Change up to 3 cards to ♥": {"中文": "将最多3张牌变为♥"},
	"Change up to 3 cards to ♠": {"中文": "将最多3张牌变为♠"},
	"Change up to 3 cards to ♣": {"中文": "将最多3张牌变为♣"},
	"Change up to 3 cards to ♦": {"中文": "将最多3张牌变为♦"},
	"Destroy 1 selected card": {"中文": "销毁1张选中的牌"},
	"Gain $5": {"中文": "获得$5"},
	"Left card becomes copy of right card": {"中文": "左边的牌变为右边牌的副本"},
	"Create 2 random Tarot cards": {"中文": "生成2张随机塔罗牌"},
	"Create 2 random Planet cards": {"中文": "生成2张随机星球牌"},
	"Level up a random hand type ×2": {"中文": "随机牌型升级×2"},

	## ===== 星球牌名称 =====
	"Moon": {"中文": "月球"},
	"Mercury": {"中文": "水星"},
	"Uranus": {"中文": "天王星"},
	"Venus": {"中文": "金星"},
	"Saturn": {"中文": "土星"},
	"Jupiter": {"中文": "木星"},
	"Earth": {"中文": "地球"},
	"Mars": {"中文": "火星"},
	"Neptune": {"中文": "海王星"},

	## ===== 星球牌描述 =====
	"Upgrades High Card": {"中文": "升级高牌"},
	"Upgrades Pair": {"中文": "升级对子"},
	"Upgrades Two Pair": {"中文": "升级两对"},
	"Upgrades Three of a Kind": {"中文": "升级三条"},
	"Upgrades Straight": {"中文": "升级顺子"},
	"Upgrades Flush": {"中文": "升级同花"},
	"Upgrades Full House": {"中文": "升级葫芦"},
	"Upgrades Four of a Kind": {"中文": "升级四条"},
	"Upgrades Straight Flush": {"中文": "升级同花顺"},

	## ===== Boss 盲注 =====
	"The Hook": {"中文": "钩子"},
	"The Wall": {"中文": "墙壁"},
	"The Eye": {"中文": "眼睛"},
	"The Mouth": {"中文": "嘴巴"},
	"The Plant": {"中文": "植物"},
	"The Serpent": {"中文": "蛇"},
	"The Ox": {"中文": "公牛"},
	"The Needle": {"中文": "针"},

	## ===== Boss 效果描述 =====
	"Only 3 hands this round": {"中文": "本轮只有3次出牌机会"},
	"No discards this round": {"中文": "本轮无法弃牌"},
	"Face cards score no chips": {"中文": "人头牌（J/Q/K）不计分"},
	"Hearts don't score": {"中文": "♥不计分"},
	"Clubs don't score": {"中文": "♣不计分"},
	"Spades don't score": {"中文": "♠不计分"},
	"Diamonds don't score": {"中文": "♦不计分"},
	"First hand played scores half": {"中文": "第一手牌得分减半"},

	## ===== 扑克牌花色 =====
	"Spades": {"中文": "黑桃"},
	"Hearts": {"中文": "红心"},
	"Diamonds": {"中文": "方块"},
	"Clubs": {"中文": "梅花"},

	## ===== 消耗品相关 =====
	"USE": {"中文": "使用"},
	"Select cards first": {"中文": "请先选择牌"},

	## ===== 计分显示 =====
	"Chips": {"中文": "筹码"},
	"Mult": {"中文": "倍率"},
	"Score": {"中文": "得分"},
	"Lvl": {"中文": "等级"},

	## ===== 其他提示 =====
	"BOSS": {"中文": "Boss"},
	"No valid hand": {"中文": "无有效牌型"},
	"Select 1-5 cards": {"中文": "选择1-5张牌"},
	"Deck": {"中文": "牌堆"},
	"cards left": {"中文": "张剩余"},

	## ===== 盲注选择补充 =====
	"Receive a random Tarot card": {"中文": "获得一张随机塔罗牌"},
	"Receive a random Planet card": {"中文": "获得一张随机星球牌"},
	"Receive $3": {"中文": "获得$3"},
	"Random hand type +1 level": {"中文": "随机牌型等级+1"},
	"Standard game": {"中文": "标准游戏"},
	"1.5× score target": {"中文": "目标分数×1.5"},

	## ===== 回合结果 =====
	"BLIND DEFEATED!": {"中文": "盲注已击败"},
	"EARNINGS": {"中文": "收入"},
	"Go to Shop": {"中文": "前往商店"},
	"Try Again": {"中文": "再试一次"},

	## ===== 计分面板 =====
	"TARGET": {"中文": "目标"},
	"ROUND SCORE": {"中文": "本轮得分"},
	"plays to next level": {"中文": "次后升级"},
	"DRAW": {"中文": "抽牌堆"},
	"DISCARD": {"中文": "弃牌堆"},

	## ===== 商店详细 =====
	"Not enough money to reroll!": {"中文": "金钱不足，无法刷新！"},
	"Max": {"中文": "上限"},
	"for": {"中文": "售价"},
	"Common": {"中文": "普通"},
	"Uncommon": {"中文": "罕见"},
	"Rare": {"中文": "稀有"},
	"Legendary": {"中文": "传说"},

	## ===== 塔罗使用反馈 =====
	"Copied": {"中文": "已复制"},
	"Changed to": {"中文": "已变为"},
	"Destroyed": {"中文": "已销毁"},
	"grants": {"中文": "获得"},
	"Card transformed to": {"中文": "牌已变为"},
	"No empty slots!": {"中文": "无空余栏位！"},
	"Created": {"中文": "已生成"},
	"leveled up to": {"中文": "已升级至"},
	"Skip reward:": {"中文": "跳过奖励："},
	"Consumable slots full — reward lost!": {"中文": "消耗品栏已满——奖励丢失！"},
}

## 翻译函数
func t(key: String) -> String:
	if current_language == "English":
		return key
	if translations.has(key) and translations[key].has(current_language):
		return translations[key][current_language]
	return key
