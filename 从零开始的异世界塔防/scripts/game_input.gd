extends Node2D

signal select_entity_s(e: Entity, click_global_pos: Vector2)
signal deselect_entity_s()

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var click_global_pos: Vector2 = get_global_mouse_position()
		var e: Variant = EntityDB.search_target(
			C.SEARCH_ENTITY_MAX_ID, click_global_pos, 30
		)
		
		if not e:
			deselect_entity_s.emit()
			return

		Log.debug("选择实体: %s, %s", [e, e.position])
		select_entity_s.emit(e, click_global_pos)
