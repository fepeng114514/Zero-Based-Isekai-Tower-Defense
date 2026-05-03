@tool
extends NavigationAgent2D
class_name RallyComponent
## 集结组件
##
## RallyComponent 可以使实体移动到指定位置，并支持阵型排列


## 移动速度
@export var speed: float = 100
## 是否可点击集结
@export var can_select_rally: bool = true
## 移动动画
@export var motion_animation: AnimationData = null

## 是否已到达集结位置
var arrived: bool = false
var is_force_rally: bool = false
var rally_center_position := Vector2.ZERO


## 设置新的集结位置
func new_rally_position(
		pos: Vector2, 
		is_force: bool = false,
		center: Vector2 = pos
	) -> void:
	is_force_rally = is_force
	arrived = false
	target_position = pos
	rally_center_position = center
	
