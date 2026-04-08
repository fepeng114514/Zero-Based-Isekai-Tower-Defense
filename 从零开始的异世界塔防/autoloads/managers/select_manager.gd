extends Node2D


var select_mode: C.SelectMode = C.SelectMode.NONE
var selected_entity: Entity = null


func _ready() -> void:
	S.select_entity.connect(_on_select)
	S.deselect_entity.connect(_on_deselect)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var e: Entity = EntityMgr.search_target(
			C.SearchMode.ENTITY_MAX_ID, 
			InputMgr.mouse_global_position, 
			C.UNSET, 
			0, 
			0, 
			0, 
			func(entity: Entity) -> bool:
				var ui_c: UIComponent = entity.get_c(C.CN_UI)
				if not ui_c:
					return false
				
				return ui_c.is_click_at(
					entity.global_position, 
					InputMgr.mouse_global_position
				)
		)
		
		if not e:
			if U.is_valid_entity(selected_entity):
				selected_entity.selected = false
				
			S.deselect_entity.emit()
			selected_entity = null
			return

		Log.debug("选择实体: %s%s" % [e, e.global_position])
		e.selected = true
		selected_entity = e
		S.select_entity.emit(e)
		return
		
		
func _on_select(e: Entity) -> void:
	e._on_select()
	select_mode = C.SelectMode.NONE
	
	var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
	if rally_c and rally_c.can_select_rally:
		select_mode = C.SelectMode.RALLY
	

func _on_deselect() -> void:
	if not U.is_valid_entity(selected_entity):
		select_mode = C.SelectMode.NONE
		return
	
	match select_mode:
		C.SelectMode.RALLY:
			var rally_c: RallyComponent = selected_entity.get_c(
				C.CN_RALLY
			)
			rally_c.new_rally(InputMgr.mouse_global_position)
		C.SelectMode.BARRACK_RALLY:
			var barrack_c: BarrackComponent = selected_entity.get_c(
				C.CN_BARRACK
			)

			var to_mouse_dist: float = selected_entity.global_position.distance_to(
				InputMgr.mouse_global_position
			)

			if (
					to_mouse_dist <= barrack_c.rally_max_range
					and to_mouse_dist >= barrack_c.rally_min_range
				):
				barrack_c.new_rally(InputMgr.mouse_global_position)
			else:
				var direction_to: Vector2 = selected_entity.global_position.direction_to(
						InputMgr.mouse_global_position
					) 

				if to_mouse_dist >= barrack_c.rally_max_range:
					var rally_pos: Vector2 = (
						direction_to
						* barrack_c.rally_max_range 
						+ selected_entity.global_position
					)
					
					barrack_c.new_rally(rally_pos)
				else:
					var rally_pos: Vector2 = (
						direction_to
						* barrack_c.rally_min_range 
						+ selected_entity.global_position
					)
					
					barrack_c.new_rally(rally_pos)

	select_mode = C.SelectMode.NONE
