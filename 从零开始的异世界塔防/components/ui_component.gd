extends Node
class_name UIComponent

@export var click_rect := Rect2(-16, -16, 32, 32)
@export var can_click: bool = true
@export var info_type: C.INFO = C.INFO.UNIT
@export var show_info: bool = false

var selected: bool = false


## 获取全局位置的矩形
func get_global_click_rect(origin: Vector2) -> Rect2:
	return Rect2(origin + click_rect.position, click_rect.size)


## 检测是否点击矩形
func is_click_at(origin: Vector2, clicked_global_pos: Vector2) -> bool:
	return (
		can_click 
		and get_global_click_rect(origin).has_point(clicked_global_pos)
	)
