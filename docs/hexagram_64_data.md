# 64卦难度分配与变爻连接数据
# hexagram_64_data.md
# 天地万象 · Wanxiang 设计圣经附录
# 版本：V1.0 | 2026.02.19

---

## 一、设计原则

### 1.1 变爻规则
- 每卦由上卦（外卦）+ 下卦（内卦）组成，各3爻，共6爻
- **变一爻**得到一个新卦 → 每卦最多6个变爻邻居
- 游戏中每个卦提供 **2-3个分岔选择**（从6个邻居中筛选同难度或+1难度的卦）
- 玩家一局走8个卦（难度等级1→8），每级从该等级的8个卦中选择

### 1.2 难度分配原则
- 64卦 = 8个难度等级 × 8个卦/等级
- 分配依据：**卦德**（吉凶）、**卦象含义**、**八宫归属**
- 吉卦/平卦偏前期，凶卦/险卦偏后期
- 八纯卦（乾坤坎离震巽艮兑）分布在关键节点

### 1.3 四象归属
每卦根据上卦（外卦）的八卦属性，归入四象体系：
| 八卦 | 四象 | 五行 | 花色 |
|:---:|:---:|:---:|:---:|
| ☰ 乾（天） | 白虎 | 金 | ♦ |
| ☷ 坤（地） | 玄武 | 水（土→水） | ♣ |
| ☵ 坎（水） | 玄武 | 水 | ♣ |
| ☲ 离（火） | 朱雀 | 火 | ♥ |
| ☳ 震（雷） | 青龙 | 木 | ♠ |
| ☴ 巽（风） | 青龙 | 木 | ♠ |
| ☶ 艮（山） | 白虎 | 金（土→金） | ♦ |
| ☱ 兑（泽） | 朱雀 | 火（金→火） | ♥ |

> **说明**：土行无对应四象，坤/艮就近归入玄武/白虎。兑（泽）归入朱雀（泽生雾气，通火象）。

---

## 二、八卦编码与二进制

用二进制表示每卦的6爻（从初爻到上爻，阳=1，阴=0）：

| 八卦 | 三爻二进制 | 十进制 |
|:---:|:---:|:---:|
| ☷ 坤 | 000 | 0 |
| ☶ 艮 | 001 | 1 |
| ☵ 坎 | 010 | 2 |
| ☴ 巽 | 011 | 3 |
| ☳ 震 | 100 | 4 |
| ☲ 离 | 101 | 5 |
| ☱ 兑 | 110 | 6 |
| ☰ 乾 | 111 | 7 |

**64卦编号** = 下卦×8 + 上卦（0-63），与伏羲先天六十四卦序对应。

---

## 三、64卦完整数据表

### 格式说明
```
卦序 | 卦名 | 上卦/下卦 | 六爻二进制 | 难度等级 | 四象 | 卦德关键词 | 游戏效果简述
```

### 难度等级1（起始·萌芽）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | ☰ **乾** | 乾/乾 | 111-111 | 1 | 白虎♦ | 刚健 | 倍率+15% |
| 2 | ☷ **坤** | 坤/坤 | 000-000 | 1 | 玄武♣ | 柔顺 | 手牌数+1 |
| 11 | **泰** | 坤/乾 | 000-111 | 1 | 玄武♣ | 通泰 | 所有商品-$1 |
| 19 | **临** | 坤/兑 | 000-110 | 1 | 玄武♣ | 亲临 | 异兽出现率+10% |
| 25 | **无妄** | 乾/震 | 111-100 | 1 | 白虎♦ | 天真 | 首次出牌+20筹码 |
| 34 | **大壮** | 震/乾 | 100-111 | 1 | 青龙♠ | 壮盛 | 倍率+10% |
| 43 | **夬** | 兑/乾 | 110-111 | 1 | 朱雀♥ | 决断 | 弃牌数+1 |
| 58 | ☱ **兑** | 兑/兑 | 110-110 | 1 | 朱雀♥ | 喜悦 | 金币收入+$2 |

### 难度等级2（初成·立基）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 9 | **小畜** | 巽/乾 | 011-111 | 2 | 青龙♠ | 蓄养 | 弃牌时+$1/张 |
| 14 | **大有** | 离/乾 | 101-111 | 2 | 朱雀♥ | 大有 | 金币收入+$3 |
| 26 | **大畜** | 艮/乾 | 001-111 | 2 | 白虎♦ | 积蓄 | 利息上限+$3 |
| 35 | **晋** | 离/坤 | 101-000 | 2 | 朱雀♥ | 进步 | 牌型升级经验×1.5 |
| 42 | **益** | 巽/震 | 011-100 | 2 | 青龙♠ | 增益 | 法宝效果+25% |
| 45 | **萃** | 兑/坤 | 110-000 | 2 | 朱雀♥ | 聚合 | 商店刷新-$1 |
| 53 | **渐** | 巽/艮 | 011-001 | 2 | 青龙♠ | 渐进 | 每回合首次出牌+5倍率 |
| 57 | ☴ **巽** | 巽/巽 | 011-011 | 2 | 青龙♠ | 柔顺入 | 同花牌+15筹码 |

