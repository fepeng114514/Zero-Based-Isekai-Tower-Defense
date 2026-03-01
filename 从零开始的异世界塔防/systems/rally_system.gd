extends System


func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_entities_group(C.CN_RALLY).filter(
		func(e: Entity) -> bool:
			return not e.waiting and e.has_state(C.STATE.RALLY | C.STATE.IDLE)
	)

	for e: Entity in entities:
		var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
		
		if rally_c.arrived:
			continue

		e.state = C.STATE.RALLY
		walk_step(e, rally_c)
		
		if not U.is_at_destination(rally_c.rally_pos, e.position, rally_c.arrived_dist):
			return
			
		e.state = C.STATE.IDLE
		rally_c.arrived = true

		e._on_arrived_rally(rally_c)


func walk_step(e: Entity, rally_c: RallyComponent) -> void:
	e.play_animation(rally_c.animation)

	rally_c.direction = (rally_c.rally_pos - e.position).normalized()
	e.position += rally_c.direction * rally_c.speed * TimeDB.frame_length

	e._on_rally_walk(rally_c)
