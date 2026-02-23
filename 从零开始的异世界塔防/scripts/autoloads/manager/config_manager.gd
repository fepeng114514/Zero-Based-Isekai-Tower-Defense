extends Node

"""
配置管理器，加载配置
"""

const RES_PATH: String = "res://config/"
const USER_PATH: String = "user://config/"
	

## 获取配置数据
func get_config_data(base_path):
	var user_path: String = USER_PATH + base_path
	var res_path: String = RES_PATH + base_path
	
	if Global.IS_DEBUG:
		return U.load_json_file(res_path)
	
	if not FileAccess.file_exists(user_path):
		copy_default_to_user(user_path, res_path)
		
	return U.load_json_file(user_path)


## 复制默认配置到 user://
func copy_default_to_user(user_path, res_path):
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive(user_path.get_base_dir())
	
	var error = dir.copy(res_path, user_path)
	if error != OK:
		printerr("复制用户配置失败，错误代码: %s, 源: %s, 目标: %s" % [str(error), res_path, user_path])
		return
		
	print_debug("复制用户配置: 源: %s, 目标: %s" % [res_path, user_path])