### 难度等级3（渐长·试炼）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 5 | **需** | 坎/乾 | 010-111 | 3 | 玄武♣ | 等待 | Boss盲注目标-10% |
| 15 | **谦** | 坤/艮 | 000-001 | 3 | 玄武♣ | 谦逊 | 所有异兽费用-$2 |
| 20 | **观** | 巽/坤 | 011-000 | 3 | 青龙♠ | 观察 | 商店可见商品+1 |
| 31 | **咸** | 兑/艮 | 110-001 | 3 | 朱雀♥ | 感应 | 星宿牌掉落率+15% |
| 37 | **家人** | 巽/离 | 011-101 | 3 | 青龙♠ | 家道 | 同花色对+10倍率 |
| 41 | **损** | 艮/兑 | 001-110 | 3 | 白虎♦ | 减损 | 弃牌-1但倍率+20% |
| 52 | ☶ **艮** | 艮/艮 | 001-001 | 3 | 白虎♦ | 止静 | 不弃牌时倍率×1.3 |
| 61 | **中孚** | 巽/兑 | 011-110 | 3 | 青龙♠ | 诚信 | 手牌有对子时+15筹码 |

### 难度等级4（中道·分野）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 8 | **比** | 坎/坤 | 010-000 | 4 | 玄武♣ | 亲附 | 相邻异兽效果+20% |
| 16 | **豫** | 震/坤 | 100-000 | 4 | 青龙♠ | 欢豫 | 出牌后有20%几率不消耗手数 |
| 32 | **恒** | 震/巽 | 100-011 | 4 | 青龙♠ | 恒久 | 异兽递增效果翻倍 |
| 46 | **升** | 坤/巽 | 000-011 | 4 | 玄武♣ | 上升 | 每过一个盲注倍率+5% |
| 48 | **井** | 坎/巽 | 010-011 | 4 | 玄武♣ | 汲养 | 每回合开始获$2 |
| 50 | **鼎** | 离/巽 | 101-011 | 4 | 朱雀♥ | 革新 | 法宝牌可使用2次 |
| 51 | ☳ **震** | 震/震 | 100-100 | 4 | 青龙♠ | 震动 | 首张计分牌×1.5 |
| 63 | **既济** | 坎/离 | 010-101 | 4 | 玄武♣ | 已成 | 所有牌型基础筹码+20 |

### 难度等级5（变局·风云）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 6 | **讼** | 乾/坎 | 111-010 | 5 | 白虎♦ | 争讼 | Boss效果加强但奖金×1.5 |
| 10 | **履** | 乾/兑 | 111-110 | 5 | 白虎♦ | 践行 | 出牌恰好5张时×1.3 |
| 13 | **同人** | 乾/离 | 111-101 | 5 | 白虎♦ | 同心 | 全部同花色时倍率×2 |
| 30 | ☲ **离** | 离/离 | 101-101 | 5 | 朱雀♥ | 附丽 | 红色牌(♥♦)+20筹码 |
| 38 | **睽** | 离/兑 | 101-110 | 5 | 朱雀♥ | 乖违 | 不同花色越多倍率越高(+5/种) |
| 49 | **革** | 兑/离 | 110-101 | 5 | 朱雀♥ | 变革 | 可重新选择1张异兽替换 |
| 55 | **丰** | 震/离 | 100-101 | 5 | 青龙♠ | 丰盛 | 筹码和倍率各+10 |
| 64 | **未济** | 离/坎 | 101-010 | 5 | 朱雀♥ | 未成 | 每次弃牌+3倍率 |

### 难度等级6（险境·淬炼）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 3 | **屯** | 坎/震 | 010-100 | 6 | 玄武♣ | 艰难 | 手牌-1但每张计分牌+15筹码 |
| 4 | **蒙** | 艮/坎 | 001-010 | 6 | 白虎♦ | 蒙昧 | 不显示Boss效果（盲打） |
| 18 | **蛊** | 艮/巽 | 001-011 | 6 | 白虎♦ | 整治 | 可销毁1张手牌获$5+倍率 |
| 29 | ☵ **坎** | 坎/坎 | 010-010 | 6 | 玄武♣ | 重险 | Boss禁用2种花色 |
| 39 | **蹇** | 坎/艮 | 010-001 | 6 | 玄武♣ | 艰行 | 出牌数-1但倍率×1.5 |
| 44 | **姤** | 乾/巽 | 111-011 | 6 | 白虎♦ | 遭遇 | 随机1张手牌被锁（不可出） |
| 47 | **困** | 兑/坎 | 110-010 | 6 | 朱雀♥ | 困穷 | 金币-50%但倍率×1.3 |
| 59 | **涣** | 巽/坎 | 011-010 | 6 | 青龙♠ | 涣散 | 手牌随机打乱位置 |

### 难度等级7（天劫·极限）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 12 | **否** | 乾/坤 | 111-000 | 7 | 白虎♦ | 闭塞 | 商店商品+$3 |
| 22 | **贲** | 艮/离 | 001-101 | 7 | 白虎♦ | 文饰 | 增强牌效果×2但普通牌-20筹码 |
| 23 | **剥** | 艮/坤 | 001-000 | 7 | 白虎♦ | 剥落 | 每回合随机失去1张手牌 |
| 27 | **颐** | 艮/震 | 001-100 | 7 | 白虎♦ | 养正 | 出牌必须含A或K |
| 33 | **遁** | 乾/艮 | 111-001 | 7 | 白虎♦ | 退避 | 跳过盲注不给奖励 |
| 36 | **明夷** | 坤/离 | 000-101 | 7 | 玄武♣ | 光明损伤 | 计分面板不显示中间过程 |
| 56 | **旅** | 离/艮 | 101-001 | 7 | 朱雀♥ | 旅行 | 异兽栏位-1 |
| 62 | **小过** | 震/艮 | 100-001 | 7 | 青龙♠ | 小有过越 | 只能出≤3张牌 |

### 难度等级8（终局·天命）— 8卦

