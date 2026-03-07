@tool
extends System
class_name BehaviorSystem


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
	if not call_systems("_on_insert", e):
		return false
		
	return true


func _on_remove(e: Entity) -> bool:
	if not call_systems("_on_remove", e):
		return false
		
	return true
	
	
func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_vaild_entities().filter(
		func(e: Entity) -> bool:
			return not e.is_waiting()
	)
	
	for e: Entity in entities:
		var result: bool = _process_update(e)
		
		if result:
			call_systems("_on_return_true", e)
			continue

		call_systems("_on_return_false", e)
		if not e.has_c(C.CN_SPRITE):
			continue
			
		e.play_animation(e.default_animation)	
			
			
func _process_update(e: Entity) -> bool:
	for system: Behavior in list:
		var system_func = system.get("_on_update")

		if system_func.call(e):
			return true
			
	return false


## 调用所有行为树中所有系统中的指定回调函数
func call_systems(fn_name: String, arg) -> bool:
	for system: Behavior in list:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
	
	
