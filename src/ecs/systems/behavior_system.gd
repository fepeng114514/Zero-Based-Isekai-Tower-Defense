extends System
class_name BehaviorSystem
## 行为系统
##
## 处理其下的子行为的调用


var _behaviors: Array[Behavior] = []
var _update_cbs: Array[Callable] = []
var _insert_cbs: Array[Callable] = []
var _remove_cbs: Array[Callable] = []
var _skip_cbs: Array[Callable] = []
var _behavior_count: int = 0


func _ready() -> void:
	_behavior_count = get_child_count()

	for child: Behavior in get_children():
		_behaviors.append(child)
		_update_cbs.append(child.get("_on_update"))
		_insert_cbs.append(child.get("_on_insert"))
		_remove_cbs.append(child.get("_on_remove"))
		_skip_cbs.append(child.get("_on_skip"))


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
	var entities: Array = EntityMgr.get_valid_entities().filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and not e.state & C.State.DEATH
	)
	
	for e: Entity in entities:
		var is_break: bool = false
		for i: int in _behavior_count:
			var updata_fn: Callable = _update_cbs[i]
			
			if updata_fn.call(e):
				for skiped_i: int in range(i + 1, _behavior_count):
					var skip_fn: Callable = _skip_cbs[skiped_i]
					skip_fn.call(e)
				
				is_break = true
				break
			
		if not is_break:
			if not e.get_node_or_null(C.CN_SPRITE):
				continue
				
			e.play_animation_by_look(e.idle_animation)
			
			
