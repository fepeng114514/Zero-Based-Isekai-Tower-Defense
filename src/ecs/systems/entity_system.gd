extends System
class_name EntitySystem
## 实体系统
##
## 处理实体的回调与更新


func _on_insert(e: Entity) -> bool:
	e.insert_ts = TimeMgr.tick_ts

	return e._on_insert()
	

func _on_remove(e: Entity) -> bool:
	if not e._on_remove():
		return false
	
	e.clear_has_mods()
	e.clear_has_auras()

	return true


func _on_update(delta: float) -> void:
	var entities: Array = EntityMgr.get_valid_entities().filter(
		func(e: Entity) -> bool:
			return not e.state & C.State.DEATH and not e.is_waiting()
	)
	
	for e: Entity in entities:
		if U.is_valid_number(e.duration) and TimeMgr.is_ready_time(e.insert_ts, e.duration):
			e.remove_entity()
			continue
			
		if e.track_source:
			var source: Entity = EntityMgr.get_entity_by_id(e.source_id)
			if not source:
				continue
				
			e.global_position = source.global_position
			
		_update_entity(e, delta)
		
	for e: Entity in EntityMgr.get_valid_entities():
		if e.is_first_update:
			e.is_first_update = false
		
	
func _update_entity(e: Entity, delta: float) -> void:
	if e.is_first_update:
		e.play_animation_by_look(e.spawn_animation)
		AudioMgr.play_sfx(e.spawn_sfx)
		if e.spawn_animation:
			await e.wait_animation(e.spawn_animation)
	
	e._on_update(delta)
	
	e.last_position = e.global_position
