## planet_data.gd
## 星球牌数据定义
class_name PlanetData
extends Resource

@export var id: String = ""
@export var planet_name: String = ""
@export var description: String = ""
@export var emoji: String = "🌍"
@export var hand_type: PokerHand.HandType = PokerHand.HandType.HIGH_CARD
@export var cost: int = 3

## 每次使用升级的数值
@export var level_chips: int = 10
@export var level_mult: int = 1

## 获取边框颜色（星球牌统一用天蓝/宇宙色）
func get_rarity_color() -> Color:
	return Color(0.2, 0.55, 0.85)

func get_rarity_name() -> String:
	return "Planet"
