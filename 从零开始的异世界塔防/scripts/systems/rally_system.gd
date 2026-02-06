extends System

func _on_update(delta: float) -> void:
	for e in EntityDB.get_entities_by_group(CS.CN_RALLY):
		if e.waitting or not e.state & (CS.STATE_IDLE | CS.STATE_RALLY):
			continue
			
		var rally_c: RallyComponent = e.get_c(CS.CN_RALLY)
		
		if not rally_c.arrived:
			e.state = CS.STATE_RALLY
			walk_step(e, rally_c)
			continue

func walk_step(e: Entity, rally_c: RallyComponent):
	rally_c.direction = (rally_c.rally_pos - e.position).normalized()
	e.position += rally_c.direction * rally_c.speed * TM.frame_length
	e._on_rally_walk(rally_c)
	
	if not rally_c.arrived_rect.has_point(rally_c.rally_pos - e.position):
		return
		
	e.state = CS.STATE_IDLE
	rally_c.arrived = true
	e._on_arrived_rally(rally_c)
