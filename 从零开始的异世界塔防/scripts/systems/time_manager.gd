extends Node

var tick_ts: float = 0
var tick: int = 0
var frame_length: float = 0
var timers: Dictionary = {}

func _process(delta: float) -> void:
	tick_ts += delta
	tick += 1
	frame_length = delta
	
	var to_remove: Array = []
	
	for key in timers:
		var timer = timers[key]
		timer.elapsed += delta
		if timer.elapsed < timer.time:
			continue
			
		to_remove.append(key)
	
	for key in to_remove:
		timers.erase(key)
			
func start_timer(key: String, duration: float):
	timers[key] = { "time": duration, "elapsed": 0.0 }
	
func is_ready(key: String) -> bool:
	return !timers.has(key)
