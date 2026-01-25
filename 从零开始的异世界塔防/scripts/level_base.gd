extends Node2D
class_name LevelBase

var level_idx: int = -1
var level_mode: int = 0
var level_data: Dictionary = {}
var wave_data: Array = []

func _ready() -> void:
	level_data = Utils.load_json_file("res://data/levels/level_%s_data.json" % level_idx)
	wave_data = Utils.load_json_file("res://data/waves/level_%s_wave.json" % level_idx)

func _process(delta: float) -> void:
	pass
