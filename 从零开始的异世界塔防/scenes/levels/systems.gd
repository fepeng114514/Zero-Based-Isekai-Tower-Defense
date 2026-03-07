@tool
extends Node
class_name Systems

@export var list: Array[System] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	SystemMgr.load(list)
	
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if list.is_empty():
		warnings.append("没有系统子节点！ 请至少增加一个系统子节点。")
	
	return warnings
	

## 自动更新列表
func _update_list() -> void:
	var new_list: Array[System] = []
	
	for child: System in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_list)
