extends System

"""
时间系统，控制时间与计时器
"""


func _on_update(delta: float) -> void:
	TimeDB.tick_ts += delta
	TimeDB.tick += 1
	TimeDB.frame_length = delta
	TimeDB.fps = Engine.get_frames_per_second()
	process_entity_timer(delta)
	

func process_entity_timer(delta: float) -> void:
	for e: Entity in EntityDB.get_vaild_entities():
		if e.wait_clock <= 0:
			e.y_waiting = false

			for action_func: Callable in e.wait_action_queue:
				action_func.call(e)

			e.wait_action_queue = []

			continue

		e.wait_clock -= delta
