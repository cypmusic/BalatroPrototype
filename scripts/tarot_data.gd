## tarot_data.gd
## 法宝牌数据定义 V0.086 — 36张法宝牌（16神器 + 10阵法 + 10幽冥）
## 36天罡 = 16神器 + 10阵法 + 10幽冥 | 36 + 72地煞(异兽) = 108
class_name TarotData
extends Resource

enum ArtifactType {
	RELIC,      ## 神器 — 单卡操作型（需选牌）
	FORMATION,  ## 阵法 — 全局效果型（无需选牌）
	SPECTER,    ## 幽冥 — 极端改造（高风险高回报）
}

enum TarotEffect {
	## ===== 神器效果 (Relic) R01~R16 =====
	CHANGE_SUIT_RANDOM,      ## 随机变花色 (翻天印)
	CHANGE_SUIT_SPADES,      ## 变♠ (太极图)
	CHANGE_SUIT_HEARTS,      ## 变♥ (乾坤圈)
	CHANGE_SUIT_DIAMONDS,    ## 变♦ (混元金斗)
	CHANGE_SUIT_CLUBS,       ## 变♣ (定海珠)
	DESTROY_CARD,            ## 销毁牌 (斩仙剑)
	COPY_TO_DECK,            ## 复制牌到牌组 (照妖镜)
	COPY_LEFT_TO_RIGHT,      ## 左牌变右牌 (山河社稷图)
	ADD_ENHANCEMENT_FOIL,    ## 添加箔片 (九龙神火罩)
	ADD_ENHANCEMENT_HOLO,    ## 添加全息 (风火轮)
	ADD_ENHANCEMENT_POLY,    ## 添加多彩 (玲珑宝塔)
	GAIN_MONEY,              ## 获得金钱 (落宝金钱)
	ADD_SEAL_AZURE_DRAGON,   ## 添加青龙印 (青龙符)
	ADD_SEAL_VERMILLION_BIRD,## 添加朱雀印 (朱雀符)
	ADD_SEAL_WHITE_TIGER,    ## 添加白虎印 (白虎符)
	ADD_SEAL_BLACK_TORTOISE, ## 添加玄武印 (玄武符)
	## ===== 阵法效果 (Formation) F01~F10 =====
	CONVERT_ADD_TO_MULT,     ## +Mult→×Mult (诛仙阵)
	DISABLE_HAND_TYPES,      ## 禁2牌型,余×2C (十绝阵)
	SHOP_DISCOUNT,           ## 商店半价 (万仙阵)
	ADD_DISCARDS,            ## +3弃牌 (九曲黄河阵)
	BOOST_SUIT_HEARTS,       ## ♥+30C+4M (红水阵)
	GENERATE_ARTIFACTS,      ## 生成2法宝 (天绝阵)
	GENERATE_CONSTELLATIONS, ## 生成2星宿 (地烈阵)
	LEVEL_UP_HAND_TYPE,      ## 牌型升级×2 (风吼阵)
	BOOST_SUIT_CLUBS,        ## ♣+30C+4M (寒冰阵)
	BOOST_ALL_CARDS,         ## 全+2M (落魂阵)
	## ===== 幽冥效果 (Specter) S01~S10 =====
	SPECTER_TRANSFORM_FACE,  ## 销毁1→生成3张增强人头牌 (招魂幡)
	SPECTER_TRANSFORM_NUMBER,## 销毁1→生成4张增强数字牌 (生死簿)
	SPECTER_BATCH_SUIT,      ## 手中所有牌变同一随机花色 (六道轮回)
	SPECTER_BATCH_RANK,      ## 手中所有牌变同一随机点数,-1手牌 (夺舍)
	SPECTER_CREATE_LEGEND,   ## 创建1张传说级异兽 (封神)
	SPECTER_UPGRADE_ALL,     ## 所有牌型等级+1 (天劫)
	SPECTER_DESTROY_FOR_GOLD,## 销毁5张随机牌→$20 (焚身)
	SPECTER_JOKER_PHANTOM,   ## 随机异兽获得虚相,-1手牌 (离魂术)
	SPECTER_DUPLICATE_CARDS, ## 选1牌→牌组中创建2张副本 (分身术)
	SPECTER_JOKER_POLY_PURGE,## 1兽获得多彩,销毁其余 (阴阳眼)
}

@export var id: String = ""
@export var tarot_name: String = ""
@export var description: String = ""
@export var emoji: String = "🎴"
@export var effect: TarotEffect = TarotEffect.GAIN_MONEY
@export var artifact_type: ArtifactType = ArtifactType.RELIC
@export var cost: int = 3

## 是否需要选中手牌才能使用
@export var needs_selection: bool = true
## 最大选中数量（0=不限）
@export var max_select: int = 1
## 最小选中数量
@export var min_select: int = 1

## 幽冥牌专用：是否需要选择异兽
@export var needs_joker_selection: bool = false

func get_rarity_color() -> Color:
	match artifact_type:
		ArtifactType.RELIC:
			return Color(0.7, 0.35, 0.75)    ## 神器 - 紫色
		ArtifactType.FORMATION:
			return Color(0.85, 0.25, 0.25)    ## 阵法 - 赤红
		ArtifactType.SPECTER:
			return Color(0.15, 0.12, 0.3)     ## 幽冥 - 暗紫色
		_:
			return Color(0.7, 0.35, 0.75)

func get_rarity_name() -> String:
	match artifact_type:
		ArtifactType.RELIC: return "Relic"
		ArtifactType.FORMATION: return "Formation"
		ArtifactType.SPECTER: return "Specter"
		_: return "Artifact"

func get_sell_price() -> int:
	return ceili(float(cost) / 2.0)
