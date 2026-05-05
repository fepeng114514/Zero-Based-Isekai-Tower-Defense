@tool
extends Control


var list: Array[Vector2] = []


func _ready() -> void:
	visible = false
		
	for child: TextureRect in get_children():
		var child_label: Label = child.get_node("Label")
		child_label.text = child.name
		list.append(child.position)
