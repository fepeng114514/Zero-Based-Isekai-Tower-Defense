extends System
class_name SpawnerSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_SPAWNER):
		return true
		
	var spawner_fn: Callable = e.spawner.bind()
	spawner_fn.call()
	
	return true
