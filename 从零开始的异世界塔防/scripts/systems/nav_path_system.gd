extends System
class_name NavPathSystem

func on_insert(e: Entity):
	var nav_path_c = e.get_c(CS.CN_NAV_PATH)

	if not nav_path_c:
		return true
	
	var nav_path: int = nav_path_c.nav_path
	var nav_subpath: int = nav_path_c.nav_subpath
	var subpath_idx: int = nav_subpath if nav_subpath != -1 else PathDB.get_random_subpath(nav_path)
	
	nav_path_c.nav_subpath = subpath_idx
	var subpath: Path2D = PathDB.get_subpath(nav_path, subpath_idx)
		
	var path_follow: PathFollow2D = subpath.follow
	path_follow.progress_ratio = 0
	e.position = subpath.to_global(path_follow.position)
	return true

func on_update(delta: float):
	for e in EntityDB.entities:
		if not is_instance_valid(e) or not e.has_c(CS.CN_NAV_PATH):
			continue
			
		var nav_path_c = e.get_c(CS.CN_NAV_PATH)
		var subpath: Path2D = PathDB.get_subpath(nav_path_c.nav_path, nav_path_c.nav_subpath)
		
		nav_path_c.progress_ratio += PathDB.calculate_progress_ratio(nav_path_c.speed, subpath)
		e.position = PathDB.get_position_with_progress_ratio(subpath, nav_path_c, nav_path_c.progress_ratio)
		
		# 终点线检查
		if nav_path_c.progress_ratio >= 1.0:
			EntityDB.remove_entity(e)
