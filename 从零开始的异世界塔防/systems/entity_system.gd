extends System


func _on_ready_insert(e: Entity) -> bool:
	return e._on_ready_insert()


func _on_insert(e: Entity) -> bool:
	e.insert_ts = TimeDB.tick_ts

	EntityDB.create_auras(e.auras_list, e.id)

	return e._on_insert()
	

func _on_ready_remove(e: Entity) -> bool:
	return e._on_ready_remove()
	

func _on_remove(e: Entity) -> void:
	e._on_remove()
	
	e.clear_has_mods()
	e.clear_has_auras()


func _on_update(delta: float) -> void:
	for e: Entity in EntityDB.get_vaild_entities():
		if e.duration != -1 and TimeDB.is_ready_time(e.insert_ts, e.duration):
			e.remove_entity()
			continue
			
		if e.source_id != -1 and e.track_source:
			var source = EntityDB.get_entity_by_id(e.source_id)
			
			if not source:
				continue
				
			e.position = source.position
			
		if e.y_waiting or e.wait_clock > 0:
			continue
			
		e._on_update(delta)
		
		e.last_position = e.position
