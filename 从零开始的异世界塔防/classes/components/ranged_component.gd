@tool
extends Node2D
class_name RangedComponent

## 是否禁用索敌
@export var disabled_search: bool = false
## 远程攻击列表
@export var list: Array[RangedAttack] = []


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if list.is_empty():
		warnings.append("没有攻击子节点！ 请至少增加一个攻击子节点。")
	
	return warnings
	

## 自动更新列表
func _update_list() -> void:
	var new_list: Array[RangedAttack] = []
	
	for child: RangedAttack in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()
		

## 当节点树变化时自动更新
func _notification(what: int) -> void:
	EditorUtils.tool_on_tree_call(self, what, _update_list)
