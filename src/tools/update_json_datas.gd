@tool
extends EditorScript


const DIR_ENTITY_SCENES: String = "res://scenes/entities/"


func _run() -> void:
	_update_entity_scene_paths()
	

## 更新 entity_scene_paths
func _update_entity_scene_paths() -> void:
	var entity_scene_paths: Array[String] = []
	
	_process_scene_dir(DIR_ENTITY_SCENES, entity_scene_paths)
	
	var entity_scene_dir: DirAccess = U.open_directory(DIR_ENTITY_SCENES)
	for dir_name: String in entity_scene_dir.get_directories():
		var dir_path: String = DIR_ENTITY_SCENES.path_join(dir_name)
		_process_scene_dir(dir_path, entity_scene_paths)
			
	U.save_json(
		entity_scene_paths, 
		DIR_ENTITY_SCENES.path_join("entity_scene_paths.json")
	)
	
	
func _process_scene_dir(dir_path: String, entity_scene_paths: Array[String]) -> void:
	var dir: DirAccess = U.open_directory(dir_path)
	
	for file: String in dir.get_files():		
		if file.get_extension() != "tscn":
			continue
			
		var full_path: String = dir_path.path_join(file)
		entity_scene_paths.append(full_path)
		Log.verbose("处理 %s" % full_path)
