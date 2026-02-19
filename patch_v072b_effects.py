#!/usr/bin/env python3
"""V0.072b 架构优化补丁 — 抽取 TarotEffect + BossEffect
在 BalatraPrototype 根目录执行: python3 patch_v072b_effects.py"""
import os

def patch_file(path, replacements):
    if not os.path.exists(path):
        print(f"  ❌ 文件不存在: {path}")
        return False
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    changed = False
    for old, new, desc in replacements:
        if old in content:
            content = content.replace(old, new, 1)
            print(f"  ✅ {desc}")
            changed = True
        else:
            print(f"  ⚠️ 未找到: {desc}")
    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
    return changed

print("=" * 55)
print("V0.072b — TarotEffect + BossEffect 抽取")
print("=" * 55)

# ==========================================
# main.gd
# ==========================================
print("\n[1/1] main.gd")

patch_file("scripts/main.gd", [
    # 1. 替换 Boss 效果处理（~30行 → 1行调用）
    (
        """## ========== Boss 效果 ==========

func _apply_boss_to_result(result: Dictionary) -> void:
\tif GS.current_boss == null:
\t\treturn
\tmatch GS.current_boss.effect:
\t\tBlindData.BossEffect.NO_FACE_CARDS:
\t\t\tvar new_chips = result["base_chips"] + result.get("level_bonus_chips", 0)
\t\t\tfor card in result["scoring_cards"]:
\t\t\t\tif card.card_data.rank < 11:
\t\t\t\t\tnew_chips += card.card_data.get_chip_value()
\t\t\tresult["total_chips"] = new_chips
\t\t\tresult["final_score"] = new_chips * result["total_mult"]
\t\tBlindData.BossEffect.NO_HEARTS:
\t\t\t_debuff_suit(result, CardData.Suit.HEARTS)
\t\tBlindData.BossEffect.NO_DIAMONDS:
\t\t\t_debuff_suit(result, CardData.Suit.DIAMONDS)
\t\tBlindData.BossEffect.NO_SPADES:
\t\t\t_debuff_suit(result, CardData.Suit.SPADES)
\t\tBlindData.BossEffect.NO_CLUBS:
\t\t\t_debuff_suit(result, CardData.Suit.CLUBS)
\t\tBlindData.BossEffect.DEBUFF_FIRST_HAND:
\t\t\tif GS.hands_played_this_round == 0:
\t\t\t\tresult["total_chips"] = int(result["total_chips"] / 2)
\t\t\t\tresult["final_score"] = int(result["total_chips"] * result["total_mult"])

func _debuff_suit(result: Dictionary, suit) -> void:
\tvar new_chips = result["base_chips"] + result.get("level_bonus_chips", 0)
\tfor card in result["scoring_cards"]:
\t\tif card.card_data.suit != suit:
\t\t\tnew_chips += card.card_data.get_chip_value()
\tresult["total_chips"] = new_chips
\tresult["final_score"] = new_chips * result["total_mult"]""",

        """## ========== Boss 效果（委托 BossEffect 处理器）==========

func _apply_boss_to_result(result: Dictionary) -> void:
\tBossEffect.apply_to_result(result, GS.current_boss, GS.hands_played_this_round)""",

        "Boss 效果 → BossEffect.apply_to_result()"
    ),

    # 2. 替换塔罗牌效果处理（~120行 → ~15行）
    (
        """func _on_tarot_used(tarot: TarotData) -> void:
\tvar selected = hand.get_selected_cards()
\tmatch tarot.effect:
\t\tTarotData.TarotEffect.COPY_CARD:
\t\t\tif selected.size() >= 1:
\t\t\t\tvar src = selected[0]
\t\t\t\tvar new_data = CardData.new()
\t\t\t\tnew_data.suit = src.card_data.suit
\t\t\t\tnew_data.rank = src.card_data.rank
\t\t\t\thand.add_card(new_data, true)
\t\t\t\tinfo_label.text = "🃏 Copied " + src.card_data.get_display_name() + "!"
\t\t\t\tinfo_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

\t\tTarotData.TarotEffect.RANDOM_SUIT:
\t\t\tif selected.size() >= 1:
\t\t\t\tvar card = selected[0]
\t\t\t\tvar suits = [CardData.Suit.HEARTS, CardData.Suit.DIAMONDS, CardData.Suit.CLUBS, CardData.Suit.SPADES]
\t\t\t\tvar old_suit = card.card_data.suit
\t\t\t\tsuits.erase(old_suit)
\t\t\t\tcard.card_data.suit = suits[randi() % suits.size()]
\t\t\t\tcard.is_selected = false
\t\t\t\tcard.queue_redraw()
\t\t\t\tinfo_label.text = "🎩 Changed to " + card.card_data.get_suit_symbol() + "!"
\t\t\t\tinfo_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

\t\tTarotData.TarotEffect.CHANGE_TO_HEARTS:
\t\t\t_change_suit(selected, CardData.Suit.HEARTS, "♥")

\t\tTarotData.TarotEffect.CHANGE_TO_SPADES:
\t\t\t_change_suit(selected, CardData.Suit.SPADES, "♠")

\t\tTarotData.TarotEffect.CHANGE_TO_CLUBS:
\t\t\t_change_suit(selected, CardData.Suit.CLUBS, "♣")

\t\tTarotData.TarotEffect.CHANGE_TO_DIAMONDS:
\t\t\t_change_suit(selected, CardData.Suit.DIAMONDS, "♦")

\t\tTarotData.TarotEffect.DESTROY_CARD:
\t\t\tif selected.size() >= 1:
\t\t\t\tvar card = selected[0]
\t\t\t\tvar name_text = card.card_data.get_display_name()
\t\t\t\thand.cards_in_hand.erase(card)
\t\t\t\tcard.queue_free()
\t\t\t\thand._arrange_cards()
\t\t\t\thand.hand_changed.emit()
\t\t\t\tinfo_label.text = "💀 Destroyed " + name_text + "!"
\t\t\t\tinfo_label.add_theme_color_override("font_color", GC.COLOR_ERROR)

\t\tTarotData.TarotEffect.GAIN_MONEY:
\t\t\tGS.money += 5
\t\t\tinfo_label.text = "🔮 " + Loc.i().t("The Hermit") + " +$5!"
\t\t\tinfo_label.add_theme_color_override("font_color", GC.COLOR_MONEY)
\t\t\t_update_ui()

\t\tTarotData.TarotEffect.CLONE_CARD:
\t\t\tif selected.size() >= 2:
\t\t\t\tvar left_idx = hand.cards_in_hand.find(selected[0])
\t\t\t\tvar right_idx = hand.cards_in_hand.find(selected[1])
\t\t\t\tvar src_card: Node2D
\t\t\t\tvar dst_card: Node2D
\t\t\t\tif left_idx < right_idx:
\t\t\t\t\tdst_card = selected[0]
\t\t\t\t\tsrc_card = selected[1]
\t\t\t\telse:
\t\t\t\t\tdst_card = selected[1]
\t\t\t\t\tsrc_card = selected[0]
\t\t\t\tdst_card.card_data.suit = src_card.card_data.suit
\t\t\t\tdst_card.card_data.rank = src_card.card_data.rank
\t\t\t\tdst_card.is_selected = false
\t\t\t\tsrc_card.is_selected = false
\t\t\t\tdst_card.queue_redraw()
\t\t\t\tsrc_card.queue_redraw()
\t\t\t\tinfo_label.text = "⚖️ Card transformed to " + src_card.card_data.get_display_name() + "!"
\t\t\t\tinfo_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

\t\tTarotData.TarotEffect.SPAWN_TAROT:
\t\t\tvar empty = consumable_slot.get_empty_slots()
\t\t\tvar to_add = mini(2, empty)
\t\t\tif to_add <= 0:
\t\t\t\tinfo_label.text = "🌎 " + Loc.i().t("No empty slots!")
\t\t\t\tinfo_label.add_theme_color_override("font_color", GC.COLOR_ERROR)
\t\t\telse:
\t\t\t\tvar new_tarots = TarotDatabase.get_random_tarots(to_add)
\t\t\t\tvar names: PackedStringArray = []
\t\t\t\tfor t in new_tarots:
\t\t\t\t\tconsumable_slot.add_tarot(t)
\t\t\t\t\tnames.append(t.tarot_name)
\t\t\t\tinfo_label.text = "🌎 Created " + ", ".join(names) + "!"
\t\t\t\tinfo_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))

\t\tTarotData.TarotEffect.SPAWN_PLANET:
\t\t\tvar empty = consumable_slot.get_empty_slots()
\t\t\tvar to_add = mini(2, empty)
\t\t\tif to_add <= 0:
\t\t\t\tinfo_label.text = "☀️ " + Loc.i().t("No empty slots!")
\t\t\t\tinfo_label.add_theme_color_override("font_color", GC.COLOR_ERROR)
\t\t\telse:
\t\t\t\tvar new_planets = PlanetDatabase.get_random_planets(to_add)
\t\t\t\tvar names: PackedStringArray = []
\t\t\t\tfor p in new_planets:
\t\t\t\t\tconsumable_slot.add_planet(p)
\t\t\t\t\tnames.append(p.planet_name)
\t\t\t\tinfo_label.text = "☀️ Created " + ", ".join(names) + "!"
\t\t\t\tinfo_label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.95))

\t\tTarotData.TarotEffect.RANDOM_LEVEL_UP:
\t\t\tvar types = PokerHand.HandType.values()
\t\t\tvar random_type = types[randi() % types.size()]
\t\t\tHandLevel.planet_level_up(random_type, 20, 2)
\t\t\tHandLevel.planet_level_up(random_type, 20, 2)
\t\t\tvar hname = PokerHand.get_hand_name(random_type)
\t\t\tvar lvl = HandLevel.get_level_info(random_type)["level"]
\t\t\tinfo_label.text = "🎰 " + Loc.i().t(hname) + " → Lv." + str(lvl) + "!"
\t\t\tinfo_label.add_theme_color_override("font_color", GC.COLOR_MONEY)
\t\t\tscore_display.show_level_up(hname, lvl)

\t_update_preview()

func _change_suit(cards: Array, new_suit: int, symbol: String) -> void:
\tvar changed = 0
\tfor card in cards:
\t\tcard.card_data.suit = new_suit
\t\tcard.is_selected = false
\t\tcard.queue_redraw()
\t\tchanged += 1
\tinfo_label.text = "Changed " + str(changed) + " card(s) to " + symbol + "!"
\tinfo_label.add_theme_color_override("font_color", Color(0.7, 0.35, 0.75))""",

        """func _on_tarot_used(tarot: TarotData) -> void:
\tvar selected = hand.get_selected_cards()
\tvar result = TarotEffect.apply(tarot, selected, hand, consumable_slot)
\tif result["message"] != "":
\t\tinfo_label.text = result["message"]
\t\tinfo_label.add_theme_color_override("font_color", result["color"])
\t## GAIN_MONEY 需要刷新 UI
\tif tarot.effect == TarotData.TarotEffect.GAIN_MONEY:
\t\t_update_ui()
\t## RANDOM_LEVEL_UP 需要显示升级动画
\tif result.has("level_up"):
\t\tscore_display.show_level_up(result["level_up"]["hand_name"], result["level_up"]["level"])
\t_update_preview()""",

        "塔罗牌效果 → TarotEffect.apply()"
    ),

    # 3. 更新文件头注释
    (
        "## 游戏主场景 V0.071 — 架构重构: 场景树化 + 状态单例\n## 变更: @onready 引用替代手动节点创建, GameState 管理状态, GameConfig 管理常量",
        "## 游戏主场景 V0.072b — TarotEffect/BossEffect 抽取\n## 架构: 场景树化 + 状态单例 + 效果处理器",
        "更新文件头注释"
    ),
])

# count lines
if os.path.exists("scripts/main.gd"):
    with open("scripts/main.gd", 'r', encoding='utf-8') as f:
        lines = len(f.readlines())
    print(f"\n  main.gd 当前行数: {lines}")

print("\n" + "=" * 55)
print("补丁完成！")
print("=" * 55)
print()
print("新增文件（需复制到 scripts/ 目录）:")
print("  - tarot_effect.gd")
print("  - boss_effect.gd")
print()
print("然后执行此脚本修改 main.gd:")
print("  cd ~/文稿/CYP\\ Works/BalatraPrototype")
print("  python3 patch_v072b_effects.py")