| 序 | 卦名 | 上/下 | 二进制 | 难度 | 四象 | 卦德 | 游戏效果 |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 7 | **师** | 坤/坎 | 000-010 | 8 | 玄武♣ | 统师 | 手牌全部由♣组成 |
| 17 | **随** | 兑/震 | 110-100 | 8 | 朱雀♥ | 随从 | 异兽效果顺序反转 |
| 21 | **噬嗑** | 离/震 | 101-100 | 8 | 朱雀♥ | 咬合 | Boss血量×1.5 |
| 24 | **复** | 坤/震 | 000-100 | 8 | 玄武♣ | 回复 | 每输一手+15%倍率（背水一战） |
| 28 | **大过** | 兑/巽 | 110-011 | 8 | 朱雀♥ | 大过越 | 出牌数-2但倍率×2 |
| 40 | **解** | 震/坎 | 100-010 | 8 | 青龙♠ | 解除 | Boss有2个效果叠加 |
| 54 | **归妹** | 震/兑 | 100-110 | 8 | 青龙♠ | 归妹 | 每出一手消耗$2 |
| 60 | **节** | 坎/兑 | 010-110 | 8 | 玄武♣ | 节制 | 手牌上限5张 |

---

## 四、变爻连接表（完整邻接图）

### 4.1 变爻计算说明

每卦6爻，翻转第N爻得到邻居卦。设卦的二进制为 `ABCDEF`（A=上爻，F=初爻）：
- 变初爻（F）→ 翻转第0位
- 变二爻（E）→ 翻转第1位
- 变三爻（D）→ 翻转第2位（下卦→上卦边界）
- 变四爻（C）→ 翻转第3位
- 变五爻（B）→ 翻转第4位
- 变上爻（A）→ 翻转第5位

**编号规则**：卦序 = 下卦(三位) × 8 + 上卦(三位) + 1（1-64）

### 4.2 完整变爻邻接表

> 格式：`卦序.卦名 → [变初爻→卦X, 变二爻→卦X, 变三爻→卦X, 变四爻→卦X, 变五爻→卦X, 变上爻→卦X]`
> 标注 `(D等级)` 表示目标卦的难度等级

```
01.乾 (111-111) [D1]
  → 变初爻→43.夬(110-111)[D1], 变二爻→14.大有(101-111)[D2],
    变三爻→09.小畜(011-111)[D2], 变四爻→10.履(111-110)[D5],
    变五爻→13.同人(111-101)[D5], 变六爻→44.姤(111-011)[D6]

02.坤 (000-000) [D1]
  → 变初爻→24.复(000-100)[D8], 变二爻→07.师(000-010)[D8],
    变三爻→15.谦(000-001)[D3], 变四爻→16.豫(100-000)[D4],
    变五爻→08.比(010-000)[D4], 变六爻→23.剥(001-000)[D7]

03.屯 (010-100) [D6]
  → 变初爻→40.解(100-010)→交换?

```

**注意**：上面只是示例格式。由于完整64卦邻接手工列出极易出错，下面我改用**程序化数据格式**，更精确且可直接导入游戏。

---

## 五、程序化数据（GDScript可用格式）

### 5.1 64卦基础数据数组

```
# 索引0-63，每项: [卦序(1-64), 卦名, 上卦, 下卦, 六爻二进制, 难度等级, 四象, 卦德, 游戏效果描述]
# 上下卦编码: 0=坤 1=艮 2=坎 3=巽 4=震 5=离 6=兑 7=乾

INDEX = 下卦 × 8 + 上卦  (0-63)
卦序 = INDEX + 1         (1-64)
```

### 5.2 难度分配映射表

```gdscript
# hexagram_data.gd 可用格式
# key = 卦序(1-64), value = 难度等级(1-8)

const DIFFICULTY_MAP := {
    # === 难度1：起始·萌芽 ===
    1: 1,   # 乾
    2: 1,   # 坤
    11: 1,  # 泰
    19: 1,  # 临
    25: 1,  # 无妄
    34: 1,  # 大壮
    43: 1,  # 夬
    58: 1,  # 兑

    # === 难度2：初成·立基 ===
    9: 2,   # 小畜
    14: 2,  # 大有
    26: 2,  # 大畜
    35: 2,  # 晋
    42: 2,  # 益
    45: 2,  # 萃
    53: 2,  # 渐
    57: 2,  # 巽

    # === 难度3：渐长·试炼 ===
    5: 3,   # 需
    15: 3,  # 谦
    20: 3,  # 观
    31: 3,  # 咸
    37: 3,  # 家人
    41: 3,  # 损
    52: 3,  # 艮
    61: 3,  # 中孚

    # === 难度4：中道·分野 ===
    8: 4,   # 比
    16: 4,  # 豫
    32: 4,  # 恒
    46: 4,  # 升
    48: 4,  # 井
    50: 4,  # 鼎
    51: 4,  # 震
    63: 4,  # 既济

    # === 难度5：变局·风云 ===
    6: 5,   # 讼
    10: 5,  # 履
    13: 5,  # 同人
    30: 5,  # 离
    38: 5,  # 睽
    49: 5,  # 革
    55: 5,  # 丰
    64: 5,  # 未济

    # === 难度6：险境·淬炼 ===
    3: 6,   # 屯
    4: 6,   # 蒙
    18: 6,  # 蛊
    29: 6,  # 坎
    39: 6,  # 蹇
    44: 6,  # 姤
    47: 6,  # 困
    59: 6,  # 涣

    # === 难度7：天劫·极限 ===
    12: 7,  # 否
    22: 7,  # 贲
    23: 7,  # 剥
    27: 7,  # 颐
    33: 7,  # 遁
    36: 7,  # 明夷
    56: 7,  # 旅
    62: 7,  # 小过

    # === 难度8：终局·天命 ===
    7: 8,   # 师
    17: 8,  # 随
    21: 8,  # 噬嗑
    24: 8,  # 复
    28: 8,  # 大过
    40: 8,  # 解
    54: 8,  # 归妹
    60: 8,  # 节
}
```

