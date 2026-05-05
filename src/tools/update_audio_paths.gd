@tool
extends EditorScript


const AUDIO_ASSETS_DIR_PATH: String = "res://assets/audios/"
var audio_paths := PackedStringArray()


func _run() -> void:
	var audio_assets_dir: DirAccess = U.open_directory(AUDIO_ASSETS_DIR_PATH)
	
	for file: String in audio_assets_dir.get_files():	
		if file.get_extension() not in ["wav", "ogg", "mp3"]:
			continue
		
		var full_path: String = AUDIO_ASSETS_DIR_PATH.path_join(file)
		audio_paths.append(full_path)
		Log.verbose("处理 %s" % full_path)
		
	U.save_json(
		audio_paths, 
		"res://assets/audio_paths.json"
	)
