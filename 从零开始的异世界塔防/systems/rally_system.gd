extends System


func _initialize() -> void:
	whitelist_state = C.STATE_IDLE | C.STATE_RALLY
	wait_entity = true


func _on_update(delta: float) -> void:
	process_entities(C.CN_RALLY, func(e: Entity):
		var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
		
		if not rally_c.arrived:
			e.state = C.STATE_RALLY
			walk_step(e, rally_c)
			return
	)

func walk_step(e: Entity, rally_c: RallyComponent) -> void:
	e.play_animation("walk")
	rally_c.direction = (rally_c.rally_pos - e.position).normalized()
	e.position += rally_c.direction * rally_c.speed * TimeDB.frame_length
	e._on_rally_walk(rally_c)
	
	if not U.is_at_destination(rally_c.rally_pos, e.position, rally_c.arrived_dist):
		return
		
	e.state = C.STATE_IDLE
	rally_c.arrived = true
	e._on_arrived_rally(rally_c)
