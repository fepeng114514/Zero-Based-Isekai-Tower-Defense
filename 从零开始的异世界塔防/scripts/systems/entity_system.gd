extends System

func _on_ready_insert(e: Entity) -> bool:
	return e._on_ready_insert()

func _on_insert(e: Entity) -> bool:
	e.insert_ts = TM.tick_ts
	return e._on_insert()
	
func _on_ready_remove(e: Entity) -> bool:
	return e._on_ready_remove()
	
func _on_remove(e: Entity) -> void:
	e._on_remove()

func _on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e):
			continue
			
		if e.duration != -1 and TM.is_ready_time(e.insert_ts, e.duration):
			EntityDB.remove_entity(e)
			continue
			
		if e.source_id != -1 and e.track_source:
			var source = EntityDB.get_entity_by_id(e.source_id)
			
			if not source:
				continue
				
			e.position = source.position
			
		if e.waitting:
			continue
			
		e._on_update(delta)
