@tool
extends System
class_name BehaviorSystem
## 行为系统
##
## 处理其下的子行为的调用


@export var list: Array[Behavior] = []
#@export var init_priority_list: Array[Behavior] = []
	
func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if list.is_empty():
		warnings.append("没有行为子节点！ 请至少增加一个行为子节点。")
		
	return warnings


## 自动更新列表
func _update_list() -> void:
	var new_list: Array[Behavior] = []
	
	for child: Behavior in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_list)
	
	
func _on_insert(e: Entity) -> bool:
	if not call_behaviors("_on_insert", e):
		return false
		
	return true


func _on_remove(e: Entity) -> bool:
	if not call_behaviors("_on_remove", e):
		return false
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityDB.get_vaild_entities():
		if e.is_waiting():
			continue
		
		var break_behavior: Behavior = _process_update(e)
		
		if break_behavior:
			for behavior: Behavior in list:
				behavior._on_return_true(e, break_behavior)
			continue

		for behavior: Behavior in list:
			behavior._on_return_false(e)

		if not e.has_c(C.CN_SPRITE):
			continue
			
		e.play_idle_animation()
			
			
func _process_update(e: Entity) -> Behavior:
	for behavior: Behavior in list:
		var behavior_func = behavior.get("_on_update")

		if behavior_func.call(e):
			return behavior

	return null


## 调用所有行为树中的指定回调函数，如果遇到一个返回 false 的行为则返回 false，否则返回 true
func call_behaviors(fn_name: String, arg) -> bool:
	for behavior: Behavior in list:
		var behavior_func = behavior.get(fn_name)

		if not behavior_func.call(arg):
			return false

	return true
