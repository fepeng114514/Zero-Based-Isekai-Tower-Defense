extends Node

var tick_ts: float = 0
var tick: int = 0
var frame_length: float = 0
var fps: float = 0
var timers: Dictionary = {}
@onready var curren_scene = get_tree()

func _process(delta: float) -> void:
	tick_ts += delta
	tick += 1
	frame_length = delta
	fps = Engine.get_frames_per_second()
	
func is_ready_time(ts: float, time: float) -> bool:
	return tick_ts - ts > time
	
func get_time(ts) -> float:
	return tick_ts - ts
	
func y_wait(time: float, break_fn = null) -> void:
	var ts = tick_ts
	while not is_ready_time(ts, time) and (not break_fn or break_fn.call()):
		await curren_scene.process_frame
