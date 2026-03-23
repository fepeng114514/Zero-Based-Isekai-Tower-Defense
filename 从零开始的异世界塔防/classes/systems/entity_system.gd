extends System
class_name EntitySystem
## 实体系统
##
## 处理实体的回调与更新


func _on_insert(e: Entity) -> bool:
	e.insert_ts = TimeDB.tick_ts

	return e._on_insert()
	

func _on_remove(e: Entity) -> bool:
	if not e._on_remove():
		return false
	
	e.clear_has_mods()
	e.clear_has_auras()

	return true

func _on_update(delta: float) -> void:
	for e: Entity in EntityDB.get_vaild_entities():
		if U.is_valid_number(e.duration) and TimeDB.is_ready_time(e.insert_ts, e.duration):
			e.remove_entity()
			continue
			
		if U.is_valid_number(e.source_id) and e.track_source:
			var source: Entity = EntityDB.get_entity_by_id(e.source_id)
			
			if not source:
				continue
				
			e.global_position = source.global_position
			
		if e.is_waiting():
			continue
			
		e._on_update(delta)
		
		e.last_position = e.global_position
