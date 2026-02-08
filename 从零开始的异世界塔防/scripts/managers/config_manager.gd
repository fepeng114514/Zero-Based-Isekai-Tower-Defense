extends Node

const RES_PATH: String = "res://config/"
const USER_PATH: String = "user://config/"
	
func copy_default_to_user(user_path, res_path):
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive(user_path.get_base_dir())
	
	var error = dir.copy(res_path, user_path)
	if error != OK:
		push_error("复制用户配置失败，错误代码: %s, 从: %s, 到: %s" % [str(error), res_path, user_path])
		return
		
	print("复制用户配置从: %s, 到: %s" % [res_path, user_path])

func get_config_data(base_path):
	var user_path: String = USER_PATH + base_path
	var res_path: String = RES_PATH + base_path
	
	if Global.IS_DEBUG:
		return U.load_json_file(res_path)
	
	if not FileAccess.file_exists(user_path):
		copy_default_to_user(user_path, res_path)
		
	return U.load_json_file(user_path)
