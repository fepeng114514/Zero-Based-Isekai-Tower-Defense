@tool
extends Node2D
class_name TowerComponent


## 每个子实体进行远程攻击轮换的间隔
@export var attack_loop_time: float = 0
@export var list: Array[Entity] = []

var attack_entity_idx: int = 0
var ts: float = 0


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if list.is_empty():
		warnings.append("没有子实体节点！ 是否忘记增加子实体节点？")
	
	return warnings
	
	
# 自动更新列表
func _update_list():
	var new_list: Array = []
	
	for child: Node in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()  # 刷新编辑器


# 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_list)


## 清理 list 中已经不存在的实体
func cleanup_list() -> void:
	var new_list: Array[Entity] = []
	
	for sub_e in list:
		if not U.is_vaild_entity(sub_e):
			continue 
			
		new_list.append(sub_e)
		
	list = new_list
