extends System
class_name EntitySystem

func on_create(e: Entity) -> bool:
	return e.on_create()

func on_insert(e: Entity) -> bool:
	return e.on_insert()
	
func on_remove(e: Entity) -> bool:
	return e.on_remove()

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e):
			continue
			
		if e.waiting:
			continue
			
		e.on_update(delta)
