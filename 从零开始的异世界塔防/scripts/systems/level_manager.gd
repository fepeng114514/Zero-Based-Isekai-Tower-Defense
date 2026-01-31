extends Node

var levels_data: Dictionary = {}
var waves_data: Dictionary = {}

func _ready() -> void:
	for level_idx in CS.LEVEL_LIST:
		levels_data[level_idx] = ConfigManager.get_config_data(CS.PATH_LEVELS % level_idx)
		waves_data[level_idx] = ConfigManager.get_config_data(CS.PATH_WAVES % level_idx)
