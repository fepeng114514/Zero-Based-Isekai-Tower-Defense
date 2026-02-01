extends Node
class_name NavPathComponent

var nav_path: int = 0
var nav_subpath: int = 0
var progress_ratio: float = 0
var speed: int = 0
var reversed: bool = false

## PathDB.get_subpath 的简写
func get_subpath() -> Path2D:
	return PathDB.get_subpath(nav_path, nav_subpath)

## PathDB.calculate_progress_ratio 的简写
func calculate_progress_ratio(subpath = null, time: float = 1) -> float:
	if not subpath:
		subpath = get_subpath()

	return PathDB.calculate_progress_ratio(speed, subpath, time)
	
## PathDB.get_pos_with_progress_ratio 的简写
func get_pos_with_progress_ratio(subpath = null) -> Vector2:
	if not subpath:
		subpath = get_subpath()

	return PathDB.get_pos_with_progress_ratio(subpath, progress_ratio)
