extends System
class_name FXSystem
## 特效系统
##
## 处理拥有 [FXComponent] 特效组件的实体


func _on_insert(e: Entity) -> bool:
	var fx_c: FXComponent = e.get_node_or_null(C.CN_FX)
	if not fx_c:
		return true
		
	_timer_remove_once(e, fx_c)
		
	return true


func _timer_remove_once(e: Entity, _fx_c: FXComponent) -> void:
	await e.wait_animation(e.idle_animation)
	e.remove_entity()
