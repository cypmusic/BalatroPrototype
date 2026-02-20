## game_config.gd
## 全局配置单例 (AutoLoad) — V0.085
## 集中管理版本号、布局常量、游戏平衡性参数
## 在 Project Settings → AutoLoad 中注册为 "GameConfig"
extends Node

## ========== 版本信息 ==========
const VERSION: String = "V0.085"
const VERSION_LABEL: String = "V0.085 beta"

## ========== 设计分辨率 (1080p) ==========
const DESIGN_WIDTH: float = 1920.0
const DESIGN_HEIGHT: float = 1080.0
const CENTER_X: float = DESIGN_WIDTH / 2.0
const CENTER_Y: float = DESIGN_HEIGHT / 2.0

## ========== 布局 Y 坐标 (1080p) ==========
const JOKER_Y: float = 175.0
const JOKER_INFO_Y: float = 275.0
const PREVIEW_Y: float = 420.0
const HAND_Y: float = 750.0
const BUTTON_Y: float = 920.0
const PILE_Y: float = 940.0
const DRAW_PILE_POS: Vector2 = Vector2(1780.0, 940.0)
const DISCARD_PILE_POS: Vector2 = Vector2(140.0, 940.0)

## ========== 游戏平衡性常量 ==========
const MAX_ANTE: int = 8
const INITIAL_HAND_SIZE: int = 8
const MAX_SELECT: int = 5
const MAX_JOKER_SLOTS: int = 5
const MAX_CONSUMABLE_SLOTS: int = 2

const STARTING_MONEY: int = 4
const STARTING_HANDS: int = 4
const STARTING_DISCARDS: int = 3

const BASE_INCOME: int = 3
const INTEREST_CAP: int = 5
const WIN_BONUS: int = 1

const REROLL_COST: int = 5

## ========== 颜色主题 ==========
const COLOR_GOLD: Color = Color(0.95, 0.85, 0.4)
const COLOR_MONEY: Color = Color(0.95, 0.8, 0.2)
const COLOR_CHIPS: Color = Color(0.4, 0.65, 0.95)
const COLOR_MULT: Color = Color(0.95, 0.4, 0.35)
const COLOR_INFO: Color = Color(0.7, 0.7, 0.65)
const COLOR_SUCCESS: Color = Color(0.3, 0.9, 0.4)
const COLOR_WARNING: Color = Color(0.9, 0.5, 0.3)
const COLOR_ERROR: Color = Color(0.9, 0.3, 0.3)
const COLOR_DEBUG: Color = Color(0.9, 0.9, 0.3)
const COLOR_BG: Color = Color(0.08, 0.16, 0.12)
