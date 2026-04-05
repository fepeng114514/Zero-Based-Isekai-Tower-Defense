@tool
extends Control


var list: Array[Vector2] = []


func _ready() -> void:
	visible = false

	if Engine.is_editor_hint():
		return
		
	for child: TextureRect in get_children():
		list.append(child.position)
