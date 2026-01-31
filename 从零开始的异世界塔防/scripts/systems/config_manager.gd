extends Node

const RES_PATH: String = "res://config/"
const USER_PATH: String = "user://config/"
	
func copy_default_to_user(user_path, res_path):
	var config_data = Utils.load_json_file(res_path)
	
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive(user_path.get_base_dir())
	
	if not config_data:
		print("默认配置解析失败")
		return

	save_config(user_path, config_data)
	print("已创建初始用户配置")

func save_config(user_path, config_data):
	var file = FileAccess.open(user_path, FileAccess.WRITE)
	if not file:
		print("保存配置失败")
		return
		
	var json_text = JSON.stringify(config_data, "\t")
	file.store_string(json_text)
	file.close()
	print("配置已保存")	

func get_config_data(base_path):
	var user_path: String = USER_PATH + base_path
	var res_path: String = RES_PATH + base_path
	
	if not FileAccess.file_exists(user_path):
		copy_default_to_user(user_path, res_path)
		
	return Utils.load_json_file(user_path)
