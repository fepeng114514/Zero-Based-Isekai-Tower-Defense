extends Node

"""关卡管理器:
	管理进入关卡与关卡数据
"""

var levels_data: Dictionary = {}
var waves_data: Dictionary = {}


func _ready() -> void:
	for level_idx in C.LEVEL_LIST:
		levels_data[level_idx] = ConfigMgr.get_config_data(C.PATH_LEVEL_DATA % level_idx)
		waves_data[level_idx] = ConfigMgr.get_config_data(C.PATH_WAVE_DATA % level_idx)


func enter_level(idx: int) -> void:
	var level_data = levels_data[GlobalStore.level_idx]
	
	GlobalStore.level_idx = idx
	
	ImageDB.load()
	ImageDB.load_atlas_group(level_data.required_atlas)
	AnimDB.load()
	EntityDB.load()
	PathDB.load(level_data)
	
	get_tree().change_scene_to_file(C.PATH_LEVELS_SCENES % idx)
