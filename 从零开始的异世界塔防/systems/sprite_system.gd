extends System


func _on_ready_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_SPRITE):
		return true
		
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	
	for sprite: Node2D in sprite_c.get_children():
		sprite_c.list.append(sprite)
		
		if sprite is AnimatedSprite2D:
			sprite.autoplay = "idle"
		
	return true
		

func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_SPRITE):
		return true
		
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	
	for sprite: Node2D in sprite_c.list:
		if sprite is AnimatedSprite2D:
			sprite.autoplay = "idle"
	
	return true
