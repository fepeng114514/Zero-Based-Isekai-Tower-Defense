extends System

func _on_update(delta: float) -> void:
	TM.tick_ts += delta
	TM.tick += 1
	TM.frame_length = delta
	TM.fps = Engine.get_frames_per_second()
	process_entity_timer(delta)
	
func process_entity_timer(delta: float) -> void:
	for e: Entity in E.get_vaild_entities():
		e.waittimer -= delta
