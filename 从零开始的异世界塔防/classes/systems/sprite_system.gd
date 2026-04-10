extends System
class_name SpriteSystem
## 精灵系统
##
## 处理拥有 [SpriteComponent] 精灵组件的实体的精灵


func _on_insert(e: Entity) -> bool:
	var sprite_c: SpriteComponent = e.get_c(C.CN_SPRITE)
	if not sprite_c:
		return true
		
	e.play_animation_by_look(e.idle_animation, "idle", true)
		
	return true
