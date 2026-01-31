extends Node

const RES_PATH: String = "res://config/"
const USER_PATH: String = "user://config/"
	
func copy_default_to_user(user_path, res_path):
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive(user_path.get_base_dir())
	
	# 复制文件
	var error = dir.copy(res_path, user_path)
	if error != OK:
		push_error("复制失败，错误代码: " + str(error))
		return
		
	print("已创建初始用户配置")

func get_config_data(base_path):
	var user_path: String = USER_PATH + base_path
	var res_path: String = RES_PATH + base_path
	
	if not FileAccess.file_exists(user_path):
		copy_default_to_user(user_path, res_path)
		
	return Utils.load_json_file(user_path)
