@tool
extends EditorScript
## 生成 SpriteFrames 资源

"""
图集格式:
"图集名.png": {	# 来自哪个图集，主要用于多图集的打包
	"图像名": {
		"quad": [	# 图像区域
			3,
			3,
			2729,
			1536
		],
		"trim": [	# 裁剪透明边
			5,		# 左裁剪
			2,		# 上裁剪
			5,		# 右裁剪
			0		# 下裁剪
		],
		"alias": []	# 别名
	},

动画文件格式:
"动画资源名": {	# 生成的 SpriteFrames 资源名
	"layer_count": 0,	# 多层动画层数，默认为 0，会创建 n 个 SpriteFrames
	"animations": {		# 动画列表
		"动画名": {		 # SpriteFrames 中的动画名
			"from": 1,	# 起始帧索引
			"to": 10,	# 结束帧索引
			"fps": 30,	# 帧率，默认为 30
			"loop": true	# 是否循环，默认为 true
		}
	}
}

动画名规范:
动画名应由方向和动作两部分组成，使用下划线分隔，格式为 "动作_方向"。
无方向的动画可以省略方向部分，格式为 "动作"。
方向部分可以是 AnimationData 资源属性: "up"、"down"、"left_right" 等。
动作部分可以是任意描述动画的字符串，如 "idle"、"walk"、"melee"、"death" 等。
示例:
"idle_up" 表示向上的待机动画
"walk_left_right" 表示左右的行走动画
"melee" 表示无方向的近战攻击动画
"""
	
const REQUIRED_ANIMATED_ATLAS: Array[String] = [
	"animated_common_enemies",
	"animated_towers",
]
const REQUIRED_IMAGE_ATLAS: Array[String] = [
	"image_towers",
	"image_gui",
]
var cached_atlas: Dictionary[String, Texture2D] = {}
var image_db: Dictionary[String, AtlasTexture] = {}
var sprite_frames_db: Dictionary[String, SpriteFrames] = {}
var sprite_frames_data: Dictionary = {}

func _run() -> void:
	sprite_frames_data = U.load_json(
		"res://tool/sprite_frames_data.json"
	)
	
	# 处理图像图集
	for atlas_name in REQUIRED_IMAGE_ATLAS:
		Log.debug("处理图像图集: %s" % atlas_name)
		var atlas_data: Dictionary = U.load_json(
				"res://assets/image_atlas/%s.json" % atlas_name
			)
			
		_parse_atlas_data(atlas_data, false)
		
	# 处理动画图集
	for atlas_name in REQUIRED_ANIMATED_ATLAS:
		Log.debug("处理动画图集: %s" % atlas_name)
		var atlas_data: Dictionary = U.load_json(
			"res://assets/animated_atlas/%s.json" % atlas_name
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
			atlas_path = "res://assets/image_atlas".path_join(atlas_name)
		else:
			atlas_path = "res://assets/animated_atlas".path_join(atlas_name)
			
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
			var trim: Array = img_data.trim
			var trim_x: int = trim[0]
			var trim_y: int = trim[1]
			var trim_w: int = trim_x + trim[2]
			var trim_h: int = trim_y + trim[3]
			atlas_texture.margin = Rect2(
				trim_x, trim_y, trim_w, trim_h
			)
			if not is_animated_atlas:
				_save_atlas_texture(img_name, atlas_texture)
			
			image_db[img_name] = atlas_texture
			
			for alias: String in img_data.alias:
				image_db[alias] = atlas_texture


func _load_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_data.keys():
		var sprite_frames_info: Dictionary = sprite_frames_data[sprite_frames_name]
		var is_layered: bool = (
			sprite_frames_info.has("layer_count") 
			and sprite_frames_info.layer_count > 0
		)
		
		var anim_group: Dictionary = sprite_frames_info.animations

		if is_layered:
			for layer_idx: int in range(1, sprite_frames_info.layer_count + 1):
				var layer_sprite_frames_name: String = "%s%d" % [sprite_frames_name, layer_idx]
				_process_sprite_frames(layer_sprite_frames_name, anim_group)
		else:
			_process_sprite_frames(sprite_frames_name, anim_group)


func _process_sprite_frames(sprite_frames_name: String, anim_group: Dictionary) -> void:
	for anim_name: String in anim_group.keys():
		var anim_data: Dictionary = anim_group[anim_name]
		if not sprite_frames_db.has(sprite_frames_name):
			var new_sprite_frames := SpriteFrames.new()
			new_sprite_frames.remove_animation("default")
			sprite_frames_db[sprite_frames_name] = new_sprite_frames

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
	var save_path: String = (
		"res://resources/atlas_texture_resources/%s.tres" 
		% atlas_texture_name
	)
		
	ResourceSaver.save(atlas_texture, save_path)
	
	Log.info("生成 AtlasTexture: %s.tres" % atlas_texture_name)


func _save_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_db.keys():
		var sprite_frames: SpriteFrames = sprite_frames_db[sprite_frames_name]
		
		var save_path: String = (
			"res://resources/sprite_frames_resources/%s.tres" 
			% sprite_frames_name
		)

		ResourceSaver.save(sprite_frames, save_path)
		
		Log.info("生成 SpriteFrames: %s.tres" % sprite_frames_name)