### 5.3 完整变爻邻接表（程序计算结果）

以下是通过二进制变爻规则精确计算的全部64卦邻接关系。

**编号约定**：卦序采用传统序（1-64），二进制 = `下卦(3bit) | 上卦(3bit)`，INDEX = 下卦×8+上卦。

```gdscript
# 变爻邻接表
# key = 卦序, value = [变初爻目标卦序, 变二爻, 变三爻, 变四爻, 变五爻, 变上爻]
# 每个邻居附带其难度等级，方便路线筛选

const YAO_CONNECTIONS := {
    # ========================================
    # 难度1 · 起始（8卦）
    # ========================================

    # 01.乾 ☰☰ (111-111) → 翻转各爻
    # 初爻→(111-110)=兑/乾=43夬, 二爻→(111-101)=离/乾=14大有
    # 三爻→(111-011)=巽/乾=9小畜, 四爻→(110-111)=乾/兑=10履
    # 五爻→(101-111)=乾/离=13同人, 上爻→(011-111)=乾/巽=44姤
    1: [43, 14, 9, 10, 13, 44],

    # 02.坤 ☷☷ (000-000)
    # 初爻→(000-001)=艮/坤→卦序需计算
    # 下卦000=坤(0), 上卦000=坤(0), INDEX=0×8+0=0, 卦序=1? 
    # 不对，让我重新用正确的编码...
}
```

> ⚠️ **重要说明**：传统64卦序号与二进制索引的映射比较复杂。下面我采用**标准的King Wen序（文王序）**与**二进制索引**的双重标注，并提供一个完整的查找表。

---

## 六、精确变爻连接（基于二进制计算）

### 6.1 二进制索引 ↔ 文王序 对照表

二进制索引 = 下卦三位(高位) + 上卦三位(低位)，范围0-63。

| 二进制(下-上) | 下卦 | 上卦 | 文王序 | 卦名 | 难度 |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 000-000 | 坤 | 坤 | 2 | 坤 | 1 |
| 000-001 | 坤 | 艮 | 15 | 谦 | 3 |
| 000-010 | 坤 | 坎 | 7 | 师 | 8 |
| 000-011 | 坤 | 巽 | 46 | 升 | 4 |
| 000-100 | 坤 | 震 | 24 | 复 | 8 |
| 000-101 | 坤 | 离 | 36 | 明夷 | 7 |
| 000-110 | 坤 | 兑 | 19 | 临 | 1 |
| 000-111 | 坤 | 乾 | 11 | 泰 | 1 |
| 001-000 | 艮 | 坤 | 23 | 剥 | 7 |
| 001-001 | 艮 | 艮 | 52 | 艮 | 3 |
| 001-010 | 艮 | 坎 | 4 | 蒙 | 6 |
| 001-011 | 艮 | 巽 | 18 | 蛊 | 6 |
| 001-100 | 艮 | 震 | 27 | 颐 | 7 |
| 001-101 | 艮 | 离 | 22 | 贲 | 7 |
| 001-110 | 艮 | 兑 | 41 | 损 | 3 |
| 001-111 | 艮 | 乾 | 26 | 大畜 | 2 |
| 010-000 | 坎 | 坤 | 8 | 比 | 4 |
| 010-001 | 坎 | 艮 | 39 | 蹇 | 6 |
| 010-010 | 坎 | 坎 | 29 | 坎 | 6 |
| 010-011 | 坎 | 巽 | 48 | 井 | 4 |
| 010-100 | 坎 | 震 | 3 | 屯 | 6 |
| 010-101 | 坎 | 离 | 63 | 既济 | 4 |
| 010-110 | 坎 | 兑 | 60 | 节 | 8 |
| 010-111 | 坎 | 乾 | 5 | 需 | 3 |
| 011-000 | 巽 | 坤 | 20 | 观 | 3 |
| 011-001 | 巽 | 艮 | 53 | 渐 | 2 |
| 011-010 | 巽 | 坎 | 59 | 涣 | 6 |
| 011-011 | 巽 | 巽 | 57 | 巽 | 2 |
| 011-100 | 巽 | 震 | 42 | 益 | 2 |
| 011-101 | 巽 | 离 | 37 | 家人 | 3 |
| 011-110 | 巽 | 兑 | 61 | 中孚 | 3 |
| 011-111 | 巽 | 乾 | 9 | 小畜 | 2 |
| 100-000 | 震 | 坤 | 16 | 豫 | 4 |
| 100-001 | 震 | 艮 | 62 | 小过 | 7 |
| 100-010 | 震 | 坎 | 40 | 解 | 8 |
| 100-011 | 震 | 巽 | 32 | 恒 | 4 |
| 100-100 | 震 | 震 | 51 | 震 | 4 |
| 100-101 | 震 | 离 | 55 | 丰 | 5 |
| 100-110 | 震 | 兑 | 54 | 归妹 | 8 |
| 100-111 | 震 | 乾 | 34 | 大壮 | 1 |
| 101-000 | 离 | 坤 | 35 | 晋 | 2 |
| 101-001 | 离 | 艮 | 56 | 旅 | 7 |
| 101-010 | 离 | 坎 | 64 | 未济 | 5 |
| 101-011 | 离 | 巽 | 50 | 鼎 | 4 |
| 101-100 | 离 | 震 | 21 | 噬嗑 | 8 |
| 101-101 | 离 | 离 | 30 | 离 | 5 |
| 101-110 | 离 | 兑 | 38 | 睽 | 5 |
| 101-111 | 离 | 乾 | 14 | 大有 | 2 |
| 110-000 | 兑 | 坤 | 45 | 萃 | 2 |
| 110-001 | 兑 | 艮 | 31 | 咸 | 3 |
| 110-010 | 兑 | 坎 | 47 | 困 | 6 |
| 110-011 | 兑 | 巽 | 28 | 大过 | 8 |
| 110-100 | 兑 | 震 | 17 | 随 | 8 |
| 110-101 | 兑 | 离 | 49 | 革 | 5 |
| 110-110 | 兑 | 兑 | 58 | 兑 | 1 |
| 110-111 | 兑 | 乾 | 43 | 夬 | 1 |
| 111-000 | 乾 | 坤 | 12 | 否 | 7 |
| 111-001 | 乾 | 艮 | 33 | 遁 | 7 |
| 111-010 | 乾 | 坎 | 6 | 讼 | 5 |
| 111-011 | 乾 | 巽 | 44 | 姤 | 6 |
| 111-100 | 乾 | 震 | 25 | 无妄 | 1 |
| 111-101 | 乾 | 离 | 13 | 同人 | 5 |
| 111-110 | 乾 | 兑 | 10 | 履 | 5 |
| 111-111 | 乾 | 乾 | 1 | 乾 | 1 |

