extends Node2D
class_name LevelBase

@export var level_idx: int = -1
var level_mode: int = 0
@onready var store = $Store
var reqiured_data = DataManager.reqiured_data

func _ready() -> void:
	GlobalStore.level_idx = level_idx
	
	SystemManager.set_required_systems(reqiured_data.level_required_system)

func _process(delta: float) -> void:
	pass
