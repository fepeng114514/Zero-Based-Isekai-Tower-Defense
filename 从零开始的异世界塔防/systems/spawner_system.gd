extends System


func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_SPAWNER):
		return true
		
	e._spawner.call()
	
	return true