### 6.2 变爻邻居计算

变爻操作 = 翻转六爻中的一爻。六爻编号：
- 爻1(初爻) = bit0 (上卦最低位)
- 爻2(二爻) = bit1 (上卦中位)  
- 爻3(三爻) = bit2 (上卦最高位)
- 爻4(四爻) = bit3 (下卦最低位)
- 爻5(五爻) = bit4 (下卦中位)
- 爻6(上爻) = bit5 (下卦最高位)

**变爻公式**：`neighbor_index = current_index XOR (1 << yao_position)`

其中 `yao_position` = 0,1,2,3,4,5 分别对应初爻到上爻。

### 6.3 完整变爻邻接表（文王序→文王序）

以下使用Python/GDScript风格的字典，key=文王序，value=6个变爻邻居的文王序。

```
# 通过二进制XOR计算，再查表转为文王序
# 格式: 卦序: [变初爻, 变二爻, 变三爻, 变四爻, 变五爻, 变上爻]

  1 乾: → [44, 13, 10, 9, 14, 43]     # D6,D5,D5,D2,D2,D1
  2 坤: → [24, 7, 19, 15, 36, 23]      # D8,D8,D1,D3,D7,D7
  3 屯: → [63, 40, 27, 59, 3→8, 55]    
```

> 由于手工转换极易出错，**我建议直接在游戏中使用程序计算**。下面提供可直接使用的GDScript。

---

## 七、hexagram_database.gd — 游戏可用代码

以下GDScript包含完整的64卦数据、自动变爻计算、路线生成逻辑：

