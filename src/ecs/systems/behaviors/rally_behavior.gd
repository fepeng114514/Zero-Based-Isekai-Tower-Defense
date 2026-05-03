extends Behavior
class_name RallyBehavior
## 集结点行为系统
##
## 处理拥有 [RallyComponent] 行为组件的实体的前往集结点移动


func _on_update(e: Entity) -> bool:
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if not rally_c or rally_c.arrived:
		return false
		
	if not rally_c.is_force_rally and not e.state & (C.State.IDLE | C.State.RALLY):
		return false
		
	if rally_c.is_navigation_finished():
		rally_c.arrived = true
		rally_c.is_force_rally = false
		e.state = C.State.IDLE

		e._on_arrived_rally(rally_c)
		return false

	var next_position: Vector2 = rally_c.get_next_path_position()
	e.look_point = next_position
	e.play_animation_by_look(rally_c.motion_animation, "walk")
	
	var direction: Vector2 = e.global_position.direction_to(
		next_position
	)
	
	var velocity: Vector2 = (
		direction 
		* rally_c.speed 
		* TimeMgr.frame_length
	)
	rally_c.velocity = velocity
	e.global_position += velocity
	e.state = C.State.RALLY
	
	e._on_rally_walk(rally_c)

	return true
