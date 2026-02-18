## shop_particle_draw.gd
## 商店粒子动画绘制器
extends Node2D

var shop_ref = null

func _process(_delta: float) -> void:
	if shop_ref and shop_ref.anim_particles.size() > 0:
		queue_redraw()

func _draw() -> void:
	if shop_ref == null:
		return
	for p in shop_ref.anim_particles:
		var alpha = clampf(p["life"] / p["max_life"], 0.0, 1.0)
		var c = p["color"]
		c.a = alpha
		var s = p["size"] * alpha
		draw_rect(Rect2(p["pos"].x - s / 2, p["pos"].y - s / 2, s, s), c)
