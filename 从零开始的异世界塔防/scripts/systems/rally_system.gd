extends System

func _on_update(delta: float) -> void:
	for e in EntityDB.get_entities_by_group(CS.CN_RALLY):
		var state: int = e.state
			
		if e.waitting or not state & CS.STATE_IDLE:
			continue
			
		var rally_c: RallyComponent = e.get_c(CS.CN_RALLY)
		
		if rally_c.arrived:
			continue
			
		rally_c.direction = (rally_c.rally_pos - e.position).normalized()
		e.position += rally_c.direction * rally_c.speed * delta
		e._on_rally_walk(rally_c)
		
		if rally_c.arrived_rect.has_point(rally_c.rally_pos - e.position):
			rally_c.arrived = true
			e._on_arrived_rally(rally_c)
			continue
		# 待实现动画播放
