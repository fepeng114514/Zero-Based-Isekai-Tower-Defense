class_name GenrateSpriteFramesResource

var image_db: Dictionary[String, Array] = {}
var required_atlas: Array[String] = [
	"enemies"
]
var sprite_frames_db: Dictionary[String, SpriteFrames] = {}

func create() -> void:
	_load_atlas()
	_sort_images()
	
	_add_sprite_frames()
	_gen_sprite_frames_res()

func _load_atlas() -> void:
	for atlas_name in required_atlas:
		var path: String = C.PATH_ATLAS_ASSETS % atlas_name
		
		print_debug("加载图集: %s" % path)
		_parse_atlas_data(path)
	
func _parse_atlas_data(path: String) -> void:
	"""图集格式
	"图集名.png": {	# 来自哪个图集，主要用于多图集的打包
		"图像名": {
			"quad": [	# 图像位置（矩形）
				3,
				3,
				2729,
				1536
			],
			"alias": []	# 别名
		},
	"""
	var atlas_data = U.load_json_file(path + ".json")
	
	for atlas_name: String in atlas_data.keys():
		var images_data: Dictionary = atlas_data[atlas_name]
		var atlas_path: String = C.PATH_ATLAS_ASSETS % atlas_name
		var atlas_file: Texture2D = load(atlas_path)
		
		for img_name: String in images_data.keys():
			# 格式: 实体名%动画名%帧索引
			var parts: PackedStringArray = img_name.split("%")
			var anim_name: String = parts[1]
			var full_name: String = "%s%%%s" % [parts[0], anim_name]
			var frame_idx: int = int(parts[2])
			
			if not image_db.has(full_name):
				image_db[full_name] = []
			
			var img_data: Dictionary = images_data[img_name]
			var group: Array = image_db[full_name]
			var atlas_texture: AtlasTexture = _create_atlas_texture(img_data, atlas_file)
			var atlas_texture_data: Array = [atlas_texture, frame_idx]
			group.append(atlas_texture_data)

			for alias: String in img_data.alias:
				var frame_i: int = int(alias.split("%")[2])
				group.append([atlas_texture, frame_i])
			
			print_debug("加载图像: %s" % img_name)

func _create_atlas_texture(
		img_data: Dictionary, atlas_file: Texture2D
	) -> AtlasTexture:
	var quad_data: Array = img_data["quad"]

	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas_file
	atlas_texture.region = Rect2(quad_data[0], quad_data[1], quad_data[2], quad_data[3])
	atlas_texture.filter_clip = true

	return atlas_texture
	
func _sort_images() -> void:
	for group_name: String in image_db.keys():
		var group: Array = image_db[group_name]
		
		group.sort_custom(func(a1: Array, a2: Array): return a1[1] < a2[1])
	
func _add_sprite_frames() -> void:
	for img_group_name: String in image_db.keys():
		var img_group: Array = image_db[img_group_name]
		
		for atlas_texture_data: Array in img_group:
			var frame_idx: int = atlas_texture_data[1]
			var parts: PackedStringArray = img_group_name.split("%")
			var entity_name: String = parts[0]
			var anim_name: String = parts[1]
			
			if not sprite_frames_db.has(entity_name):
				sprite_frames_db[entity_name] = SpriteFrames.new()
				
			var sprite_frames: SpriteFrames = sprite_frames_db[entity_name]
			
			if not sprite_frames.has_animation(anim_name):
				sprite_frames.add_animation(anim_name)
				sprite_frames.set_animation_speed(anim_name, 60)
				
			var frame: AtlasTexture = image_db[img_group_name][frame_idx - 1][0]
				
			sprite_frames.add_frame(anim_name, frame)
		
func _gen_sprite_frames_res() -> void:
	for name: String in sprite_frames_db.keys():
		var sprite_frames: SpriteFrames = sprite_frames_db[name]
		var path: String = "resource/%s.tres" % name
		
		ResourceSaver.save(sprite_frames, C.PATH_ATLAS_ASSETS % path)
