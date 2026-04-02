@tool
extends Control


@export var position_list: Array[Vector2] = []


func _ready() -> void:
	visible = false


## 自动更新位置列表
func _update_position_list() -> void:
	var new_position_list: Array[Vector2] = []
	
	for holder: TextureRect in get_children():
		new_position_list.append(holder.position)
	
	# 只在变化时更新，避免无限循环
	if new_position_list != position_list:
		position_list = new_position_list
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	EditorUtils.tool_on_tree_call(self, what, _update_position_list)
