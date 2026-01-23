extends Node

var tick_ts: float = 0

func _process(delta: float) -> void:
	tick_ts += delta
