extends System
class_name EntitySystem

func on_insert(e: Entity) -> bool:
	if not e.get("insert"):
		return true
		
	return e.insert()
	
func on_remove(e: Entity) -> bool:
	if not e.get("remove"):
		return true
		
	return e.remove()

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not is_instance_valid(e) or not e.get("update") or e.removed :
			continue
			
		e.update()
