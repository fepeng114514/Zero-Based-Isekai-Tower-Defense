extends Node2D
class_name LevelBase

"""后续会迁移到 LevelManager"""

@export var level_idx: int = -1
var reqiured_data = DataManager.reqiured_data

func _ready() -> void:
	GlobalStore.level_idx = level_idx
	SystemManager.set_required_systems(reqiured_data.level_required_system)
