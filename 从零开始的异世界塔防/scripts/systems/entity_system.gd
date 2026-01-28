extends System
class_name EntitySystem

func on_insert(e: Entity) -> bool:
	return e.on_insert()
	
func on_remove(e: Entity) -> bool:
	return e.on_remove()

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not is_instance_valid(e) or e.removed:
			continue
			
		if not e.waiting:
			e.on_update(delta)
