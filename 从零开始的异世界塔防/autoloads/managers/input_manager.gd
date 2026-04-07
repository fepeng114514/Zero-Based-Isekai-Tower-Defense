extends Node2D


var mouse_global_position := Vector2.ZERO


func _input(_event: InputEvent) -> void:
	mouse_global_position = get_global_mouse_position()
