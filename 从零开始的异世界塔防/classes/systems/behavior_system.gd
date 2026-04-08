@tool
extends System
class_name BehaviorSystem
## 行为系统
##
## 处理其下的子行为的调用


var list: Array[Behavior] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	for child: Behavior in get_children():
		list.append(child)


func _on_insert(e: Entity) -> bool:
	if not call_behaviors("_on_insert", e):
		return false
		
	return true


func _on_remove(e: Entity) -> bool:
	if not call_behaviors("_on_remove", e):
		return false
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_valid_entities():
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
