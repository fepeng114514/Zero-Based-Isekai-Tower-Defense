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
	var dir: C.Direction = _get_direction(e, point)
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

func _get_direction(e: Entity, point: Vector2) -> C.Direction:
	var v: Vector2 = point - e.global_position
	if up_down:
		return C.Direction.DOWN if v.y > 0 else C.Direction.UP
	if left_right:
		return C.Direction.RIGHT if v.x >= 0 else C.Direction.LEFT
	
	# 八方向：使用向量比较，完全避免 atan2
	var abs_x: float = abs(v.x)
	var abs_y: float = abs(v.y)
	if abs_x > abs_y:
		return C.Direction.RIGHT if v.x > 0 else C.Direction.LEFT
	elif abs_y > abs_x:
		return C.Direction.DOWN if v.y > 0 else C.Direction.UP
	else:
		# 对角线情况 (|x| == |y|)
		if v.x > 0 and v.y > 0:
			return C.Direction.DOWN   # 45°
		elif v.x > 0 and v.y < 0:
			return C.Direction.RIGHT  # -45°
		elif v.x < 0 and v.y > 0:
			return C.Direction.LEFT   # 135°
		else:
			return C.Direction.UP     # -135°
