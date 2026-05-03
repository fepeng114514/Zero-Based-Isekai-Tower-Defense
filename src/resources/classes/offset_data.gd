@tool
extends Resource
class_name OffsetData
## 偏移数据资源
##
## 根据方向存储偏移


## 左方向的偏移
@export var left := Vector2.ZERO:
	set(value):
		left = value
		emit_changed()
## 右方向的偏移
@export var right := Vector2.ZERO:
	set(value):
		right = value
		emit_changed()
## 上方向的偏移
@export var up := Vector2.ZERO:
	set(value):
		up = value
		emit_changed()
## 下方向的偏移
@export var down := Vector2.ZERO:
	set(value):
		down = value
		emit_changed()
## 任意方向的偏移
@export var any := Vector2.ZERO:
	set(value):
		any = value
		emit_changed()


## 根据方向获取相应偏移
func get_offset_by_direction(direction: C.Direction) -> Vector2:
	var offset := Vector2.ZERO
	
	if any:
		offset = any
	else:
		match direction:
			C.Direction.UP:
				offset = up
			C.Direction.DOWN:
				offset = down
			C.Direction.LEFT:
				offset = left
			C.Direction.RIGHT:
				offset = right
				
	return offset


## 序列化为字典
func to_dict() -> Dictionary:
	return {
		"left": left,
		"right": right,
		"up": up,
		"down": down,
		"any": any,
	}
