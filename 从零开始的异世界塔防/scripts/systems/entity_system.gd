extends System

func _on_create(e: Entity) -> bool:
	return e._on_create()

func _on_insert(e: Entity) -> bool:
	return e._on_insert()
	
func _on_remove(e: Entity) -> bool:
	return e._on_remove()

func _on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e):
			continue
			
		if e.waitting:
			continue
			
		e._on_update(delta)
