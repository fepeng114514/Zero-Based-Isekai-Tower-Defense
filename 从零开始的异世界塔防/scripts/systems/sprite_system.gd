extends System

func _on_ready_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_SPRITE):
		return true
		
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	var node_list: Array = sprite_c.node_list
	
	for sprite_data: Dictionary in sprite_c.list:
		var sprite
		var sprite_name: String = sprite_data.sprite_name
		match sprite_data.type:
			"animation":
				sprite = AnimatedSprite2D.new()
				sprite.sprite_frames = AnimDB.get_animation(sprite_name)
				sprite.autoplay = "default"
				
			"image":
				sprite = Sprite2D.new()
				sprite.texture = ImageDB.get_image(sprite_name)
			
		for key: String in sprite_data:
			var property = sprite_data[key]
			
			sprite.set(key, property)
			
		node_list.append(sprite)
		e.add_child(sprite)
	
	return true
