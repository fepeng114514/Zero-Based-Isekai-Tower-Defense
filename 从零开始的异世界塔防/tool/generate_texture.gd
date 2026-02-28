@tool
extends EditorScript


"""图集格式
"图集名.png": {	# 来自哪个图集，主要用于多图集的打包
	"图像名": {
		"quad": [	# 图像区域
			3,
			3,
			2729,
			1536
		],
		"alias": []	# 别名
	},
"""
	
const REQUIRED_ANIMATED_ATLAS: Array[String] = [
	"animated_common_enemies",
	"animated_towers",
]
const REQUIRED_IMAGE_ATLAS: Array[String] = [
	"image_towers"
]
var cached_atlas: Dictionary[String, Texture2D] = {}
var image_db: Dictionary[String, AtlasTexture] = {}
var sprite_frames_db: Dictionary[String, SpriteFrames] = {}
var sprite_frames_data: Dictionary = {}

func _run() -> void:
	sprite_frames_data = U.load_json("res://tool/sprite_frames_data.json")
	
	# 处理图像图集
	for atlas_name in REQUIRED_IMAGE_ATLAS:
		Log.debug("处理图像图集: %s", atlas_name)
		var atlas_data = U.load_json(
				C.PATH_IMAGE_ATLAS_ASSETS_DATA % atlas_name
			)
			
		_parse_atlas_data(atlas_data, false)
		
	# 处理动画图集
	for atlas_name in REQUIRED_ANIMATED_ATLAS:
		Log.debug("处理动画图集: %s", atlas_name)
		var atlas_data = U.load_json(
			C.PATH_ANIMATE_ATLAS_ASSETS_DATA % atlas_name
		)
		
		_parse_atlas_data(atlas_data, true)
		
	_load_sprite_frames()
	# 处理完毕后统一保存精灵帧资源
	_save_sprite_frames()
	

func _parse_atlas_data(atlas_data: Dictionary, is_animated_atlas: bool) -> void:
	for atlas_name: String in atlas_data.keys():
		var images_data: Dictionary = atlas_data[atlas_name]
		var atlas_path: String 
		
		if not is_animated_atlas:
			atlas_path = C.DIR_IMAGE_ATLAS_ASSETS.path_join(atlas_name)
		else:
			atlas_path = C.DIR_ANIMATED_ATLAS_ASSETS.path_join(atlas_name)
			
		var atlas_file: Texture2D
		
		if cached_atlas.has(atlas_path):
			atlas_file = cached_atlas[atlas_path]
		else:
			atlas_file = load(atlas_path)
			cached_atlas[atlas_path] = atlas_file
		
		for img_name: String in images_data.keys():
			var img_data: Dictionary = images_data[img_name]
			
			var atlas_texture: AtlasTexture = _create_atlas_texture(
				img_data, atlas_file
			)
			
			if not is_animated_atlas:
				_save_atlas_texture(img_name, atlas_texture)
			
			image_db[img_name] = atlas_texture
			
			for alias: String in img_data.alias:
				image_db[alias] = atlas_texture


func _load_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_data.keys():
		var anim_group: Dictionary = sprite_frames_data[sprite_frames_name]
		
		for anim_name: String in anim_group.keys():
			var anim_data: Dictionary = anim_group[anim_name]
			if not sprite_frames_db.has(sprite_frames_name):
				var new_sprite_frames := SpriteFrames.new()
				sprite_frames_db[sprite_frames_name] = new_sprite_frames

			var sprite_frames: SpriteFrames = sprite_frames_db[sprite_frames_name]
				
			var fps: float = anim_data.get("fps", 30)
			var loop: bool = anim_data.get("loop", true)
			
			if not sprite_frames.has_animation(anim_name):
				sprite_frames.add_animation(anim_name)
				sprite_frames.set_animation_speed(anim_name, fps)
				sprite_frames.set_animation_loop(anim_name, loop)
			
			var from: int = anim_data.from
			var to: int = anim_data.to

			for idx: int in range(from, to + 1):
				var atlas_texture_name: String = "%s_%04d" % [sprite_frames_name, idx]
				var frame: AtlasTexture = image_db[atlas_texture_name]
				sprite_frames.add_frame(anim_name, frame)
		
		
func _create_atlas_texture(
		img_data: Dictionary, atlas_file: Texture2D
	) -> AtlasTexture:
	var quad_data: Array = img_data["quad"]
	
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas_file
	atlas_texture.region = Rect2(
		quad_data[0], quad_data[1], quad_data[2], quad_data[3]
	)
	atlas_texture.filter_clip = true

	return atlas_texture
	
	
func _save_atlas_texture(
		atlas_texture_name: String, atlas_texture: AtlasTexture
	) -> void:
	var save_path: String = C.PATH_ATLAS_TEXTURE_RESOURCES % atlas_texture_name
	
	ResourceSaver.save(atlas_texture, save_path)
	
	Log.verbose("生成 AtlasTexture: %s.tres...", atlas_texture_name)


func _save_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_db.keys():
		var sprite_frames: SpriteFrames = sprite_frames_db[sprite_frames_name]
		
		var save_path: String = C.PATH_SPRITE_FRAMES_RESOURCES % sprite_frames_name
		
		ResourceSaver.save(sprite_frames, save_path)
		
		Log.verbose("生成 SpriteFrames: %s.tres...", sprite_frames_name)
