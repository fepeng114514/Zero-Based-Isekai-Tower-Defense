@tool
extends EditorScript


const ENTITY_SCENES_DIR_PATH: String = "res://scenes/entities/"
var entity_scene_paths := PackedStringArray()
	

func _run() -> void:
	_process_scene_dir(ENTITY_SCENES_DIR_PATH)
	
	for dir_name: String in U.open_directory(ENTITY_SCENES_DIR_PATH).get_directories():
		var full_path: String = ENTITY_SCENES_DIR_PATH.path_join(dir_name)
		_process_scene_dir(full_path)
			
	U.save_json(
		entity_scene_paths, 
		ENTITY_SCENES_DIR_PATH.path_join("entity_scene_paths.json")
	)
	

func _process_scene_dir(dir_path: String) -> void:
	for file: String in U.open_directory(dir_path).get_files():		
		if file.get_extension() != "tscn":
			continue
			
		var full_path: String = dir_path.path_join(file)
		entity_scene_paths.append(full_path)
		Log.verbose("处理 %s" % full_path)
