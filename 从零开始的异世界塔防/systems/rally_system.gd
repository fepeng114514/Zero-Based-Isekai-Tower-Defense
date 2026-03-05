extends System
class_name RallySystem


func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_entities_group(C.CN_RALLY).filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and e.has_state(C.STATE.RALLY | C.STATE.IDLE)
	)

	for e: Entity in entities:
		var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
		
		if rally_c.arrived:
			continue

		walk_step(e, rally_c)
		
		if not rally_c.is_navigation_finished():
			continue
			
		e.state = C.STATE.IDLE
		rally_c.arrived = true
		e.play_animation(e.default_animation)

		e._on_arrived_rally(rally_c)
		
		if e.has_c(C.CN_MELEE):
			var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
			melee_c.set_origin_pos(e.global_position)


func walk_step(e: Entity, rally_c: RallyComponent) -> void:
	e.play_animation(rally_c.animation)
	
	var next_position: Vector2 = rally_c.get_next_path_position()
	var direction: Vector2 = (
		next_position - e.global_position
	).normalized()
	var velocity: Vector2 = (
		direction 
		* rally_c.speed 
		* TimeDB.frame_length
	)
	e.global_position += velocity
	rally_c.velocity = velocity
	
	e._on_rally_walk(rally_c)
