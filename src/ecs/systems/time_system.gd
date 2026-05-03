extends System
class_name TimeSystem
## 时间系统
##
## 处理时间


func _on_update(delta: float) -> void:
	TimeMgr.tick_ts += delta
	TimeMgr.tick += 1
	TimeMgr.frame_length = delta
	TimeMgr.fps = Engine.get_frames_per_second()
