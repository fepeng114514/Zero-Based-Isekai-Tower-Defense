extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var clicked_global_pos: Vector2 = get_global_mouse_position()
		var e: Entity = EntityDB.search_target(
			C.SEARCH.ENTITY_MAX_ID, 
			clicked_global_pos, 
			30, 
			0, 
			0, 
			0, 
			func(entity: Entity) -> bool:
				if not entity.has_c(C.CN_UI):
					return false

				var ui_c: UIComponent = entity.get_c(C.CN_UI)
				
				return ui_c.is_click_at(
					entity.position, clicked_global_pos
				)
		)
		
		if not e:
			S.deselect_entity_s.emit()
			return

		Log.debug("选择实体: %s, %s" % [e, e.position])
		S.select_entity_s.emit(e)
		return
