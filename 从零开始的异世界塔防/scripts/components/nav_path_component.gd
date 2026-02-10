extends Node
class_name NavPathComponent

var nav_pi: int = 0
var nav_spi: int = 0
var nav_ni: int = 0
var nav_ratio: float = 0
var nav_progress: float = 0
var origin_speed: int = 0
var reversed: bool = false
var speed: int = 0
var ts: float = 0
var end_ratio: int = 1
var loop: bool = false
var loop_times: int = -1
var loop_count: int = 0

## PathDB.get_subpath 的简写，已传递 nav_pi, nav_spi
func get_subpath() -> Path2D:
	return PathDB.get_subpath(nav_pi, nav_spi)

## PathDB.get_ratio 的简写，已传递 nav_pi, nav_spi
func get_ratio(progress: float = nav_ratio) -> float:
	return PathDB.get_ratio(nav_pi, nav_spi, progress)
	
## PathDB.get_ratio_pos 的简写，已传递 nav_pi, nav_spi
func get_ratio_pos(ratio: float = nav_ratio) -> Vector2:
	return PathDB.get_ratio_pos(nav_pi, nav_spi, ratio)
	
## PathDB.get_progress_pos 的简写，已传递 nav_pi, nav_spi
func get_progress_pos(progress: float = nav_progress) -> Vector2:
	return PathDB.get_progress_pos(nav_pi, nav_spi, progress)

## PathDB.get_progress_by_ratio 的简写，已传递 nav_pi, nav_spi
func get_progress_by_ratio(ratio: float = nav_ratio) -> float:
	return PathDB.get_progress_by_ratio(nav_pi, nav_spi, ratio)

## PathDB.get_path_node 的简写，已传递 nav_pi, nav_spi
func get_path_node(ni: int = nav_ni) -> PathNode:
	return PathDB.get_path_node(nav_pi, nav_spi, ni)

func set_nav_path(pi: int, spi: int) -> void:
	nav_pi = pi
	nav_spi = spi

func set_nav_ni(pi: int):
	var node: PathNode = get_path_node(pi)
	nav_ni = pi
	nav_ratio = node.ratio
	nav_progress = node.progress
