@tool
extends Node
class_name NavPathComponent

@export var reversed: bool = false
@export var speed: float = 133
@export var end_ni: int = C.UNSET
@export var loop: bool = false
@export var loop_times: int = C.UNSET
## 移动动画数据
@export var motion_animation: AnimationData = null


var nav_pi: int = 0
var nav_spi: int = 0
var nav_ni: int = 0
var nav_ratio: float = 0
var nav_progress: float = 0
var origin_speed: float = 0
var loop_count: int = 0
var ts: float = 0


func _ready() -> void:
	if motion_animation == null:
		motion_animation = AnimationData.new({
			"up": "walk_up",
			"down": "walk_down",
			"left_right": "walk_left_right",
		})


## PathDB.get_subpath 的简写，已传递 nav_pi, nav_spi
func get_subpath() -> Path2D:
	return PathDB.get_subpath(nav_pi, nav_spi)


## PathDB.get_ratio 的简写，已传递 nav_pi, nav_spi
func get_ratio(progress: float = nav_progress) -> float:
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


## PathDB.get_pathway_node 的简写，已传递 nav_pi, nav_spi
func get_pathway_node(ni: int = nav_ni) -> PathwayNode:
	return PathDB.get_pathway_node(nav_pi, nav_spi, ni)


func set_nav_path(
		pi: int, spi: int = C.UNSET, ni: int = C.UNSET
	) -> void:
	nav_pi = pi
	nav_spi = spi
	if U.is_valid_number(ni):
		nav_ni = ni


func set_pathway_node(node: PathwayNode) -> void:
	nav_ni = node.ni
	nav_progress = node.progress
	nav_ratio = node.ratio
