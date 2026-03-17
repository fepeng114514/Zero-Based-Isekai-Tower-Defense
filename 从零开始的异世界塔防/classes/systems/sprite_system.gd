extends System
class_name SpriteSystem

func _on_insert(e: Entity) -> bool:
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	if not sprite_c:
		return true
		
	e.mixed_play_animation_by_look(e.idle_animation, "idle", true)
		
	return true
