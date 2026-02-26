extends Node
class_name UIComponent

var click_rect := Rect2(-12, -16, 13, 16)
var can_click: bool = true
var info_type: StringName = C.INFO_COMMON


## 获取全局位置的矩形
func get_global_click_rect(origin: Vector2) -> Rect2:
	return Rect2(origin + click_rect.position, click_rect.size)


## 检测是否点击矩形
func is_click_at(origin: Vector2, clicked_global_pos: Vector2) -> bool:
	return (
		can_click 
		and get_global_click_rect(origin).has_point(clicked_global_pos)
	)
