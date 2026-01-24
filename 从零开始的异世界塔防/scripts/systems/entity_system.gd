extends System
class_name EntitySystem

func on_insert(entity: Entity) -> bool:
	if not entity.get("insert"):
		return true
		
	return entity.insert()
	
func on_remove(entity: Entity) -> bool:
	if not entity.get("remove"):
		return true
		
	return entity.remove()

func on_update(delta: float) -> void:
	for entity in EntityDB.entities:
		if not is_instance_valid(entity) or not entity.get("update"):
			continue
			
		entity.update(delta)
