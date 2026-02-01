extends Node

var tick_ts: float = 0
var tick: int = 0
var frame_length: float = 0
var fps: float = 0
var timers: Dictionary = {}

func _process(delta: float) -> void:
	tick_ts += delta
	tick += 1
	frame_length = delta
	fps = Engine.get_frames_per_second()
	
func is_ready_time(ts: float, time: float) -> bool:
	return tick_ts - ts > time
	
func get_time(ts) -> float:
	return tick_ts - ts
	
func create_once_timer(time: float) -> Signal:
	return GlobalStore.curren_scene.create_timer(time).timeout