```gdscript
## hexagram_database.gd
## 64卦数据库 — 天地万象 · Wanxiang
## 包含：卦象数据 + 变爻邻接自动计算 + 路线生成
class_name HexagramDatabase
extends RefCounted

# ==============================
# 八卦基础编码
# ==============================
enum Trigram {
    KUN = 0,   # ☷ 坤 000
    GEN = 1,   # ☶ 艮 001
    KAN = 2,   # ☵ 坎 010
    XUN = 3,   # ☴ 巽 011
    ZHEN = 4,  # ☳ 震 100
    LI = 5,    # ☲ 离 101
    DUI = 6,   # ☱ 兑 110
    QIAN = 7,  # ☰ 乾 111
}

# 八卦→四象映射
enum SiXiang { QINGLONG, ZHUQUE, BAIHU, XUANWU }

const TRIGRAM_TO_SIXIANG := {
    Trigram.QIAN: SiXiang.BAIHU,   # 乾→白虎(金)
    Trigram.KUN:  SiXiang.XUANWU,  # 坤→玄武(水)
    Trigram.KAN:  SiXiang.XUANWU,  # 坎→玄武(水)
    Trigram.LI:   SiXiang.ZHUQUE,  # 离→朱雀(火)
    Trigram.ZHEN: SiXiang.QINGLONG,# 震→青龙(木)
    Trigram.XUN:  SiXiang.QINGLONG,# 巽→青龙(木)
    Trigram.GEN:  SiXiang.BAIHU,   # 艮→白虎(金)
    Trigram.DUI:  SiXiang.ZHUQUE,  # 兑→朱雀(火)
}

const SIXIANG_NAMES := {
    SiXiang.QINGLONG: "青龙",
    SiXiang.ZHUQUE:   "朱雀",
    SiXiang.BAIHU:    "白虎",
    SiXiang.XUANWU:   "玄武",
}

const TRIGRAM_NAMES := {
    Trigram.QIAN: "乾", Trigram.KUN: "坤",
    Trigram.KAN: "坎",  Trigram.LI: "离",
    Trigram.ZHEN: "震", Trigram.XUN: "巽",
    Trigram.GEN: "艮",  Trigram.DUI: "兑",
}

# ==============================
# 二进制索引 → 文王序 对照表
# index = lower_trigram * 8 + upper_trigram
# ==============================
const BIN_TO_KINGWEN := [
     2, 15,  7, 46, 24, 36, 19, 11,  # 下坤(000): 坤谦师升复明夷临泰
    23, 52,  4, 18, 27, 22, 41, 26,  # 下艮(001): 剥艮蒙蛊颐贲损大畜
     8, 39, 29, 48,  3, 63, 60,  5,  # 下坎(010): 比蹇坎井屯既济节需
    20, 53, 59, 57, 42, 37, 61,  9,  # 下巽(011): 观渐涣巽益家人中孚小畜
    16, 62, 40, 32, 51, 55, 54, 34,  # 下震(100): 豫小过解恒震丰归妹大壮
    35, 56, 64, 50, 21, 30, 38, 14,  # 下离(101): 晋旅未济鼎噬嗑离睽大有
    45, 31, 47, 28, 17, 49, 58, 43,  # 下兑(110): 萃咸困大过随革兑夬
    12, 33,  6, 44, 25, 13, 10,  1,  # 下乾(111): 否遁讼姤无妄同人履乾
]

# 文王序 → 二进制索引（反查表，运行时构建）
static var _kingwen_to_bin := {}

# ==============================
# 64卦详细数据
# ==============================
# 格式: 文王序 → { name, difficulty, keyword, effect_id, effect_desc }
const HEXAGRAM_DATA := {
    # --- 难度1：起始·萌芽 ---
    1:  { "name": "乾",   "difficulty": 1, "keyword": "刚健",   "effect_id": "mult_pct_15",       "effect_desc": "倍率+15%" },
    2:  { "name": "坤",   "difficulty": 1, "keyword": "柔顺",   "effect_id": "hand_size_1",        "effect_desc": "手牌数+1" },
    11: { "name": "泰",   "difficulty": 1, "keyword": "通泰",   "effect_id": "shop_discount_1",    "effect_desc": "所有商品-$1" },
    19: { "name": "临",   "difficulty": 1, "keyword": "亲临",   "effect_id": "beast_rate_10",      "effect_desc": "异兽出现率+10%" },
    25: { "name": "无妄", "difficulty": 1, "keyword": "天真",   "effect_id": "first_play_chips_20","effect_desc": "首次出牌+20筹码" },
    34: { "name": "大壮", "difficulty": 1, "keyword": "壮盛",   "effect_id": "mult_pct_10",        "effect_desc": "倍率+10%" },
    43: { "name": "夬",   "difficulty": 1, "keyword": "决断",   "effect_id": "discard_1",          "effect_desc": "弃牌数+1" },
    58: { "name": "兑",   "difficulty": 1, "keyword": "喜悦",   "effect_id": "income_2",           "effect_desc": "金币收入+$2" },

    # --- 难度2：初成·立基 ---
    9:  { "name": "小畜", "difficulty": 2, "keyword": "蓄养",   "effect_id": "discard_money_1",    "effect_desc": "弃牌时+$1/张" },
    14: { "name": "大有", "difficulty": 2, "keyword": "大有",   "effect_id": "income_3",           "effect_desc": "金币收入+$3" },
    26: { "name": "大畜", "difficulty": 2, "keyword": "积蓄",   "effect_id": "interest_cap_3",     "effect_desc": "利息上限+$3" },
    35: { "name": "晋",   "difficulty": 2, "keyword": "进步",   "effect_id": "level_exp_150",      "effect_desc": "牌型升级经验×1.5" },
    42: { "name": "益",   "difficulty": 2, "keyword": "增益",   "effect_id": "artifact_boost_25",  "effect_desc": "法宝效果+25%" },
    45: { "name": "萃",   "difficulty": 2, "keyword": "聚合",   "effect_id": "reroll_discount_1",  "effect_desc": "商店刷新-$1" },
    53: { "name": "渐",   "difficulty": 2, "keyword": "渐进",   "effect_id": "first_mult_5",       "effect_desc": "每回合首次出牌+5倍率" },
    57: { "name": "巽",   "difficulty": 2, "keyword": "柔顺入", "effect_id": "flush_chips_15",     "effect_desc": "同花牌+15筹码" },

    # --- 难度3：渐长·试炼 ---
    5:  { "name": "需",   "difficulty": 3, "keyword": "等待",   "effect_id": "boss_target_m10",    "effect_desc": "Boss盲注目标-10%" },
    15: { "name": "谦",   "difficulty": 3, "keyword": "谦逊",   "effect_id": "beast_cost_m2",      "effect_desc": "所有异兽费用-$2" },
    20: { "name": "观",   "difficulty": 3, "keyword": "观察",   "effect_id": "shop_items_1",       "effect_desc": "商店可见商品+1" },
    31: { "name": "咸",   "difficulty": 3, "keyword": "感应",   "effect_id": "star_drop_15",       "effect_desc": "星宿牌掉落率+15%" },
    37: { "name": "家人", "difficulty": 3, "keyword": "家道",   "effect_id": "flush_pair_mult_10", "effect_desc": "同花色对+10倍率" },
    41: { "name": "损",   "difficulty": 3, "keyword": "减损",   "effect_id": "discard_m1_mult_20", "effect_desc": "弃牌-1但倍率+20%" },
    52: { "name": "艮",   "difficulty": 3, "keyword": "止静",   "effect_id": "no_discard_mult_130","effect_desc": "不弃牌时倍率×1.3" },
    61: { "name": "中孚", "difficulty": 3, "keyword": "诚信",   "effect_id": "pair_chips_15",      "effect_desc": "手牌有对子时+15筹码" },

    # --- 难度4：中道·分野 ---
    8:  { "name": "比",   "difficulty": 4, "keyword": "亲附",   "effect_id": "adj_beast_20",       "effect_desc": "相邻异兽效果+20%" },
    16: { "name": "豫",   "difficulty": 4, "keyword": "欢豫",   "effect_id": "free_play_20",       "effect_desc": "出牌后有20%几率不消耗手数" },
    32: { "name": "恒",   "difficulty": 4, "keyword": "恒久",   "effect_id": "scaling_double",     "effect_desc": "异兽递增效果翻倍" },
    46: { "name": "升",   "difficulty": 4, "keyword": "上升",   "effect_id": "blind_mult_5pct",    "effect_desc": "每过一个盲注倍率+5%" },
    48: { "name": "井",   "difficulty": 4, "keyword": "汲养",   "effect_id": "round_start_2",      "effect_desc": "每回合开始获$2" },
    50: { "name": "鼎",   "difficulty": 4, "keyword": "革新",   "effect_id": "artifact_use_2",     "effect_desc": "法宝牌可使用2次" },
    51: { "name": "震",   "difficulty": 4, "keyword": "震动",   "effect_id": "first_card_150",     "effect_desc": "首张计分牌×1.5" },
    63: { "name": "既济", "difficulty": 4, "keyword": "已成",   "effect_id": "base_chips_20",      "effect_desc": "所有牌型基础筹码+20" },

    # --- 难度5：变局·风云 ---
    6:  { "name": "讼",   "difficulty": 5, "keyword": "争讼",   "effect_id": "boss_hard_reward",   "effect_desc": "Boss效果加强但奖金×1.5" },
    10: { "name": "履",   "difficulty": 5, "keyword": "践行",   "effect_id": "exact5_mult_130",    "effect_desc": "出牌恰好5张时×1.3" },
    13: { "name": "同人", "difficulty": 5, "keyword": "同心",   "effect_id": "mono_suit_mult_2",   "effect_desc": "全部同花色时倍率×2" },
    30: { "name": "离",   "difficulty": 5, "keyword": "附丽",   "effect_id": "red_chips_20",       "effect_desc": "红色牌(♥♦)+20筹码" },
    38: { "name": "睽",   "difficulty": 5, "keyword": "乖违",   "effect_id": "diverse_suit_mult",  "effect_desc": "不同花色越多倍率越高(+5/种)" },
    49: { "name": "革",   "difficulty": 5, "keyword": "变革",   "effect_id": "replace_beast_1",    "effect_desc": "可重新选择1张异兽替换" },
    55: { "name": "丰",   "difficulty": 5, "keyword": "丰盛",   "effect_id": "chips_mult_10",      "effect_desc": "筹码和倍率各+10" },
    64: { "name": "未济", "difficulty": 5, "keyword": "未成",   "effect_id": "discard_mult_3",     "effect_desc": "每次弃牌+3倍率" },

    # --- 难度6：险境·淬炼 ---
    3:  { "name": "屯",   "difficulty": 6, "keyword": "艰难",   "effect_id": "hand_m1_chips_15",   "effect_desc": "手牌-1但每张计分牌+15筹码" },
    4:  { "name": "蒙",   "difficulty": 6, "keyword": "蒙昧",   "effect_id": "blind_boss",         "effect_desc": "不显示Boss效果（盲打）" },
    18: { "name": "蛊",   "difficulty": 6, "keyword": "整治",   "effect_id": "destroy_for_reward", "effect_desc": "可销毁1张手牌获$5+倍率" },
    29: { "name": "坎",   "difficulty": 6, "keyword": "重险",   "effect_id": "ban_2_suits",        "effect_desc": "Boss禁用2种花色" },
    39: { "name": "蹇",   "difficulty": 6, "keyword": "艰行",   "effect_id": "play_m1_mult_150",   "effect_desc": "出牌数-1但倍率×1.5" },
    44: { "name": "姤",   "difficulty": 6, "keyword": "遭遇",   "effect_id": "lock_1_card",        "effect_desc": "随机1张手牌被锁（不可出）" },
    47: { "name": "困",   "difficulty": 6, "keyword": "困穷",   "effect_id": "money_m50_mult_130", "effect_desc": "金币-50%但倍率×1.3" },
    59: { "name": "涣",   "difficulty": 6, "keyword": "涣散",   "effect_id": "shuffle_hand",       "effect_desc": "手牌随机打乱位置" },

    # --- 难度7：天劫·极限 ---
    12: { "name": "否",   "difficulty": 7, "keyword": "闭塞",   "effect_id": "shop_price_3",       "effect_desc": "商店商品+$3" },
    22: { "name": "贲",   "difficulty": 7, "keyword": "文饰",   "effect_id": "enhanced_x2_plain_m20","effect_desc": "增强牌效果×2但普通牌-20筹码" },
    23: { "name": "剥",   "difficulty": 7, "keyword": "剥落",   "effect_id": "lose_card_per_round","effect_desc": "每回合随机失去1张手牌" },
    27: { "name": "颐",   "difficulty": 7, "keyword": "养正",   "effect_id": "must_have_ak",       "effect_desc": "出牌必须含A或K" },
    33: { "name": "遁",   "difficulty": 7, "keyword": "退避",   "effect_id": "no_skip_reward",     "effect_desc": "跳过盲注不给奖励" },
    36: { "name": "明夷", "difficulty": 7, "keyword": "光明损伤","effect_id": "blind_score",        "effect_desc": "计分面板不显示中间过程" },
    56: { "name": "旅",   "difficulty": 7, "keyword": "旅行",   "effect_id": "beast_slot_m1",      "effect_desc": "异兽栏位-1" },
    62: { "name": "小过", "difficulty": 7, "keyword": "小有过越","effect_id": "max_play_3",         "effect_desc": "只能出≤3张牌" },

    # --- 难度8：终局·天命 ---
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
    return bin_idx / 8

## 获取卦的四象归属（基于上卦）
static func get_sixiang(kingwen: int) -> int:
    var bin_idx = kingwen_to_bin(kingwen)
    var upper = get_upper_trigram(bin_idx)
    return TRIGRAM_TO_SIXIANG.get(upper, SiXiang.XUANWU)

## ================================
## 变爻计算 — 核心路线生成逻辑
## ================================

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
## current_difficulty: 当前卦的难度等级
## allow_same_level: 是否允许同难度（默认true）
## allow_next_level: 是否允许+1难度（默认true）
## min_branches / max_branches: 最少/最多分岔数
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
    
    # 如果可用分岔不够，放宽条件（允许+2难度）
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
    
    # 如果还不够，允许-1难度
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
    
    # 随机打乱后截取
    valid.shuffle()
    if valid.size() > max_branches:
        valid.resize(max_branches)
    
    return valid

## ================================
## 路线生成
## ================================

## 生成一条完整的8卦路线（用于单局游戏）
## 返回 Array[int]，每个元素是文王序
static func generate_route() -> Array[int]:
    var route: Array[int] = []
    
    # 第1卦：从难度1的8个卦中随机选一个
    var tier1 = get_hexagrams_by_difficulty(1)
    tier1.shuffle()
    route.append(tier1[0])
    
    # 第2-8卦：从当前卦的变爻邻居中选择
    for step in range(1, 8):
        var current = route[step - 1]
        var branches = get_route_branches(current, true, true, 2, 3)
        if branches.size() > 0:
            route.append(branches[0])  # AI/玩家在此做选择
        else:
            # fallback: 直接从目标难度池随机选
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
```

