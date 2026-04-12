extends Resource
class_name AnimationData
## 动画数据资源


## 要播放的精灵/精灵组索引
@export var play_idx: int = 0
## 是否播放精灵组
@export var is_group: bool = false
## 播放次数
@export var times: int = 1
## 上方向的动画名
@export var up: StringName = &""
## 下方向的动画名
@export var down: StringName = &""
## 上下方向的动画名
@export var up_down: StringName = &""
## 左方向的动画名
@export var left: StringName = &""
## 右方向的动画名
@export var right: StringName = &""
## 左右方向的动画名，默认向右，通过镜像朝左
@export var left_right: StringName = &""
## 任意方向的动画名
@export var any: StringName = &""


## 根据实体与目标点的角度返回对应的动画名称
func get_animation_name_for_point(e: Entity, point: Vector2) -> Array:
	var dir: C.Direction = C.Direction.DOWN
	var angle: float = e.global_position.angle_to_point(
		point
	)
	
	if (
			not (left or right or left_right) 
			and up_down
		):
		if angle >= -PI and angle < 0:
			dir = C.Direction.UP
		else:
			dir = C.Direction.DOWN
	elif (
			not (up or down or up_down)
			and left_right
		):
		if angle <= C.HALF_PI and angle >= -C.HALF_PI:
			dir = C.Direction.RIGHT
		else:
			dir = C.Direction.LEFT
	else:
		if angle >= -3 * C.QUARTER_PI and angle < -C.QUARTER_PI:
			dir = C.Direction.UP
		elif angle >= C.QUARTER_PI and angle < 3 * C.QUARTER_PI:
			dir = C.Direction.DOWN
		elif angle >= -C.QUARTER_PI and angle < C.QUARTER_PI:
			dir = C.Direction.RIGHT
		else:
			dir = C.Direction.LEFT

	var anim_name: StringName = ""
	var flip_h: bool = false
	
	if any:
		anim_name = any
	else:
		match dir:
			C.Direction.UP:
				anim_name = up_down if up_down else up
			C.Direction.DOWN:
				anim_name = up_down if up_down else down
			C.Direction.LEFT:
				if left_right:
					anim_name = left_right
					flip_h = true
				else:
					anim_name = left
			C.Direction.RIGHT:
				if left_right:
					anim_name = left_right
				else:
					anim_name = right
	
	return [anim_name, dir, flip_h]