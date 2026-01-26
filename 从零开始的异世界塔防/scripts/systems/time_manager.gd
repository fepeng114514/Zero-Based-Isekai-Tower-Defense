extends Node

var tick_ts: float = 0
var tick: int = 0
var frame_length: float = 0
var timers: Dictionary = {}

func _process(delta: float) -> void:
	tick_ts += delta
	tick += 1
	frame_length = delta

func is_ready_time(ts: float, time: float):
	return tick_ts - ts > time

func create_timer(time: float) -> Signal:
	return Utils.curren_scene.create_timer(time).timeout
