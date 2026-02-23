extends Node

"""
关卡管理器，管理进入关卡与关卡数据
"""

var levels_data: Dictionary = {}
var waves_data: Dictionary = {}


func _ready() -> void:
	for level_idx in C.LEVEL_LIST:
		levels_data[level_idx] = ConfigMgr.get_config_data(C.PATH_LEVELS % level_idx)
		waves_data[level_idx] = ConfigMgr.get_config_data(C.PATH_WAVES % level_idx)


func enter_level(idx: int) -> void:
	GlobalStore.level_idx = idx
	
	SystemMgr.load(C.LEVEL_REQUIRED_SYSTEMS)
	get_tree().change_scene_to_file(C.PATH_LEVELS_SCENES % idx)
