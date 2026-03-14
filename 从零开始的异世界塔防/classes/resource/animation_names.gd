extends Resource
class_name AnimationNames
## 动画名称资源，存储所有方向的动画名

## 上方向的动画名
@export var up: String = ""
## 下方向的动画名
@export var down: String = ""
## 上下方向的动画名
@export var up_down: String = ""
## 左方向的动画名
@export var left: String = ""
## 右方向的动画名
@export var right: String = ""
## 左右方向的动画名，默认向右，通过镜像朝左
@export var left_right: String = ""
## 任意方向的动画名
@export var any: String = ""


func _init(data: Dictionary = {}) -> void:
	for key in data:
		if key not in self:
			continue
		
		set(key, data[key])
	

## 根据实体与目标点的角度返回对应的动画名称 [br]
func get_animation_name_for_point(e: Entity, point: Vector2) -> Array:
	var anim_name: String = ""
	var filp_h: bool = false
	var angle: float = e.global_position.angle_to_point(
		point
	)
	var direction: C.DIRECTION = get_direction(angle)
			
	if not any.is_empty():
		anim_name = any
		if direction == C.DIRECTION.RIGHT:
			# 默认朝右所以需要镜像
			filp_h = true
	else:
		var result: Array = match_animation_name(direction)
		anim_name = result[0]
		filp_h = result[1]

	return [anim_name, direction, filp_h]


## 计算方向
func get_direction(angle: float) -> C.DIRECTION:
	if (
			up_down or left.is_empty() 
			and right.is_empty() 
			and left_right.is_empty() 
		):
		if angle >= -PI and angle < 0:
			return C.DIRECTION.UP
		else:
			return C.DIRECTION.DOWN
	elif (
			up.is_empty() 
			and down.is_empty() 
			and up_down.is_empty() 
			and left_right
		):
		if angle <= C.HALF_PI and angle >= -C.HALF_PI:
			return C.DIRECTION.RIGHT
		else:
			return C.DIRECTION.LEFT
	else:
		if angle >= -3 * C.QUARTER_PI and angle < -C.QUARTER_PI:
			return C.DIRECTION.UP
		elif angle >= C.QUARTER_PI and angle < 3 * C.QUARTER_PI:
			return C.DIRECTION.DOWN
		elif angle >= -C.QUARTER_PI and angle < C.QUARTER_PI:
			return C.DIRECTION.RIGHT
		else:
			return C.DIRECTION.LEFT


## 根据方向返回相应动画名称
func match_animation_name(direction: C.DIRECTION) -> Array:
	var anim_name: String = ""
	var filp_h: bool = false

	match direction:
		C.DIRECTION.UP:
			if not up_down.is_empty():
				anim_name = up_down
			else:
				anim_name = up
		C.DIRECTION.DOWN:
			if not up_down.is_empty():
				anim_name = up_down
			else:
				anim_name = down
		C.DIRECTION.LEFT:
			if not left_right.is_empty():
				anim_name = left_right
				# 默认朝右所以需要镜像
				filp_h = true
			else:
				anim_name = left
		C.DIRECTION.RIGHT:
			if not left_right.is_empty():
				anim_name = left_right
			else:
				anim_name = right
			
	return [anim_name, filp_h]
