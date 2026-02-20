extends Node

"""
动画数据库，存储所有动画资源
"""

var animations_db: Dictionary = {}
	
func load() -> void:
	animations_db = {}
	
	var animations_groups: Dictionary[String, Dictionary] = {}

	_grouping_animations(animations_groups)
	_process_animations(animations_groups)

## 按前缀分组动画
func _grouping_animations(
		animations_groups: Dictionary[String, Dictionary]
	) -> void:
	var configed_datas: Dictionary = ConfigMgr.get_config_data(CS.PATH_ANIMATIONS)
	
	for tex_name: String in ImageDB.image_db.keys():
		# 格式: 实体名%动画名%帧索引
		var parts: PackedStringArray = tex_name.split("%")
		var group_name: String = parts[0]
		var anim_name: String = parts[1]
		var full_name: String = "%s_%s" % [group_name, anim_name]
		var origin_name: String = "%s%%%s" % [group_name, anim_name]
		
		if not animations_groups.has(group_name):
			animations_groups[group_name] = {}
		
		var animation: AnimRes = AnimRes.new(full_name, origin_name)
		
		if configed_datas.has(full_name):
			var configed_data: Dictionary = configed_datas[full_name]
			
			animation.fps = configed_data.get("fps", animation.fps)
			animation.loop = configed_data.get("loop", animation.loop)
			animation.from = configed_data.get("from", animation.from)
			animation.to = configed_data.get("to", animation.to)
			
		animations_groups[group_name][anim_name] = animation
		
func _process_animations(
		animations_groups: Dictionary[String, Dictionary]
	) -> void:
	for group_name: String in animations_groups.keys():
		var group: Dictionary = animations_groups[group_name]
		
		for anim_name: String in group.keys():
			var animation: AnimRes = group[anim_name]
			animation.add_frames()

			var sprite_frames: SpriteFrames = SpriteFrames.new()
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, animation.fps)
			sprite_frames.set_animation_loop(anim_name, animation.loop)
			
			for frame: FrameRes in animation.frames:
				sprite_frames.add_frame(anim_name, frame.texture)
		
			animations_db[animation.full_name] = sprite_frames

## 根据动画完整名称获取动画
func get_animation(full_name: String) -> AnimRes:
	return animations_db[full_name]
