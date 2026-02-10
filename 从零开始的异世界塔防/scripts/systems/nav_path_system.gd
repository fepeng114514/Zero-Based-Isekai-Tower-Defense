extends System

func _on_insert(e: Entity):
	if not e.has_c(CS.CN_NAV_PATH):
		return true
	
	var nav_path_c: NavPathComponent = e.get_c(CS.CN_NAV_PATH)
	var nav_pi: int = nav_path_c.nav_pi

	if nav_path_c.nav_spi == -1:
		nav_path_c.nav_spi = PathDB.get_random_subpath(nav_pi).idx
		
	nav_path_c.origin_speed = nav_path_c.speed
	var node: PathNode = nav_path_c.get_path_node()
	nav_path_c.set_nav_ni(node.ni)
	e.position = node.pos
	return true

func _on_update(delta: float) -> void:
	for e: Entity in E.get_entities_group(CS.CN_NAV_PATH):
		if e.waitting or not e.state & CS.STATE_IDLE:
			continue
			
		var nav_path_c: NavPathComponent = e.get_c(CS.CN_NAV_PATH)
		nav_path_c.speed = nav_path_c.origin_speed * get_mod_speed_factor(e)
		var reversed: bool = nav_path_c.reversed

		walk_step(e, nav_path_c, reversed)
		
		if reversed and nav_path_c.nav_ratio == 1 - nav_path_c.end_ratio:
			get_end(e, nav_path_c, reversed)
		elif not reversed and nav_path_c.nav_ratio == nav_path_c.end_ratio:
			get_end(e, nav_path_c, reversed)

func get_mod_speed_factor(e: Entity):
	var speed_factor: float = 1

	for mod: Entity in e.get_has_auras():
		var mod_c: ModifierComponent = mod.get_c(CS.CN_MODIFIER)
		speed_factor *= mod_c.speed_factor
	
	return speed_factor

func walk_step(e: Entity, nav_path_c: NavPathComponent, reversed: bool):
	var walk_lenth: float = nav_path_c.speed * TM.frame_length
	
	if reversed:
		nav_path_c.nav_progress -= walk_lenth
	else:
		nav_path_c.nav_progress += walk_lenth
		
	e.position = nav_path_c.get_progress_pos()
	var nav_ni: int = nav_path_c.nav_ni
	var next_ni: int = nav_ni
	var next_node: PathNode = nav_path_c.get_path_node(next_ni)
	
	if reversed:
		while (
				next_ni > 0 
				and nav_path_c.nav_progress <= next_node.progress
		):
			next_ni -= 1
			next_node = nav_path_c.get_path_node(next_ni)
	else:
		while (
				next_ni + 1 < PathDB.node_count 
				and nav_path_c.nav_progress >= next_node.progress
		):
			next_ni += 1
			next_node = nav_path_c.get_path_node(next_ni)

	if reversed and nav_path_c.nav_progress <= next_node.progress:
		nav_path_c.set_nav_ni(next_node.ni)
	elif not reversed and nav_path_c.nav_progress >= next_node.progress:
		nav_path_c.set_nav_ni(next_node.ni)

	e._on_path_walk(nav_path_c)

func get_end(e: Entity, nav_path_c: NavPathComponent, reversed: bool):
	nav_path_c.reversed = not reversed
	
	var node_idx: int = PathDB.node_count - 1 if nav_path_c.reversed else 0
	var node: PathNode = nav_path_c.get_path_node(node_idx)
	nav_path_c.set_nav_ni(node.ni)
	e.position = node.pos
		
	e._on_arrived_end(nav_path_c)
	
	nav_path_c.loop_count += 1
	print("到达终点: %s(%d)， 到达次数 %d" % [e.template_name, e.id, nav_path_c.loop_count])
	
	if (
			not nav_path_c.loop 
			or nav_path_c.loop_times != -1 
			and nav_path_c.loop_count > nav_path_c.loop_times
	):
		e.remove_entity()
