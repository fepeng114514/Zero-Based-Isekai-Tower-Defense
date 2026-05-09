@tool
extends EditorScript
## 生成 SpriteFrames 资源，并自动按图集数据文件名创建子文件夹分类存放


const DIR_SPRITE_FRAMES_DATAS: String = "res://tools/sprite_frames_datas/"
const DIR_IMAGE_ATLAS: String = "res://assets/atlas/image_atlas/"
const DIR_ANIMATED_ATLAS: String = "res://assets/atlas/animated_atlas/"


var cached_atlas: Dictionary[String, Texture2D] = {}
var image_db: Dictionary[String, AtlasTexture] = {}


func _run() -> void:
	# 处理图像图集（生成 AtlasTexture 并保存为 .tres）
	for file: String in U.open_directory(DIR_IMAGE_ATLAS).get_files():
		if file.get_extension() != "json":
			continue
		var full_path: String = DIR_IMAGE_ATLAS.path_join(file)
		Log.debug("处理图像图集: %s" % full_path)
		_parse_atlas_data(full_path, false)

	# 处理动画图集（只创建 AtlasTexture 存入 image_db，不单独保存）
	for file: String in U.open_directory(DIR_ANIMATED_ATLAS).get_files():
		if file.get_extension() != "json":
			continue
		var full_path: String = DIR_ANIMATED_ATLAS.path_join(file)
		Log.debug("处理动画图集: %s" % full_path)
		_parse_atlas_data(full_path, true)

	# 逐个处理 SpriteFrames 定义文件，生成并按分类保存 SpriteFrames
	for data_file: String in U.open_directory(DIR_SPRITE_FRAMES_DATAS).get_files():
		var full_path: String = DIR_SPRITE_FRAMES_DATAS.path_join(data_file)
		var json_data: Dictionary = U.load_json(full_path)
		var category: String = _get_category_from_path(full_path)
		_build_and_save_sprite_frames_from_json(category, json_data)


func _parse_atlas_data(path: String, is_animated_atlas: bool) -> void:
	var category: String = _get_category_from_path(path)
	var atlas_data: Dictionary = U.load_json(path)

	for atlas_name: String in atlas_data:
		var images_data: Dictionary = atlas_data[atlas_name]
		var atlas_path: String = ""

		if not is_animated_atlas:
			atlas_path = DIR_IMAGE_ATLAS.path_join(atlas_name)
		else:
			atlas_path = DIR_ANIMATED_ATLAS.path_join(atlas_name)

		var atlas_file: Texture2D = null
		if cached_atlas.has(atlas_path):
			atlas_file = cached_atlas[atlas_path]
		else:
			atlas_file = load(atlas_path)
			cached_atlas[atlas_path] = atlas_file

		for img_name: String in images_data:
			var img_data: Dictionary = images_data[img_name]
			var atlas_texture: AtlasTexture = _create_atlas_texture(img_data, atlas_file)

			# 设置修剪边距
			var trim: Array = img_data.trim
			var trim_x: int = trim[0]
			var trim_y: int = trim[1]
			var trim_w: int = trim_x + trim[2]
			var trim_h: int = trim_y + trim[3]
			atlas_texture.margin = Rect2(trim_x, trim_y, trim_w, trim_h)

			# 非动画图集需要单独保存 AtlasTexture 文件
			if not is_animated_atlas:
				_save_atlas_texture(category, img_name, atlas_texture)

			image_db[img_name] = atlas_texture

			# 处理别名
			for alias: String in img_data.alias:
				image_db[alias] = atlas_texture


func _build_and_save_sprite_frames_from_json(category: String, json_data: Dictionary) -> void:
	for sprite_frames_name: String in json_data:
		var sprite_frames_info: Dictionary = json_data[sprite_frames_name]
		var is_layered: bool = (
			sprite_frames_info.has("layer_count") 
			and sprite_frames_info.layer_count > 0
		)
		var anim_group: Dictionary = sprite_frames_info.animations

		if is_layered:
			for layer_idx: int in range(1, sprite_frames_info.layer_count + 1):
				var layer_sprite_frames_name: String = "%s%d" % [sprite_frames_name, layer_idx]
				_process_and_save_sprite_frames(category, layer_sprite_frames_name, anim_group)
		else:
			_process_and_save_sprite_frames(category, sprite_frames_name, anim_group)


func _process_and_save_sprite_frames(category: String, sprite_frames_name: String, anim_group: Dictionary) -> void:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")  # 移除默认的空动画

	for anim_name: String in anim_group:
		var anim_data: Dictionary = anim_group[anim_name]

		if sprite_frames.has_animation(anim_name):
			sprite_frames.clear(anim_name)
		else:
			sprite_frames.add_animation(anim_name)
			Log.verbose("增加动画: %s, 到 %s" % [anim_name, sprite_frames_name])

		var fps: float = anim_data.get("fps", 30)
		var loop: bool = anim_data.get("loop", true)
		sprite_frames.set_animation_speed(anim_name, fps)
		sprite_frames.set_animation_loop(anim_name, loop)

		var from_idx: int = anim_data.from
		var to_idx: int = anim_data.to

		for idx: int in range(from_idx, to_idx + 1):
			var atlas_texture_name: String = "%s_%04d" % [sprite_frames_name, idx]
			if not image_db.has(atlas_texture_name):
				Log.warn("未找到帧: %s" % atlas_texture_name)
				continue
			var frame: AtlasTexture = image_db[atlas_texture_name]
			sprite_frames.add_frame(anim_name, frame)

	_save_sprite_frames(category, sprite_frames_name, sprite_frames)


func _create_atlas_texture(img_data: Dictionary, atlas_file: Texture2D) -> AtlasTexture:
	var quad_data: Array = img_data["quad"]
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas_file
	atlas_texture.region = Rect2(
		quad_data[0], quad_data[1], quad_data[2], quad_data[3]
	)
	atlas_texture.filter_clip = true
	return atlas_texture


func _save_atlas_texture(category: String, atlas_texture_name: String, atlas_texture: AtlasTexture) -> void:
	var dir_path: String = "res://resources/atlas_textures/%s/" % category
	_ensure_directory(dir_path)
	var save_path: String = dir_path.path_join(atlas_texture_name + ".tres")
	ResourceSaver.save(atlas_texture, save_path)
	Log.info("生成 AtlasTexture: %s" % save_path)


func _save_sprite_frames(category: String, sprite_frames_name: String, sprite_frames: SpriteFrames) -> void:
	var dir_path: String = "res://resources/sprite_frames/%s/" % category
	_ensure_directory(dir_path)
	var save_path: String = dir_path.path_join(sprite_frames_name + ".tres")
	ResourceSaver.save(sprite_frames, save_path)
	Log.info("生成 SpriteFrames: %s" % save_path)


func _ensure_directory(path: String) -> void:
	var dir := DirAccess.open("res://")
	if dir and not dir.dir_exists(path):
		dir.make_dir_recursive(path)


func _get_category_from_path(path: String) -> String:
	return path.get_file().get_basename()  # 返回不带路径和扩展名的文件名
