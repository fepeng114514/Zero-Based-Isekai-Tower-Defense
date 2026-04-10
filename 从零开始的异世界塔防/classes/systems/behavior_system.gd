extends System
class_name BehaviorSystem
## 行为系统
##
## 处理其下的子行为的调用


var _behaviors: Array[Behavior] = []
var _update_cbs: Array[Callable] = []
var _return_true_cbs: Array[Callable] = []
var _return_false_cbs: Array[Callable] = []
var _insert_cbs: Array[Callable] = []
var _remove_cbs: Array[Callable] = []
var _behavior_count: int = 0


func _ready() -> void:
	for child: Behavior in get_children():
		_behaviors.append(child)
		_update_cbs.append(child.get("_on_update"))
		_return_true_cbs.append(child.get("_on_return_true"))
		_return_false_cbs.append(child.get("_on_return_false"))
		_insert_cbs.append(child.get("_on_insert"))
		_remove_cbs.append(child.get("_on_remove"))
		_behavior_count += 1

func _on_insert(e: Entity) -> bool:
	for insert_fn: Callable in _insert_cbs:
		if not insert_fn.call(e):
			return false

	return true


func _on_remove(e: Entity) -> bool:
	for remove_fn: Callable in _remove_cbs:
		if not remove_fn.call(e):
			return false

	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_valid_entities():
		if e.is_waiting():
			continue
		
		var break_behavior: Behavior = null

		for i: int in range(_behavior_count):
			var updata_fn: Callable = _update_cbs[i]

			if updata_fn.call(e):
				break_behavior = _behaviors[i]
				break
		
		if break_behavior:
			for return_true_fn: Callable in _return_true_cbs:
				return_true_fn.call(e, break_behavior)
			continue

		for return_false_fn: Callable in _return_false_cbs:
			return_false_fn.call(e)

		if not e.has_c(C.CN_SPRITE):
			continue
			
		e.play_animation_by_look(e.idle_animation)
			
			
