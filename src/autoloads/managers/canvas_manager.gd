extends Node


# 世界坐标 → 屏幕坐标
func world_to_screen(world_pos: Vector2) -> Vector2:
	var canvas_transform = get_viewport().canvas_transform
	return canvas_transform * world_pos

# 屏幕坐标 → 世界坐标
func screen_to_world(screen_pos: Vector2) -> Vector2:
	var canvas_transform = get_viewport().canvas_transform
	return canvas_transform.affine_inverse() * screen_pos
