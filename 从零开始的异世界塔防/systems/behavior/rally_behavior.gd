extends Behavior
class_name RallyBehavior


func _on_update(e: Entity) -> bool:
	var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
	if not rally_c or rally_c.arrived:
		return false
		
	if rally_c.is_navigation_finished():
		rally_c.arrived = true

		e._on_arrived_rally(rally_c)
		return false

	walk_step(e, rally_c)
	return true

func walk_step(e: Entity, rally_c: RallyComponent) -> void:
	e.play_animation(rally_c.animation)
	
	var next_position: Vector2 = rally_c.get_next_path_position()
	var direction: Vector2 = e.global_position.direction_to(
		next_position
	)

	var velocity: Vector2 = (
		direction 
		* rally_c.speed 
		* TimeDB.frame_length
	)
	rally_c.velocity = velocity
	e.global_position += velocity
	
	e._on_rally_walk(rally_c)
