extends Node

"""
关卡管理器，管理进入关卡与关卡数据
"""

var levels_data: Dictionary = {}
var waves_data: Dictionary = {}
var reqiured_data = DataMgr.reqiured_data

func _ready() -> void:
	for level_idx in CS.LEVEL_LIST:
		levels_data[level_idx] = ConfigMgr.get_config_data(CS.PATH_LEVELS % level_idx)
		waves_data[level_idx] = ConfigMgr.get_config_data(CS.PATH_WAVES % level_idx)

func enter_level(idx: int) -> void:
	GlobalStore.level_idx = idx
	
	SystemMgr.set_required_systems(reqiured_data.level_required_system)
	get_tree().change_scene_to_file(CS.PATH_LEVELS_SCENES % idx)
