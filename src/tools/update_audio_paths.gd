@tool
extends EditorScript


const AUDIO_ASSETS_DIR_PATH: String = "res://assets/audios/"
var audio_paths := PackedStringArray()


func _run() -> void:
	for file: String in U.open_directory(AUDIO_ASSETS_DIR_PATH).get_files():	
		if file.get_extension() not in ["wav", "ogg", "mp3"]:
			continue
		
		var full_path: String = AUDIO_ASSETS_DIR_PATH.path_join(file)
		audio_paths.append(full_path)
		Log.verbose("处理 %s" % full_path)
		
	U.save_json(
		audio_paths, 
		"res://assets/audio_paths.json"
	)
