extends Node

## 自上次初始化后已经过的时间戳
var tick_ts: float = 0
## 自上次初始化后已经过的帧数
var tick: int = 0
## 该变量始终等于 _process(delta) 中的 delta
var frame_length: float = 0
## 每秒的经过的帧数，始终等于 Engine.get_frames_per_second()
var fps: float = 0
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

## 协程等待，等待 0 秒表示等待一帧
func y_wait(time: float = 0, break_fn = null) -> void:
	if time == 0:
		await curren_scene.process_frame
	else:	
		var ts = tick_ts
		while not is_ready_time(ts, time) and (not break_fn or break_fn.call()):
			await curren_scene.process_frame
