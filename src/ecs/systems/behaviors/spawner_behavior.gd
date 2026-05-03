extends Behavior
class_name SpawnerBehavior
## 生成器行为系统
##
## 处理拥有 [SpawnerComponent] 生成器组件的实体


func _on_insert(e: Entity) -> bool:
	if not e.get_node_or_null(C.CN_SPAWNER):
		return true
		
	e._spawner.call()
	
	return true
