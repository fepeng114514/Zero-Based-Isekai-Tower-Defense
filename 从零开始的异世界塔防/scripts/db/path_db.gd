extends Node

var paths: Array[Path2D] = []

func get_subpath(path_idx: int, subpath_idx: int) -> Path2D:
	return paths[path_idx].subpaths[subpath_idx]

func get_random_subpath(path_idx: int):
	return Utils.random_int(0, paths[path_idx].subpaths.size() - 1)

func calculate_progress_ratio(speed: int, subpath: Path2D, time: float = 1) -> float:
	var value: float = speed * TM.frame_length * time / subpath.curve.get_baked_length()
	
	return value

func get_position_with_progress_ratio(subpath: Path2D, nav_path_c: NavPathComponent, progress_ratio) -> Vector2:
	var path_follow = subpath.follow
		
	path_follow.progress_ratio = progress_ratio
	var position: Vector2 = path_follow.position
	
	return subpath.to_global(position)

func predict_target_pos(target: Entity, walk_time: float) -> Vector2:
	var nav_path_c = target.get_c(CS.CN_NAV_PATH)
	
	if not nav_path_c:
		return target.position
	
	var subpath: Path2D = get_subpath(nav_path_c.nav_path, nav_path_c.nav_subpath)
	var progress_ratio = nav_path_c.progress_ratio + calculate_progress_ratio(nav_path_c.speed, subpath, walk_time)
	var predict_pos: Vector2 = get_position_with_progress_ratio(subpath, nav_path_c, progress_ratio)
	
	return predict_pos
