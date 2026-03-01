extends System

"""时间系统
	控制与管理时间与计时器
"""


func _on_update(delta: float) -> void:
	TimeDB.tick_ts += delta
	TimeDB.tick += 1
	TimeDB.frame_length = delta
	TimeDB.fps = Engine.get_frames_per_second()
