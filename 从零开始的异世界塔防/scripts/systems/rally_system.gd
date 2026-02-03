extends System
class_name RallySystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_RALLY):
		return true
		
	var rally_c: RallyComponent = e.get_c(CS.CN_RALLY)

	rally_c.direction = (rally_c.rally_pos - e.position).normalized()
		
	return true

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e) or not e.has_c(CS.CN_RALLY):
			continue
			
		var state: int = e.state
			
		if e.waitting or not state & CS.STATE_IDLE:
			continue
			
		var rally_c: RallyComponent = e.get_c(CS.CN_RALLY)
		
		if rally_c.arrived:
			continue
			
		e.position += rally_c.direction * rally_c.speed * delta
		e.on_rally_walk(rally_c)
		rally_c.direction = (rally_c.rally_pos - e.position).normalized()
		
		if rally_c.arrived_rect.has_point(e.position - rally_c.rally_pos):
			rally_c.arrived = true
			continue
		# 待实现动画播放
