extends System


func _on_insert(e: Entity) -> bool:
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	if not sprite_c:
		return true
	
	for sprite_idx: int in range(sprite_c.list.size()):
		e.play_animation(e.default_animation, sprite_idx)
	
	return true
