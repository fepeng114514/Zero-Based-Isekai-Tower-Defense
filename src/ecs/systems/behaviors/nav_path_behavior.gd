extends Behavior
class_name NavPathBehavior
## 导航路径行为系统
##
## 处理拥有 [NavPathComponent] 行为组件的实体的移动与到达终点判断


func _on_insert(e: Entity) -> bool:
	var nav_path_c: NavPathComponent = e.get_node_or_null(C.CN_NAV_PATH)
	if not nav_path_c:
		return true

	var nav_pi: int = nav_path_c.nav_pi
	if not U.is_valid_number(nav_path_c.nav_spi):
		nav_path_c.nav_spi = PathwayMgr.get_random_subpathway(nav_pi).idx
		
	if nav_path_c.end_ni < 0:
		nav_path_c.end_ni = PathwayMgr.node_count + nav_path_c.end_ni
		
	nav_path_c.origin_speed = nav_path_c.speed

	var node: PathwayNode = nav_path_c.get_pathway_node()
	nav_path_c.set_pathway_node(node)
	e.global_position = node.pos

	return true


func _on_return_true(e: Entity, break_behavior: Behavior) -> void:
	if break_behavior == self:
		return

	var nav_path_c: NavPathComponent = e.get_node_or_null(C.CN_NAV_PATH)
	if not nav_path_c:
		return
		
	e.state = C.State.IDLE


func _on_update(e: Entity) -> bool:
	var nav_path_c: NavPathComponent = e.get_node_or_null(C.CN_NAV_PATH)
	if not nav_path_c:
		return false
	
	# 速度计算
	var speed_factor: float = 1

	for mod: Entity in e.get_has_auras():
		var mod_c: ModifierComponent = mod.get_node_or_null(C.CN_MODIFIER)
		speed_factor *= mod_c.speed_factor
		
	nav_path_c.speed = nav_path_c.origin_speed * speed_factor
	
	if nav_path_c.reversed:
		return _update_reversed(e, nav_path_c)
	else:
		return _update_forward(e, nav_path_c)


func _update_forward(e: Entity, nav_path_c: NavPathComponent) -> bool:
	# 检查终点
	if nav_path_c.nav_ni == nav_path_c.end_ni:
		_arrived_end(e, nav_path_c, false)
		return false
		
	e.state = C.State.NAV_PATH_WALK
	
	# 正向移动逻辑
	nav_path_c.nav_progress += nav_path_c.speed * TimeMgr.frame_length
	
	# 节点切换
	var nav_ni: int = nav_path_c.nav_ni
	var next_ni: int = nav_ni
	var next_node: PathwayNode = nav_path_c.get_pathway_node(next_ni)
	while (
		next_ni + 1 < PathwayMgr.node_count
		and nav_path_c.nav_progress >= next_node.progress
	):
		next_ni += 1
		next_node = nav_path_c.get_pathway_node(next_ni)
		
	if nav_ni != next_ni:
		nav_path_c.nav_ni = next_ni

	# 更新位置和动画
	_update_entity_position(e, nav_path_c)
	return true


func _update_reversed(e: Entity, nav_path_c: NavPathComponent) -> bool:
	# 检查终点
	if nav_path_c.nav_ni == PathwayMgr.node_count - 1 - nav_path_c.end_ni:
		_arrived_end(e, nav_path_c, true)
		return false
		
	e.state = C.State.NAV_PATH_WALK
	
	# 反向移动逻辑
	nav_path_c.nav_progress -= nav_path_c.speed * TimeMgr.frame_length
	
	# 节点切换
	var nav_ni: int = nav_path_c.nav_ni
	var next_ni: int = nav_ni
	var next_node: PathwayNode = nav_path_c.get_pathway_node(next_ni)
	while (
			next_ni > 0 
			and nav_path_c.nav_progress <= next_node.progress
		):
		next_ni -= 1
		next_node = nav_path_c.get_pathway_node(next_ni)
		
	if nav_ni != next_ni:
		nav_path_c.nav_ni = next_ni
	
	# 更新位置和动画
	_update_entity_position(e, nav_path_c)
	return true
	

func _update_entity_position(e: Entity, nav_path_c: NavPathComponent) -> void:
	var next_position: Vector2 = nav_path_c.get_progress_pos()
	e.look_point = next_position
	e.play_animation_by_look(nav_path_c.motion_animation, "walk")
	e.global_position = next_position
	e._on_pathway_walk(nav_path_c)


func _arrived_end(e: Entity, nav_path_c: NavPathComponent, reversed: bool) -> void:
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
		GameMgr.life -= nav_path_c.life_cost
		e.remove_entity()
