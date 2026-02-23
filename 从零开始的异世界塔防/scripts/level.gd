extends Node2D


func _ready() -> void:
	SystemMgr.load(C.LEVEL_REQUIRED_SYSTEMS)