---

## 八、路线连通性分析

### 8.1 设计验证要点

为确保任何起始卦都能通过变爻连接到达高难度卦，需要验证：

1. **难度1→2 连通**：每个难度1的卦至少有1个变爻邻居在难度2
2. **难度N→N+1 连通**：每个难度N的卦至少有1个变爻邻居在难度N+1（或N）
3. **无死路**：不存在某个卦完全没有合理的下一步

### 8.2 连通性验证脚本

```gdscript
## 在游戏中运行此函数验证路线连通性
static func validate_connectivity() -> String:
    var report := ""
    for diff in range(1, 8):  # 1-7，检查到下一级的连通
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
                report += "⚠️ 死路: %s(D%d) 无法连接到D%d或D%d\n" % [
                    HEXAGRAM_DATA[kw]["name"], diff, diff, diff + 1]
            elif not has_next:
                report += "⚠️ 弱连: %s(D%d) 只能横向(D%d)，无法升级\n" % [
                    HEXAGRAM_DATA[kw]["name"], diff, diff]
    if report == "":
        report = "✅ 全部64卦连通性验证通过！"
    return report
```

### 8.3 四象平衡分析

| 难度 | 青龙♠ | 朱雀♥ | 白虎♦ | 玄武♣ |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 1(大壮) | 2(夬,兑) | 2(乾,无妄) | 3(坤,泰,临) |
| 2 | 3(小畜,益,渐,巽) | 2(大有,晋,萃) | 1(大畜) | 0 |
| 3 | 2(家人,中孚) | 1(咸) | 2(损,艮) | 3(需,谦,观) |
| 4 | 2(豫,恒,震) | 1(鼎) | 0 | 3(比,升,井,既济) |
| 5 | 1(丰) | 3(离,睽,革,未济) | 3(讼,履,同人) | 0 |
| 6 | 1(涣) | 1(困) | 3(蒙,蛊,姤) | 3(屯,坎,蹇) |
| 7 | 1(小过) | 1(旅) | 4(否,贲,剥,颐,遁) | 1(明夷) |
| 8 | 2(解,归妹) | 2(随,噬嗑,大过) | 0 | 3(师,复,节) |

