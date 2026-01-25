extends System
class_name NavPathSystem

func on_insert(entity: Entity):
	if not Utils.is_has_c(entity, CS.CN_NAV_PATH):
		return true
	
	var nav_path_c = entity.components[CS.CN_NAV_PATH]
	
	var nav_path: int = nav_path_c.nav_path
	var nav_subpath: int = nav_path_c.nav_subpath
	var subpath_idx: int = nav_subpath if nav_subpath != -1 else PathDB.get_random_subpath(nav_path)
	nav_path_c.nav_subpath = subpath_idx
	var subpath: Path2D = PathDB.get_subpath(nav_path, subpath_idx)
		
	var path_follow: PathFollow2D = subpath.follow

	entity.position = subpath.to_global(path_follow.position)
	return true

func on_update(delta: float):
	for entity in EntityDB.entities:
		if not is_instance_valid(entity) or not Utils.is_has_c(entity, CS.CN_NAV_PATH):
			continue
			
		var nav_path_c = entity.components[CS.CN_NAV_PATH]
			
		var subpath: Path2D = PathDB.get_subpath(nav_path_c.nav_path, nav_path_c.nav_subpath)
		nav_path_c.progress_ratio += PathDB.calculate_progress_ratio(delta, nav_path_c.speed, subpath)
		entity.position = subpath.to_global(PathDB.get_position_with_progress_ratio(subpath, nav_path_c))
		
		# 终点线检查
		if nav_path_c.progress_ratio >= 1.0:
			EntityDB.remove_entity(entity)
