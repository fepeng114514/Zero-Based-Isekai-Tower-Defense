extends System

func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_SPAWNER):
		return true
		
	var spawner_fn: Callable = e._spawner.bind()
	spawner_fn.call()
	
	return true
