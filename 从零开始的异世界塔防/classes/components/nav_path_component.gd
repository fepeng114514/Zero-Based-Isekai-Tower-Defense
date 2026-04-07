@tool
extends Node
class_name NavPathComponent
## 导航路径组件
##
## NavPathComponent 可以使实体沿着路径移动


## 是否沿相反路线移动
@export var reversed: bool = false
## 移动速度
@export var speed: float = 133
## 移动动画数据
@export var motion_animation: AnimationData = null
## 是否强制与来源实体所在路径同步
@export var sync_source_path: bool = true

@export_group("End")
## 终点节点
@export var end_ni: int = C.UNSET
## 是否循环
@export var loop: bool = false
## 循环次数
##
## 循环指定次数后再到达终点节点将会到达终点
@export var loop_times: int = C.UNSET
## 到达终点消耗的生命
@export var life_cost: int = 1

## 所在路径索引
var nav_pi: int = 0
## 所在子路径索引
var nav_spi: int = 0
## 所在节点索引
var nav_ni: int = 0
## 所在路程比率
var nav_ratio: float = 0
## 所在路程
var nav_progress: float = 0
## 原始速度
var origin_speed: float = 0
## 当前循环次数
var loop_count: int = 0
## 时间戳
var ts: float = 0


func _ready() -> void:
	if motion_animation == null:
		motion_animation = AnimationData.new()
		motion_animation.up = "walk_up"
		motion_animation.down = "walk_down"
		motion_animation.left_right = "walk_left_right"


## PathwayMgr.get_subpath 的简写，已传递 nav_pi, nav_spi
func get_subpath() -> Path2D:
	return PathwayMgr.get_subpath(nav_pi, nav_spi)


## PathwayMgr.get_ratio 的简写，已传递 nav_pi, nav_spi
func get_ratio(progress: float = nav_progress) -> float:
	return PathwayMgr.get_ratio(nav_pi, nav_spi, progress)
	

## PathwayMgr.get_ratio_pos 的简写，已传递 nav_pi, nav_spi
func get_ratio_pos(ratio: float = nav_ratio) -> Vector2:
	return PathwayMgr.get_ratio_pos(nav_pi, nav_spi, ratio)
	

## PathwayMgr.get_progress_pos 的简写，已传递 nav_pi, nav_spi
func get_progress_pos(progress: float = nav_progress) -> Vector2:
	return PathwayMgr.get_progress_pos(nav_pi, nav_spi, progress)


## PathwayMgr.get_progress_by_ratio 的简写，已传递 nav_pi, nav_spi
func get_progress_by_ratio(ratio: float = nav_ratio) -> float:
	return PathwayMgr.get_progress_by_ratio(nav_pi, nav_spi, ratio)


## PathwayMgr.get_pathway_node 的简写，已传递 nav_pi, nav_spi
func get_pathway_node(ni: int = nav_ni) -> PathwayNode:
	return PathwayMgr.get_pathway_node(nav_pi, nav_spi, ni)


## 设置导航路径
func set_nav_path(
		pi: int, spi: int = C.UNSET, ni: int = C.UNSET
	) -> void:
	nav_pi = pi
	nav_spi = spi
	if U.is_valid_number(ni):
		nav_ni = ni


## 根据某个节点设置导航路径
func set_pathway_node(node: PathwayNode) -> void:
	nav_ni = node.ni
	nav_progress = node.progress
	nav_ratio = node.ratio
