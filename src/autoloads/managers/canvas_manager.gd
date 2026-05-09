extends Node


@onready var canvas_transform: Transform2D = get_viewport().canvas_transform
@onready var canvas_transform_affine_inverse: Transform2D = canvas_transform.affine_inverse()


func screen_to_world(v: Vector2) -> Vector2:
	return v * canvas_transform
	
	
func world_to_screen(v: Vector2) -> Vector2:
	return v * canvas_transform_affine_inverse
