extends Node2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var click_global_pos: Vector2 = get_global_mouse_position()
		var e: Variant = EntityDB.search_target(
			C.SEARCH_ENTITY_MAX_ID, click_global_pos, 30
		)
		
		if not e:
			S.deselect_entity_s.emit()
			return

		Log.debug("选择实体: %s, %s", [e, e.position])
		S.select_entity_s.emit(e, click_global_pos)
		return
		
	S.deselect_entity_s.emit()
