@tool
extends Control


var list := PackedVector2Array()


func _ready() -> void:
	visible = false
		
	for child: TextureRect in get_children():
		var child_label: Label = child.get_node("Label")
		child_label.text = child.name
		list.append(child.position + child.size / 2)


func _draw() -> void:
	for place: Vector2 in list:
		draw_circle(place, 5, Color.GREEN)
