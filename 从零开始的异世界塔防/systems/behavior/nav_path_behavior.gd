extends Behavior
class_name NavPathBehavior

func _on_insert(e: Entity) -> bool:
	var nav_path_c: NavPathComponent = e.get_c(C.CN_NAV_PATH)
	if not nav_path_c:
		return true

	var nav_pi: int = nav_path_c.nav_pi

	if not U.is_valid_number(nav_path_c.nav_spi):
		nav_path_c.nav_spi = PathDB.get_random_subpathway(nav_pi).idx
		
	if nav_path_c.end_ni < 0:
		nav_path_c.end_ni = PathDB.node_count + nav_path_c.end_ni
		
	nav_path_c.origin_speed = nav_path_c.speed

	var node: PathwayNode = nav_path_c.get_pathway_node()
	nav_path_c.set_pathway_node(node)
	e.global_position = node.pos

	return true


func _on_update(e: Entity) -> bool:
	var nav_path_c: NavPathComponent = e.get_c(C.CN_NAV_PATH)
	if not nav_path_c:
		return false
	
	nav_path_c.speed = nav_path_c.origin_speed * get_mod_speed_factor(e)
	var reversed: bool = nav_path_c.reversed
	var end_ni: int = nav_path_c.end_ni
	
	if reversed and nav_path_c.nav_ni == PathDB.node_count - 1 - end_ni:
		arrived_end(e, nav_path_c, reversed)
		return false
	elif not reversed and nav_path_c.nav_ni == end_ni:
		arrived_end(e, nav_path_c, reversed)
		return false
		
	walk_step(e, nav_path_c, reversed)
	return true


func get_mod_speed_factor(e: Entity) -> float:
	var speed_factor: float = 1

	for mod: Entity in e.get_has_auras():
		var mod_c: ModifierComponent = mod.get_c(C.CN_MODIFIER)
		speed_factor *= mod_c.speed_factor
	
	return speed_factor


func walk_step(e: Entity, nav_path_c: NavPathComponent, reversed: bool) -> void:
	e.play_animation(nav_path_c.animation)
	
	var walk_lenth: float = nav_path_c.speed * TimeDB.frame_length
	
	if reversed:
		nav_path_c.nav_progress -= walk_lenth
	else:
		nav_path_c.nav_progress += walk_lenth
		
	nav_path_c.nav_ratio = nav_path_c.get_ratio()
	e.global_position = nav_path_c.get_progress_pos()
	
	var nav_ni: int = nav_path_c.nav_ni
	var next_ni: int = nav_ni
	var next_node: PathwayNode = nav_path_c.get_pathway_node(next_ni)
	
	if reversed:
		while (
				next_ni > 0 
				and nav_path_c.nav_progress <= next_node.progress
		):
			next_ni -= 1
			next_node = nav_path_c.get_pathway_node(next_ni)
	else:
		while (
				next_ni + 1 < PathDB.node_count 
				and nav_path_c.nav_progress >= next_node.progress
		):
			next_ni += 1
			next_node = nav_path_c.get_pathway_node(next_ni)

	if nav_ni != next_ni:
		nav_path_c.nav_ni = next_ni

	e._on_pathway_walk(nav_path_c)


func arrived_end(e: Entity, nav_path_c: NavPathComponent, reversed: bool) -> void:
	nav_path_c.reversed = not reversed
	
	var node: PathwayNode = nav_path_c.get_pathway_node()
	nav_path_c.set_pathway_node(node)
		
	e._on_arrived_end(nav_path_c)
	
	nav_path_c.loop_count += 1
	Log.debug("到达终点: %s, 到达次数 %d" % [e, nav_path_c.loop_count])
	
	if (
			not nav_path_c.loop 
			or U.is_valid_number(nav_path_c.loop_times) 
			and nav_path_c.loop_count > nav_path_c.loop_times
	):
		e.remove_entity()
