@tool
extends EditorScript
## 生成 SpriteFrames 资源


const DIR_SPRITE_FRAMES_DATAS: String = "res://tools/sprite_frames_datas/"
const DIR_ANIMATED_ATLAS: String = "res://assets/animated_atlas/"
const DIR_IMAGE_ATLAS: String = "res://assets/image_atlas/"

var cached_atlas: Dictionary[String, Texture2D] = {}
var image_db: Dictionary[String, AtlasTexture] = {}
var sprite_frames_db: Dictionary[String, SpriteFrames] = {}


func _run() -> void:
	# 处理图像图集
	for file: String in U.open_directory(DIR_IMAGE_ATLAS).get_files():
		if file.get_extension() != "json":
			continue
			
		Log.debug("解析图像图集: %s" % file)
		_parse_atlas_data(DIR_IMAGE_ATLAS.path_join(file), false)
		
	# 处理动画图集
	for file: String in U.open_directory(DIR_ANIMATED_ATLAS).get_files():
		if file.get_extension() != "json":
			continue
			
		Log.debug("解析动画图集: %s" % file)
		_parse_atlas_data(DIR_ANIMATED_ATLAS.path_join(file), true)
		
	_build_sprite_frames()
	_save_sprite_frames()
	

func _parse_atlas_data(
	path: String, is_animated_atlas: bool
	) -> void:
	var atlas_data: Dictionary = U.load_json(path)
			
	for atlas_name: String in atlas_data:
		var images_data: Dictionary = atlas_data[atlas_name]
		var atlas_path: String = ""
		
		if not is_animated_atlas:
			atlas_path = "res://assets/image_atlas".path_join(atlas_name)
		else:
			atlas_path = "res://assets/animated_atlas".path_join(atlas_name)
			
		var atlas_file: Texture2D = null
		
		if cached_atlas.has(atlas_path):
			atlas_file = cached_atlas[atlas_path]
		else:
			atlas_file = load(atlas_path)
			cached_atlas[atlas_path] = atlas_file
		
		for img_name: String in images_data:
			var img_data: Dictionary = images_data[img_name]
			
			var quad_data: Array = img_data["quad"]
	
			var atlas_texture: AtlasTexture = AtlasTexture.new()
			atlas_texture.atlas = atlas_file
			atlas_texture.region = Rect2(
				quad_data[0], quad_data[1], quad_data[2], quad_data[3]
			)
			atlas_texture.filter_clip = true
			var trim: Array = img_data.trim
			var trim_x: int = trim[0]
			var trim_y: int = trim[1]
			var trim_w: int = trim_x + trim[2]
			var trim_h: int = trim_y + trim[3]
			atlas_texture.margin = Rect2(
				trim_x, trim_y, trim_w, trim_h
			)
			if not is_animated_atlas:
				var save_path: String = (
					"res://resources/atlas_textures/%s.tres" 
					% img_name
				)
					
				ResourceSaver.save(atlas_texture, save_path)
				
				Log.info("生成 AtlasTexture: %s.tres" % img_name)
			
			image_db[img_name] = atlas_texture
			
			for alias: String in img_data.alias:
				image_db[alias] = atlas_texture


func _build_sprite_frames() -> void:
	for file: String in U.open_directory(DIR_SPRITE_FRAMES_DATAS).get_files():
		var full_path: String = DIR_SPRITE_FRAMES_DATAS.path_join(file)
		var json_data: Dictionary = U.load_json(full_path)
	
		for sprite_frames_name: String in json_data:
			var data: Dictionary = json_data[sprite_frames_name]
			var is_layered: bool = (
				data.has("layer_count") 
				and data.layer_count > 0
			)
			
			var anim_datas: Dictionary = data.animations

			if is_layered:
				for layer_idx: int in range(1, data.layer_count + 1):
					var layer_name: String = "%s%d" % [sprite_frames_name, layer_idx]
					_add_animations(layer_name, anim_datas)
			else:
				_add_animations(sprite_frames_name, anim_datas)


func _add_animations(sprite_frames_name: String, anim_datas: Dictionary) -> void:
	for anim_name: String in anim_datas:
		if not sprite_frames_db.has(sprite_frames_name):
			var new_sprite_frames := SpriteFrames.new()
			new_sprite_frames.remove_animation("default")
			sprite_frames_db[sprite_frames_name] = new_sprite_frames

		var anim_data: Dictionary = anim_datas[anim_name]
		var sprite_frames: SpriteFrames = sprite_frames_db[sprite_frames_name]
		
		if sprite_frames.has_animation(anim_name):
			sprite_frames.clear(anim_name)
		else:
			sprite_frames.add_animation(anim_name)
			Log.verbose("增加动画: %s, 到 %s" % [anim_name, sprite_frames_name])
		
		var fps: float = anim_data.get("fps", 30)
		var loop: bool = anim_data.get("loop", true)
		sprite_frames.set_animation_speed(anim_name, fps)
		sprite_frames.set_animation_loop(anim_name, loop)
		
		var from: int = anim_data.from
		var to: int = anim_data.to

		for idx: int in range(from, to + 1):
			var atlas_texture_name: String = "%s_%04d" % [sprite_frames_name, idx]
			
			if not image_db.has(atlas_texture_name):
				Log.warn("未找到帧: %s" % atlas_texture_name)
				continue
				
			var frame: AtlasTexture = image_db[atlas_texture_name]
			sprite_frames.add_frame(anim_name, frame)


func _save_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_db:
		var sprite_frames: SpriteFrames = sprite_frames_db[sprite_frames_name]
		
		var save_path: String = (
			"res://resources/sprite_frames/%s.tscn" 
			% sprite_frames_name
		)
		
		var sprite_frames_file: String = "%s.tres" % sprite_frames_name
		ResourceSaver.save(sprite_frames, save_path)
		
		Log.info("生成 SpriteFrames: %s" % sprite_frames_file)
