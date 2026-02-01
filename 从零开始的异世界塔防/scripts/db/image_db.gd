extends Node2D
#
#func split_atlas_and_create_animations():
	#var atlas_texture = preload(CS.PATH_ATLAS_ASSETS % name + ".png")
	#var data = Utils.load_json_file(CS.PATH_ATLAS_ASSETS % name + ".json")
	#
	## 创建SpriteFrames资源用于存储动画
	#var sprite_frames = SpriteFrames.new()
	#
	## 假设数据格式：{"animations": {"run": [{"x":0,"y":0,"w":32,"h":32}, ...]}, ...}
	#for anim_name in data.animations:
		#var frames = data.animations[anim_name]
		#sprite_frames.add_animation(anim_name)
		#sprite_frames.set_animation_speed(anim_name, 10)
		#
		#for frame_data in frames:
			## 创建AtlasTexture
			#var atlas_tex = AtlasTexture.new()
			#atlas_tex.atlas = atlas_texture
			#atlas_tex.region = Rect2(
				#frame_data.x,
				#frame_data.y,
				#frame_data.w,
				#frame_data.h
			#)
			## 添加到动画帧
			#sprite_frames.add_frame(anim_name, atlas_tex)
	#
	## 保存SpriteFrames资源
	#ResourceSaver.save(sprite_frames, "res://animations.tres")
	#
	## 应用到AnimatedSprite2D
	#$AnimatedSprite2D.sprite_frames = sprite_frames
