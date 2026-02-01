extends System
class_name NavPathSystem

func on_insert(e: Entity):
	if not e.has_c(CS.CN_NAV_PATH):
		return true
	
	var nav_path_c = e.get_c(CS.CN_NAV_PATH)
	var nav_path: int = nav_path_c.nav_path
	var nav_subpath: int = nav_path_c.nav_subpath

	var subpath_idx: int = nav_subpath if nav_subpath != -1 else PathDB.get_random_subpath(nav_path)
	nav_path_c.nav_subpath = subpath_idx

	var subpath: Path2D = nav_path_c.get_subpath()
		
	var path_follow: PathFollow2D = subpath.follow
	
	path_follow.progress_ratio = 0
	e.position = subpath.to_global(path_follow.position)
	return true

func on_update(delta: float) -> bool:
	for e in EntityDB.entities:
		if not is_instance_valid(e) or not e.has_c(CS.CN_NAV_PATH):
			continue
			
		var nav_path_c = e.get_c(CS.CN_NAV_PATH)

		walk_step(e, nav_path_c)
		
		# 终点线检查
		if nav_path_c.progress_ratio >= 1.0:
			e.on_culminate(nav_path_c)
			EntityDB.remove_entity(e)
	
	return true

func walk_step(e, nav_path_c):
	nav_path_c.progress_ratio += nav_path_c.calculate_progress_ratio()
		# 待实现动画播放
	e.position = nav_path_c.get_pos_with_progress_ratio()
	e.on_path_walk(nav_path_c)