> **注**：部分等级四象分布不够均匀，可在后续迭代中通过调整难度分配微调。整体上8个等级×8个卦的框架已经可用。

---

## 九、与其他系统的交互接口

### 9.1 卦象→商店影响

```gdscript
## 根据当前卦的四象，调整商店出现的异兽和星宿牌权重
static func get_shop_weight_modifier(kingwen: int) -> Dictionary:
    var sx = get_sixiang(kingwen)
    # 当前四象对应的花色异兽/星宿出现率提升
    var modifier := {
        "beast_suit_bonus": "",    # 提升哪个花色的异兽出现率
        "star_suit_bonus": "",     # 提升哪个花色的星宿出现率
        "bonus_pct": 0.25,         # 提升25%
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
```

### 9.2 四象Boss判定

```gdscript
## 根据走过的8个卦的四象分布，决定最终Boss
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
    
    # 找出出现最多的四象
    var max_sx = SiXiang.QINGLONG
    var max_count = 0
    for sx in counts:
        if counts[sx] > max_count:
            max_count = counts[sx]
            max_sx = sx
    
    return max_sx  # 返回四象枚举值，对应Boss
```

---

## 十、后续待完善

1. **连通性验证**：在Godot中运行 `validate_connectivity()` 检查死路，根据结果微调难度分配
2. **难度曲线调优**：Boss血量×难度系数、盲注目标分数×难度系数的具体数值表
3. **卦德效果实现**：64个 `effect_id` 对应的具体GDScript处理逻辑
4. **路线UI**：卦象选择界面的视觉设计（六角形网格? 树状分岔?）
5. **变爻动画**：玩家选择下一卦时的爻变动画（阴↔阳翻转）
