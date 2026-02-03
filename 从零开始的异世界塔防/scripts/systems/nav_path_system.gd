extends System
class_name NavPathSystem

func on_insert(e: Entity):
	if not e.has_c(CS.CN_NAV_PATH):
		return true
	
	var nav_path_c: NavPathComponent = e.get_c(CS.CN_NAV_PATH)
	var nav_path: int = nav_path_c.nav_path
	var nav_subpath: int = nav_path_c.nav_subpath

	var subpath_idx: int = nav_subpath if nav_subpath != -1 else PathDB.get_random_subpath(nav_path)
	nav_path_c.nav_subpath = subpath_idx

	var subpath: Path2D = nav_path_c.get_subpath()
		
	var path_follow: PathFollow2D = subpath.follow
	
	path_follow.progress_ratio = 0
	e.position = subpath.to_global(path_follow.position)
	return true

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e) or not e.has_c(CS.CN_NAV_PATH):
			continue
			
		var state: int = e.state
			
		if e.waitting or not state & CS.STATE_IDLE:
			continue
			
		var nav_path_c = e.get_c(CS.CN_NAV_PATH)

		walk_step(e, nav_path_c)
		
		if nav_path_c.progress_ratio >= 1.0:
			get_end(e, nav_path_c)

func walk_step(e: Entity, nav_path_c: NavPathComponent):
	nav_path_c.progress_ratio += nav_path_c.calculate_progress_ratio()
		# 待实现动画播放
	e.position = nav_path_c.get_pos_with_progress_ratio()
	e.on_path_walk(nav_path_c)

func get_end(e: Entity, nav_path_c: NavPathComponent):
	e.on_get_end(nav_path_c)
	EntityDB.remove_entity(e)
