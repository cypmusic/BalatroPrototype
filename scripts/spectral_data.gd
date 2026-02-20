## spectral_data.gd
## 幽冥牌（幽冥牌）数据定义 V1 — 10种极端效果
class_name SpectralData
extends Resource

enum SpectralEffect {
	CARD_TRANSFORM_FACE,    ## 销毁1→生成3张增强人头牌
	CARD_TRANSFORM_NUMBER,  ## 销毁1→生成4张增强数字牌
	BATCH_SUIT_CHANGE,      ## 手中所有牌变为同一随机花色
	BATCH_RANK_CHANGE,      ## 手中所有牌变为同一随机点数（手牌上限-1）
	CREATE_LEGENDARY_JOKER, ## 创建1张传说级异兽牌
	UPGRADE_ALL_HANDS,      ## 所有牌型等级+1
	DESTROY_FOR_COINS,      ## 销毁5张随机牌→$20
	JOKER_PHANTOM,          ## 随机1只异兽获得虚相（不占栏位），手牌上限-1
	DUPLICATE_CARDS,        ## 选择1张手牌→牌组中创建2张副本
	JOKER_POLYCHROME_DESTROY, ## 选中1只异兽获得多彩(×1.5)，销毁其余
}

@export var id: String = ""
@export var spectral_name: String = ""
@export var description: String = ""
@export var emoji: String = "👻"
@export var effect: SpectralEffect = SpectralEffect.CARD_TRANSFORM_FACE
@export var cost: int = 4

## 是否需要选择手牌
@export var needs_card_selection: bool = false
## 是否需要选择异兽
@export var needs_joker_selection: bool = false

func get_rarity_color() -> Color:
	return Color(0.15, 0.12, 0.3)  ## 幽冥 — 暗紫色

func get_sell_price() -> int:
	return ceili(float(cost) / 2.0)
