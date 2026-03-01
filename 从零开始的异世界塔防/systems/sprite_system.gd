extends System


func _on_create(e: Entity) -> bool:
	if not e.has_c(C.CN_SPRITE):
		return true
		
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	
	for sprite: Node2D in sprite_c.get_children():
		sprite_c.list.append(sprite)
		
	return true
		

func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_SPRITE):
		return true
		
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	
	for sprite_idx: int in range(sprite_c.list.size()):
		e.play_animation("idle", sprite_idx)
	
	return true
