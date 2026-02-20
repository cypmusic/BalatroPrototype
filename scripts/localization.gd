## localization.gd
## 完整本地化系统 V0.085 — 覆盖游戏全部文本
## 72异兽 + 26法宝 + 10幽冥 + 28星宿 + 16天书 + 28牌型 + 4灵印
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
	"Beast Cards": {"中文": "异兽牌"},
	"Constellation Cards": {"中文": "星宿牌"},
	"Artifact Cards": {"中文": "法宝牌"},
	"Specter Cards": {"中文": "幽冥牌"},
	"Celestial Tomes": {"中文": "天书"},

	## ===== 教程 =====
	"HOW TO PLAY": {"中文": "游戏说明"},
	"Goal": {"中文": "目标"},
	"Reach the target score before running out of hands.": {"中文": "在出牌次数用完前达到目标分数。"},
	"Hands": {"中文": "出牌"},
	"Select up to 5 cards to play poker hands.": {"中文": "选择最多5张牌组成牌型出牌。"},
	"Select up to 6 cards to play poker hands.": {"中文": "选择最多6张牌组成牌型出牌。"},
	"Scoring": {"中文": "计分"},
	"Chips × Mult = Score. Better hands = more points.": {"中文": "筹码 × 倍率 = 得分。牌型越好分数越高。"},
	"Discard": {"中文": "弃牌"},
	"Discard unwanted cards to draw new ones.": {"中文": "弃掉不需要的牌，抽取新牌。"},
	"Beasts": {"中文": "异兽牌"},
	"Buy Beasts in the shop for permanent bonuses.": {"中文": "在商店购买异兽牌获得永久加成。"},
	"Constellations": {"中文": "星宿牌"},
	"Constellation cards level up hand types permanently.": {"中文": "星宿牌可永久提升牌型等级。"},
	"Artifacts": {"中文": "法宝牌"},
	"Artifact cards modify your hand cards.": {"中文": "法宝牌可修改手牌。"},
	"Specters": {"中文": "幽冥牌"},
	"Specter cards have powerful but destructive effects.": {"中文": "幽冥牌拥有强大但具有破坏性的效果。"},
	"Shop": {"中文": "商店"},
	"After each round, buy Beasts and consumables.": {"中文": "每回合后可购买异兽牌和消耗品。"},
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
	"Free Artifact": {"中文": "免费法宝牌"},
	"Free Constellation": {"中文": "免费星宿牌"},
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
	"BEASTS": {"中文": "异兽牌"},
	"Use": {"中文": "使用"},
	"Use artifacts during gameplay!": {"中文": "法宝牌需在对局中使用！"},
	"Left: Use": {"中文": "左键使用"},
	"Right: Sell": {"中文": "右键出售"},
	"Select": {"中文": "选择"},
	"cards": {"中文": "张牌"},
	"CONSUMABLES": {"中文": "消耗品"},
	"YOUR BEASTS": {"中文": "持有异兽"},
	"YOUR CONSUMABLES": {"中文": "持有消耗品"},
	"Reroll": {"中文": "刷新"},
	"Next Round": {"中文": "下一回合"},
	"Not enough money!": {"中文": "金钱不足！"},
	"Beast slots full!": {"中文": "异兽栏已满！"},
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

	## ============================================================
	## 牌型名称 — 28种 (9基础5卡 + 19扩展含6卡)
	## ============================================================

	## --- 基础5卡牌型 ---
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
	## --- 扩展5卡/6卡牌型 ---
	"Five of a Kind": {"中文": "五条"},
	"Flush House": {"中文": "同花葫芦"},
	"Flush Five": {"中文": "同花五条"},
	"Double Three": {"中文": "双三条"},
	"Triple Pair": {"中文": "三对"},
	"Four-One-One": {"中文": "四带二单"},
	"Full House Plus": {"中文": "大葫芦"},
	"Straight Six": {"中文": "六连顺"},
	"Flush Six": {"中文": "六花"},
	"Straight Flush Six": {"中文": "六连同花顺"},
	"Full Flush": {"中文": "满花"},
	"Four-Two": {"中文": "四带一对"},
	"Two-Three": {"中文": "二三"},
	"Pair-Four": {"中文": "对加四条"},
	"Royal Flush Six": {"中文": "六皇家同花顺"},
	"Six of a Kind": {"中文": "六条"},
	"Flush Six of a Kind": {"中文": "同花六条"},
	"Royal Six of a Kind": {"中文": "皇家六条"},

	## ============================================================
	## 灵印 (Seals) — 4种
	## ============================================================
	"Azure Dragon Seal": {"中文": "青龙印"},
	"Vermillion Bird Seal": {"中文": "朱雀印"},
	"White Tiger Seal": {"中文": "白虎印"},
	"Black Tortoise Seal": {"中文": "玄武印"},

	## ============================================================
	## 异兽牌名称 — 72张 (30普通 + 24罕见 + 14稀有 + 4传奇)
	## ============================================================

	## --- 青龙♠ 普通 (8) ---
	"Fei Dan": {"中文": "飞诞"},
	"Man Man": {"中文": "蛮蛮"},
	"Bo Tuo": {"中文": "猼訑"},
	"Tian Gou": {"中文": "天狗"},
	"Jing Wei": {"中文": "精卫"},
	"Zhu Jian": {"中文": "诸犍"},
	"Ju Fu": {"中文": "举父"},
	"Feng Huang Chu": {"中文": "凤凰雏"},

	## --- 朱雀♥ 普通 (8) ---
	"Chi Ru": {"中文": "赤鱬"},
	"Qi Tu": {"中文": "鵸鵌"},
	"Bi Yi Niao": {"中文": "比翼鸟"},
	"Huo Shu": {"中文": "火鼠"},
	"Zhu Niao": {"中文": "朱鸟"},
	"Huan Tou": {"中文": "讙头国人"},
	"Kua Fu": {"中文": "夸父"},
	"Chong Ming Niao": {"中文": "重明鸟"},

	## --- 白虎♦ 普通 (7) ---
	"Xing Xing": {"中文": "狌狌"},
	"Qian Yang": {"中文": "羬羊"},
	"Jin Wu": {"中文": "金乌"},
	"Bai Lu": {"中文": "白鹿"},
	"Tu Shu": {"中文": "䑏疏"},
	"Hao Zhi": {"中文": "豪彘"},
	"Ning Shi Shou": {"中文": "凝时兽"},

	## --- 玄武♣ 普通 (7) ---
	"Long Zhi": {"中文": "蠪侄"},
	"Wen Yao Yu": {"中文": "文鳐鱼"},
	"Qing Niao": {"中文": "青鸟"},
	"Shui Qi Lin": {"中文": "水麒麟"},
	"Chi Long": {"中文": "螭龙"},
	"Bai Sha": {"中文": "白鲨"},
	"Huan Xi Shou": {"中文": "缓息兽"},

	## --- 青龙♠ 罕见 (6) ---
	"Dang Kang": {"中文": "当康"},
	"Fei Yi": {"中文": "肥遗"},
	"Li Li": {"中文": "狸力"},
	"Hua She": {"中文": "化蛇"},
	"Huan": {"中文": "讙"},
	"Lu Shu": {"中文": "鹿蜀"},

	## --- 朱雀♥ 罕见 (6) ---
	"Luan Niao": {"中文": "鸾鸟"},
	"Bi Fang Ming": {"中文": "毕方鸣"},
	"Fei Lian": {"中文": "飞廉"},
	"Huo Dou": {"中文": "祸斗"},
	"Zhu Nao": {"中文": "朱獳"},
	"Zou Wu": {"中文": "驺吾"},

	## --- 白虎♦ 罕见 (6) ---
	"Suan Ni": {"中文": "狻猊"},
	"Xie Zhi": {"中文": "獬豸"},
	"Qiong Qi": {"中文": "穷奇"},
	"Ya Zi": {"中文": "睚眦"},
	"Ya Yu": {"中文": "猰貐"},
	"Qi Lin": {"中文": "麒麟"},

	## --- 玄武♣ 罕见 (6) ---
	"Xuan She": {"中文": "玄蛇"},
	"Ba She": {"中文": "巴蛇"},
	"Ying Yu": {"中文": "赢鱼"},
	"Teng She": {"中文": "腾蛇"},
	"Ran Yi Yu": {"中文": "冉遗鱼"},
	"Jiao Long": {"中文": "蛟龙"},

	## --- 青龙♠ 稀有 (3) ---
	"Ying Long": {"中文": "应龙"},
	"Zhu Long": {"中文": "烛龙"},
	"Gou Mang": {"中文": "句芒"},

	## --- 朱雀♥ 稀有 (3) ---
	"Jiu Wei Hu": {"中文": "九尾狐"},
	"Zhu Yan": {"中文": "朱厌"},
	"Du Yu": {"中文": "毒蜮"},

	## --- 白虎♦ 稀有 (4) ---
	"Pi Xiu": {"中文": "貔貅"},
	"Zheng": {"中文": "狰"},
	"Ying Zhao": {"中文": "英招"},
	"Lu Wu": {"中文": "陆吾"},

	## --- 玄武♣ 稀有 (4) ---
	"Xuan Gui": {"中文": "旋龟"},
	"Jiao Ren": {"中文": "鲛人"},
	"Xiang Liu": {"中文": "相柳"},
	"Luo Yu": {"中文": "蠃鱼"},

	## --- 传奇 (4) ---
	"Taotie, the Insatiable": {"中文": "饕餮·贪食"},
	"Bifang, the Fire Herald": {"中文": "毕方·火使"},
	"Baize, the All-Knowing": {"中文": "白泽·博识"},
	"Xuangui, the Eternal Shell": {"中文": "玄龟·不灭"},

	## ============================================================
	## 异兽牌描述 — 72张
	## ============================================================

	## --- 青龙♠ 普通描述 ---
	"+4 Mult": {"中文": "+4 倍率"},
	"+30 Chips": {"中文": "+30 筹码"},
	"+6 Mult": {"中文": "+6 倍率"},
	"+3 Mult for each scored Spade": {"中文": "每张计分♠牌 +3倍率"},
	"Permanently +1 Mult each hand played": {"中文": "每次出牌永久+1倍率"},
	"+12 Mult if Three of a Kind": {"中文": "打出三条时 +12倍率"},
	"+4 Mult per remaining discard": {"中文": "每剩余1次弃牌 +4倍率"},
	"Boss play timer +4 bars": {"中文": "Boss战时限+4小节"},

	## --- 朱雀♥ 普通描述 ---
	"+5 Mult": {"中文": "+5 倍率"},
	"+40 Chips": {"中文": "+40 筹码"},
	"+3 Mult for each scored Heart": {"中文": "每张计分♥牌 +3倍率"},
	"+8 Mult if Pair": {"中文": "打出对子时 +8倍率"},
	"+30 Chips for each odd card scored": {"中文": "每张计分奇数牌 +30筹码"},
	"+$6 extra when sold": {"中文": "卖出时额外+$6"},
	"+15 Mult when 0 discards remain": {"中文": "弃牌剩余0时 +15倍率"},
	"+30 Chips per remaining play": {"中文": "每剩余1次出牌 +30筹码"},

	## --- 白虎♦ 普通描述 ---
	"+50 Chips": {"中文": "+50 筹码"},
	"+3 Mult for each scored Diamond": {"中文": "每张计分♦牌 +3倍率"},
	"+$2 at end of round": {"中文": "回合结束时+$2"},
	"+$3 at end of round": {"中文": "回合结束时+$3"},
	"+4 Mult for each face card scored": {"中文": "每张计分人头牌 +4倍率"},
	"Reel Draw A-slot half speed": {"中文": "天机A牌速度减半"},

	## --- 玄武♣ 普通描述 ---
	"+8 Mult": {"中文": "+8 倍率"},
	"+20 Chips": {"中文": "+20 筹码"},
	"+3 Mult for each scored Club": {"中文": "每张计分♣牌 +3倍率"},
	"+15 Mult if Two Pair": {"中文": "打出两对时 +15倍率"},
	"+8 Mult for Fibonacci cards (A/2/3/5/8)": {"中文": "斐波那契牌(A/2/3/5/8)计分时 +8倍率"},
	"Boss: +2 bars per card drawn": {"中文": "Boss战补牌+2小节/张"},

	## --- 青龙♠ 罕见描述 ---
	"+4 Mult for each scored Spade": {"中文": "每张计分♠牌 +4倍率"},
	"Permanently +2 Mult per Flush played": {"中文": "每打出同花永久+2倍率"},
	"Permanently +3 Chips per discard": {"中文": "每次弃牌永久+3筹码"},
	"Boss play timer +8 bars": {"中文": "Boss战时限+8小节"},
	"Boss: auto-snap to beat (Good guarantee)": {"中文": "Boss战自动对齐节拍"},
	"x2 Mult when playing Straight": {"中文": "打出顺子时 ×2倍率"},

	## --- 朱雀♥ 罕见描述 ---
	"+4 Mult for each scored Heart": {"中文": "每张计分♥牌 +4倍率"},
	"x1.5 Mult when holding $20+": {"中文": "持有$20+时 ×1.5倍率"},
	"+8 Mult for each even card scored": {"中文": "每张计分偶数牌 +8倍率"},
	"After selling, next hand x3 Mult": {"中文": "卖出后下一手 ×3倍率"},
	"Perfect beat bonus: 130%": {"中文": "Perfect节拍加成130%"},
	"x1.5 Mult when hand contains Pair": {"中文": "牌型含对子时 ×1.5倍率"},

	## --- 白虎♦ 罕见描述 ---
	"+4 Mult for each scored Diamond": {"中文": "每张计分♦牌 +4倍率"},
	"+$1 for each face card scored": {"中文": "每张计分人头牌+$1"},
	"+$4 at end of round": {"中文": "回合结束时+$4"},
	"Reel A-slot: face cards only": {"中文": "天机A牌只出人头牌"},
	"Reel A-slot: only Diamonds": {"中文": "天机A牌只出♦"},
	"+50 Chips for each face card scored": {"中文": "每张计分人头牌 +50筹码"},

	## --- 玄武♣ 罕见描述 ---
	"+4 Mult for each scored Club": {"中文": "每张计分♣牌 +4倍率"},
	"Spade cards retrigger once": {"中文": "♠计分牌重触发1次"},
	"Even cards retrigger once": {"中文": "偶数牌重触发1次"},
	"Copy left Beast's effect": {"中文": "复制左侧异兽效果"},
	"+1 extra A-tier Reel Draw on redraw": {"中文": "补牌时额外天机A级抽牌"},

	## --- 青龙♠ 稀有描述 ---
	"Per boss beaten: permanently +x0.2 Mult": {"中文": "每击败Boss永久+×0.2倍率"},
	"Boss: +3 Mult per bar (max +48)": {"中文": "Boss战中每小节+3倍率(上限+48)"},
	"x1.5 Mult": {"中文": "×1.5 倍率"},

	## --- 朱雀♥ 稀有描述 ---
	"x3 Mult on Full House or better": {"中文": "打出葫芦或更强时 ×3倍率"},
	"x2 Mult on first hand each round": {"中文": "每轮首手 ×2倍率"},
	"After 3 blinds: self-destruct, all cards +1 Mult": {"中文": "3盲注后自毁，全牌组永久+1倍率"},

	## --- 白虎♦ 稀有描述 ---
	"Interest cap raised to $10": {"中文": "利息上限提升至$10"},
	"x1.3 Mult for each low card (2-5) scored": {"中文": "每张低牌(2-5)计分 ×1.3倍率"},
	"Reel C-slot: preview next 2 cards": {"中文": "天机C牌预见后续2张"},
	"Copy strongest additive Beast effect": {"中文": "复制最强加法异兽效果"},

	## --- 玄武♣ 稀有描述 ---
	"Face cards retrigger once": {"中文": "人头牌(J/Q/K)重触发1次"},
	"Club cards retrigger once": {"中文": "♣计分牌重触发1次"},
	"Boss BPM reduced by 1 tier": {"中文": "Boss战BPM降一档"},
	"Each round: become a random sold Beast": {"中文": "每轮变为已卖出异兽"},

	## --- 传奇描述 ---
	"Sell a Beast: permanently +Mult equal to sell price": {"中文": "卖出异兽：永久+等值售价倍率"},
	"When sold, copy the Beast to the left": {"中文": "卖出时复制左侧异兽"},
	"Reel Draw becomes 4 draws (A/B/C/D)": {"中文": "天机抽牌变4次(A/B/C/D)"},
	"All scoring cards retrigger once": {"中文": "所有计分牌重触发1次"},

	## ============================================================
	## 法宝牌名称 — 26张 (16神器 + 10阵法)
	## ============================================================

	## --- 神器 (16) ---
	"Seal of Heaven's Overthrow": {"中文": "翻天印"},
	"Diagram of the Supreme Ultimate": {"中文": "太极图"},
	"Ring of Heaven and Earth": {"中文": "乾坤圈"},
	"Primordial Golden Vessel": {"中文": "混元金斗"},
	"Sea-Calming Pearls": {"中文": "定海珠"},
	"Immortal-Slaying Sword": {"中文": "斩仙剑"},
	"Demon-Revealing Mirror": {"中文": "照妖镜"},
	"Map of Mountains and Rivers": {"中文": "山河社稷图"},
	"Nine-Dragon Divine Fire Canopy": {"中文": "九龙神火罩"},
	"Wind-Fire Wheels": {"中文": "风火轮"},
	"Exquisite Pagoda": {"中文": "玲珑宝塔"},
	"Treasure-Felling Gold Coin": {"中文": "落宝金钱"},
	"Azure Dragon Talisman": {"中文": "青龙符"},
	"Vermillion Bird Talisman": {"中文": "朱雀符"},
	"White Tiger Talisman": {"中文": "白虎符"},
	"Black Tortoise Talisman": {"中文": "玄武符"},

	## --- 阵法 (10) ---
	"Immortal-Execution Formation": {"中文": "诛仙阵"},
	"Ten Lethal Formations": {"中文": "十绝阵"},
	"Formation of Ten Thousand Immortals": {"中文": "万仙阵"},
	"Nine-Bend Yellow River Formation": {"中文": "九曲黄河阵"},
	"Crimson Water Formation": {"中文": "红水阵"},
	"Heaven-Severing Formation": {"中文": "天绝阵"},
	"Earth-Splitting Formation": {"中文": "地烈阵"},
	"Howling Wind Formation": {"中文": "风吼阵"},
	"Glacial Ice Formation": {"中文": "寒冰阵"},
	"Soul-Shattering Formation": {"中文": "落魂阵"},

	## ============================================================
	## 法宝牌描述 — 26张
	## ============================================================

	## --- 神器描述 ---
	"Change 1 card to random suit": {"中文": "将1张牌变为随机花色"},
	"Change up to 3 cards to ♠": {"中文": "将最多3张牌变为♠"},
	"Change up to 3 cards to ♥": {"中文": "将最多3张牌变为♥"},
	"Change up to 3 cards to ♦": {"中文": "将最多3张牌变为♦"},
	"Change up to 3 cards to ♣": {"中文": "将最多3张牌变为♣"},
	"Destroy 1 selected card": {"中文": "销毁1张选中的牌"},
	"Copy 1 card into your deck": {"中文": "复制1张牌到牌组"},
	"Left card becomes copy of right card": {"中文": "左边的牌变为右边牌的副本"},
	"Add Foil to 1 card (+50 Chips)": {"中文": "为1张牌添加箔片 (+50筹码)"},
	"Add Holographic to 1 card (+10 Mult)": {"中文": "为1张牌添加全息 (+10倍率)"},
	"Add Polychrome to 1 card (x1.5 Mult)": {"中文": "为1张牌添加多彩 (×1.5倍率)"},
	"Gain $5": {"中文": "获得$5"},
	"Add Azure Dragon Seal to 1 card": {"中文": "为1张牌添加青龙印"},
	"Add Vermillion Bird Seal to 1 card": {"中文": "为1张牌添加朱雀印"},
	"Add White Tiger Seal to 1 card": {"中文": "为1张牌添加白虎印"},
	"Add Black Tortoise Seal to 1 card": {"中文": "为1张牌添加玄武印"},

	## --- 阵法描述 ---
	"All +Mult becomes xMult this round": {"中文": "本轮所有+Mult变为×Mult"},
	"Disable 2 hand types; others gain x2 Chips": {"中文": "禁用2种牌型，其余×2筹码"},
	"Next shop: all items 50% off": {"中文": "下次商店所有物品半价"},
	"+3 discards this round": {"中文": "本轮+3次弃牌"},
	"All Hearts gain +30 Chips, +4 Mult this round": {"中文": "本轮所有♥牌+30筹码+4倍率"},
	"Create 2 random Artifact cards": {"中文": "生成2张随机法宝牌"},
	"Create 2 random Constellation cards": {"中文": "生成2张随机星宿牌"},
	"Level up 1 random hand type by 2": {"中文": "随机1种牌型升2级"},
	"All Clubs gain +30 Chips, +4 Mult this round": {"中文": "本轮所有♣牌+30筹码+4倍率"},
	"All scored cards gain +2 Mult this round": {"中文": "本轮所有计分牌+2倍率"},

	## ============================================================
	## 幽冥牌名称 — 10张
	## ============================================================
	"Soul-Calling Banner": {"中文": "招魂幡"},
	"Book of Life and Death": {"中文": "生死簿"},
	"Six Paths of Reincarnation": {"中文": "六道轮回"},
	"Soul Possession": {"中文": "夺舍"},
	"Deification": {"中文": "封神"},
	"Heavenly Tribulation": {"中文": "天劫"},
	"Self-Immolation": {"中文": "焚身"},
	"Soul Separation": {"中文": "离魂术"},
	"Clone Technique": {"中文": "分身术"},
	"Yin-Yang Eyes": {"中文": "阴阳眼"},

	## ============================================================
	## 幽冥牌描述 — 10张
	## ============================================================
	"Destroy 1 random card, create 3 random enhanced face cards": {"中文": "销毁1张随机牌，生成3张随机增强人头牌"},
	"Destroy 1 random card, create 4 random enhanced number cards": {"中文": "销毁1张随机牌，生成4张随机增强数字牌"},
	"All cards in hand become a single random suit": {"中文": "手中所有牌变为同一随机花色"},
	"All cards become single random rank, -1 hand size permanently": {"中文": "所有牌变为同一随机点数，手牌上限永久-1"},
	"Create 1 Legendary Beast card": {"中文": "创建1张传说级异兽牌"},
	"Level up ALL hand types by 1": {"中文": "所有牌型等级+1"},
	"Destroy 5 random cards, gain $20": {"中文": "销毁5张随机牌，获得$20"},
	"Random Beast gains Phantom (no slot), -1 hand size": {"中文": "随机1只异兽获得虚相(不占栏位)，手牌上限-1"},
	"Select 1 card, create 2 exact copies in deck": {"中文": "选择1张牌，牌组中创建2张副本"},
	"Selected Beast gains Polychrome (×1.5), destroy all others": {"中文": "选中异兽获得多彩(×1.5)，销毁其余"},

	## ============================================================
	## 星宿牌名称 — 28张 (四象×七宿)
	## ============================================================

	## --- 东方青龙七宿 (♠) ---
	"Horn Star": {"中文": "角宿"},
	"Neck Star": {"中文": "亢宿"},
	"Root Star": {"中文": "氐宿"},
	"Chamber Star": {"中文": "房宿"},
	"Heart Star": {"中文": "心宿"},
	"Tail Star": {"中文": "尾宿"},
	"Winnow Star": {"中文": "箕宿"},

	## --- 北方玄武七宿 (♣) ---
	"Dipper Star": {"中文": "斗宿"},
	"Ox Star": {"中文": "牛宿"},
	"Maiden Star": {"中文": "女宿"},
	"Void Star": {"中文": "虚宿"},
	"Danger Star": {"中文": "危宿"},
	"Hall Star": {"中文": "室宿"},
	"Wall Star": {"中文": "壁宿"},

	## --- 西方白虎七宿 (♦) ---
	"Stride Star": {"中文": "奎宿"},
	"Mound Star": {"中文": "娄宿"},
	"Stomach Star": {"中文": "胃宿"},
	"Hairy Star": {"中文": "昴宿"},
	"Net Star": {"中文": "毕宿"},
	"Beak Star": {"中文": "觜宿"},
	"Trident Star": {"中文": "参宿"},

	## --- 南方朱雀七宿 (♥) ---
	"Well Star": {"中文": "井宿"},
	"Ghost Star": {"中文": "鬼宿"},
	"Willow Star": {"中文": "柳宿"},
	"Star Star": {"中文": "星宿"},
	"Spread Star": {"中文": "张宿"},
	"Wing Star": {"中文": "翼宿"},
	"Chariot Star": {"中文": "轸宿"},

	## ============================================================
	## 星宿牌描述 — 28种升级
	## ============================================================
	"Upgrades High Card": {"中文": "升级高牌"},
	"Upgrades Pair": {"中文": "升级对子"},
	"Upgrades Two Pair": {"中文": "升级两对"},
	"Upgrades Three of a Kind": {"中文": "升级三条"},
	"Upgrades Straight": {"中文": "升级顺子"},
	"Upgrades Flush": {"中文": "升级同花"},
	"Upgrades Full House": {"中文": "升级葫芦"},
	"Upgrades Four of a Kind": {"中文": "升级四条"},
	"Upgrades Straight Flush": {"中文": "升级同花顺"},
	"Upgrades Five of a Kind": {"中文": "升级五条"},
	"Upgrades Flush House": {"中文": "升级同花葫芦"},
	"Upgrades Flush Five": {"中文": "升级同花五条"},
	"Upgrades Double Three": {"中文": "升级双三条"},
	"Upgrades Triple Pair": {"中文": "升级三对"},
	"Upgrades Four-One-One": {"中文": "升级四带二单"},
	"Upgrades Full House Plus": {"中文": "升级大葫芦"},
	"Upgrades Straight Six": {"中文": "升级六连顺"},
	"Upgrades Flush Six": {"中文": "升级六花"},
	"Upgrades Straight Flush Six": {"中文": "升级六连同花顺"},
	"Upgrades Full Flush": {"中文": "升级满花"},
	"Upgrades Royal Flush": {"中文": "升级皇家同花顺"},
	"Upgrades Four-Two": {"中文": "升级四带一对"},
	"Upgrades Two-Three": {"中文": "升级二三"},
	"Upgrades Pair-Four": {"中文": "升级对加四条"},
	"Upgrades Royal Flush Six": {"中文": "升级六皇家同花顺"},
	"Upgrades Six of a Kind": {"中文": "升级六条"},
	"Upgrades Flush Six of a Kind": {"中文": "升级同花六条"},
	"Upgrades Royal Six of a Kind": {"中文": "升级皇家六条"},

	## ============================================================
	## 天书名称 — 16部 (8基础 + 8进阶)
	## ============================================================

	## --- 基础天书 (8) ---
	"Classic of Seizing Opportunity": {"中文": "握机经"},
	"Classic of Discarding Excess": {"中文": "弃繁经"},
	"Bestiary of a Hundred Beasts": {"中文": "百兽谱"},
	"Classic of the Cosmos Pouch": {"中文": "乾坤袋经"},
	"Classic of Free Flow": {"中文": "活络经"},
	"Classic of Fair Trade": {"中文": "市易经"},
	"Classic of Gathering Treasures": {"中文": "聚宝经"},
	"Classic of Beast-Rearing": {"中文": "养兽经"},

	## --- 进阶天书 (8) ---
	"Classic of Profound Truth": {"中文": "洞真经"},
	"Classic of Heart-Cleansing": {"中文": "洗心经"},
	"Record of Ten Thousand Beasts": {"中文": "万兽录"},
	"Classic of Sumeru": {"中文": "须弥经"},
	"Classic of Open Commerce": {"中文": "通商经"},
	"Classic of Alchemy": {"中文": "炼金经"},
	"Classic of Beast-Taming": {"中文": "驯兽经"},
	"Classic of the Hidden Talisman": {"中文": "阴符经"},

	## ============================================================
	## 天书描述 — 16部
	## ============================================================
	"+1 Hand per round": {"中文": "每回合+1出牌"},
	"+1 Discard per round": {"中文": "每回合+1弃牌"},
	"+1 Beast slot": {"中文": "+1异兽栏位"},
	"+1 Consumable slot": {"中文": "+1消耗品栏位"},
	"-$2 Reroll cost": {"中文": "刷新费用-$2"},
	"10% shop discount": {"中文": "商店物品9折"},
	"+$1 Beast sell value": {"中文": "异兽出售价格+$1"},
	"+1 Hand per round (stacks)": {"中文": "每回合+1出牌(可叠加)"},
	"+1 Discard per round (stacks)": {"中文": "每回合+1弃牌(可叠加)"},
	"+1 Beast slot (stacks)": {"中文": "+1异兽栏位(可叠加)"},
	"Rerolls are free": {"中文": "刷新免费"},
	"25% shop discount": {"中文": "商店物品75折"},
	"Interest cap raised to $15": {"中文": "利息上限提升至$15"},
	"+$2 Beast sell value": {"中文": "异兽出售价格+$2"},
	"+1 card play limit (unlock 6-card hands)": {"中文": "出牌上限+1(解锁6张牌型)"},

	## ============================================================
	## 卡牌增强 & 稀有度
	## ============================================================
	"Foil": {"中文": "箔片"},
	"Holographic": {"中文": "全息"},
	"Polychrome": {"中文": "多彩"},
	"Enhancement": {"中文": "增强"},
	"Common": {"中文": "普通"},
	"Uncommon": {"中文": "罕见"},
	"Rare": {"中文": "稀有"},
	"Legendary": {"中文": "传说"},
	"Relic": {"中文": "神器"},
	"Formation": {"中文": "阵法"},
	"Constellation": {"中文": "星宿"},
	"Specter": {"中文": "幽冥"},
	"Beast": {"中文": "异兽"},
	"Celestial Tome": {"中文": "天书"},
	"Phantom": {"中文": "虚相"},

	## ============================================================
	## TAB 状态面板
	## ============================================================
	"Game Status": {"中文": "本局状态"},
	"Run Status": {"中文": "本局状态"},
	"Owned Tomes": {"中文": "已拥有天书"},
	"None": {"中文": "无"},
	"Deck Tracker": {"中文": "牌库追踪"},
	"Played": {"中文": "已出"},
	"Remaining": {"中文": "剩余"},
	"Hand Levels": {"中文": "牌型等级"},
	"Hand Type": {"中文": "牌型"},

	## ============================================================
	## Boss盲注 (将来64卦扩展)
	## ============================================================
	"The Hook": {"中文": "钩子"},
	"The Wall": {"中文": "墙壁"},
	"The Eye": {"中文": "眼睛"},
	"The Mouth": {"中文": "嘴巴"},
	"The Plant": {"中文": "植物"},
	"The Serpent": {"中文": "蛇"},
	"The Ox": {"中文": "公牛"},
	"The Needle": {"中文": "针"},

	## Boss效果描述
	"Only 3 hands this round": {"中文": "本轮只有3次出牌机会"},
	"No discards this round": {"中文": "本轮无法弃牌"},
	"Face cards score no chips": {"中文": "人头牌（J/Q/K）不计分"},
	"Hearts don't score": {"中文": "♥不计分"},
	"Clubs don't score": {"中文": "♣不计分"},
	"Spades don't score": {"中文": "♠不计分"},
	"Diamonds don't score": {"中文": "♦不计分"},
	"First hand played scores half": {"中文": "第一手牌得分减半"},

	## ============================================================
	## 扑克牌花色
	## ============================================================
	"Spades": {"中文": "黑桃"},
	"Hearts": {"中文": "红心"},
	"Diamonds": {"中文": "方块"},
	"Clubs": {"中文": "梅花"},

	## ============================================================
	## 消耗品相关
	## ============================================================
	"USE": {"中文": "使用"},
	"Select cards first": {"中文": "请先选择牌"},

	## ============================================================
	## 计分显示
	## ============================================================
	"Chips": {"中文": "筹码"},
	"Mult": {"中文": "倍率"},
	"Score": {"中文": "得分"},
	"Lvl": {"中文": "等级"},

	## ============================================================
	## 其他提示
	## ============================================================
	"BOSS": {"中文": "Boss"},
	"No valid hand": {"中文": "无有效牌型"},
	"Select 1-5 cards": {"中文": "选择1-5张牌"},
	"Select 1-6 cards": {"中文": "选择1-6张牌"},
	"Deck": {"中文": "牌堆"},
	"cards left": {"中文": "张剩余"},

	## ============================================================
	## 盲注选择补充
	## ============================================================
	"Receive a random Artifact card": {"中文": "获得一张随机法宝牌"},
	"Receive a random Constellation card": {"中文": "获得一张随机星宿牌"},
	"Receive $3": {"中文": "获得$3"},
	"Random hand type +1 level": {"中文": "随机牌型等级+1"},
	"Standard game": {"中文": "标准游戏"},
	"1.5× score target": {"中文": "目标分数×1.5"},

	## ============================================================
	## 回合结果 & 商店详细
	## ============================================================
	"BLIND DEFEATED!": {"中文": "盲注已击败"},
	"EARNINGS": {"中文": "收入"},
	"Go to Shop": {"中文": "前往商店"},
	"Try Again": {"中文": "再试一次"},
	"TARGET": {"中文": "目标"},
	"ROUND SCORE": {"中文": "本轮得分"},
	"plays to next level": {"中文": "次后升级"},
	"DRAW": {"中文": "抽牌堆"},
	"DISCARD": {"中文": "弃牌堆"},
	"Not enough money to reroll!": {"中文": "金钱不足，无法刷新！"},
	"Max": {"中文": "上限"},
	"for": {"中文": "售价"},
	"Right click to sell": {"中文": "右键出售"},

	## ============================================================
	## 法宝使用反馈
	## ============================================================
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
	"Seal added": {"中文": "已添加灵印"},
	"Enhancement added": {"中文": "已添加增强"},

	## ============================================================
	## 天机系统 (Reel Draw)
	## ============================================================
	"Reel Draw": {"中文": "天机抽牌"},
	"A-Slot": {"中文": "天机A"},
	"B-Slot": {"中文": "天机B"},
	"C-Slot": {"中文": "天机C"},
	"D-Slot": {"中文": "天机D"},

	## ============================================================
	## 节拍系统 (BeatClock)
	## ============================================================
	"Perfect": {"中文": "完美"},
	"Good": {"中文": "良好"},
	"Miss": {"中文": "失误"},
	"BPM": {"中文": "节拍"},
	"Beat Bonus": {"中文": "节拍加成"},

	## ============================================================
	## 卡牌类型通用
	## ============================================================
	"TOME": {"中文": "天书"},
	"ARTIFACT": {"中文": "法宝"},
	"CONSTELLATION": {"中文": "星宿"},
	"BEAST": {"中文": "异兽"},
	"SPECTER": {"中文": "幽冥"},
}

## 翻译函数
func t(key: String) -> String:
	if current_language == "English":
		return key
	if translations.has(key) and translations[key].has(current_language):
		return translations[key][current_language]
	return key
