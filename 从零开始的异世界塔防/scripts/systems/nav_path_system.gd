extends System
class_name NavPathSystem

func on_insert(entity: Entity):
	var nav_path_c = entity.get_node("NavPathComponent")
	
	if not nav_path_c:
		return
		
	var subpath: Path2D = PathDB.get_subpath(nav_path_c.nav_path, nav_path_c.nav_subpath)
	var path_follow: PathFollow2D = subpath.get_node("Follow")

	entity.position = subpath.to_global(path_follow.position)

func on_update(delta: float):
	for entity in EntityDB.entities:
		if not is_instance_valid(entity):
			continue
		
		var nav_path_c = entity.get_node("NavPathComponent")
		
		if not nav_path_c:
			continue
			
		var subpath: Path2D = PathDB.get_subpath(nav_path_c.nav_path, nav_path_c.nav_subpath)
		nav_path_c.progress_ratio += PathDB.calculate_progress_ratio(delta, nav_path_c.speed, subpath)
		entity.position = subpath.to_global(PathDB.get_position_with_progress_ratio(subpath, nav_path_c))
		
		# 终点线检查
		if nav_path_c.progress_ratio >= 1.0:
			EntityDB.remove_entity(entity)
