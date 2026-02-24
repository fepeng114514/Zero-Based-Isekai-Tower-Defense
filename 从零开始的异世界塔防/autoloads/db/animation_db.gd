extends Node

"""动画数据库:
	存储所有 SpriteFrames 动画资源
"""

var animations_db: Dictionary[String, SpriteFrames] = {}


func load() -> void:
	animations_db = {}
	
	_load_sprite_frames()


## 加载动画
func _load_sprite_frames() -> void:
	var anim_datas: Array = ConfigMgr.get_config_data(C.PATH_ANIMATIONS_DATA)
	
	for anim_data: Dictionary in anim_datas:
		var prefix: String = anim_data.prefix
		var anim_name: String = anim_data.name
		
		if not animations_db.has(prefix):
			animations_db[prefix] = SpriteFrames.new()

		var sprite_frames: SpriteFrames = animations_db[prefix]
			
		var fps: float = anim_data.get("fps", 60)
		var loop: bool = anim_data.get("loop", true)
		
		if not sprite_frames.has_animation(anim_name):
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, fps)
			sprite_frames.set_animation_loop(anim_name, loop)
		
		var from: int = anim_data.from
		var to: int = anim_data.to

		for idx: int in range(from, to + 1):
			var texture_name: String = "%s_%04d" % [prefix, idx]
			var frame: AtlasTexture = ImageDB.get_image(texture_name)
			sprite_frames.add_frame(anim_name, frame)
		
		
## 根据动画完整名称获取动画
func get_animation(anim_name: String) -> SpriteFrames:
	if not animations_db.has(anim_name):
		Log.error("未找到动画: %s", anim_name)
		return null
	
	return animations_db[anim_name]
