extends Node

var paths: Array[Path2D] = []

func get_subpath(path_idx: int, subpath_idx: int) -> Path2D:
	return paths[path_idx].subpath[subpath_idx]

func get_random_subpath(path_idx: int):
	return Utils.random_int(0, paths[path_idx].subpath.size() - 1)

func calculate_progress_ratio(delta: float, speed: int, subpath: Path2D) -> float:
	var value: float = speed * delta / subpath.curve.get_baked_length()
	return value

func get_position_with_progress_ratio(subpath: Path2D, nav_path_c: NavPathComponent, path_follow = null) -> Vector2:
	if not path_follow:
		path_follow = subpath.get_node("Follow")
		
	path_follow.progress_ratio = nav_path_c.progress_ratio
	var position: Vector2 = path_follow.position
	
	return position
