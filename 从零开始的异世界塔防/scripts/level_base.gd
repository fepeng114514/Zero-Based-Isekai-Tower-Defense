extends Node2D
class_name LevelBase

@export var level_idx: int = -1
var level_mode: int = 0
var level_data: Dictionary = {}

func _ready() -> void:
	level_data = Utils.load_json_file(CS.PATH_LEVELS_DATA % level_idx)


func _process(delta: float) -> void:
	pass
