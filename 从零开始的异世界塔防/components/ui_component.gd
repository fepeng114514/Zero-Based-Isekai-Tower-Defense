@tool
extends Node2D
class_name UIComponent

@export var click_rect := Rect2(-16, -16, 32, 32):
	set(value):
		click_rect = value
		queue_redraw()
@export var can_click: bool = true:
	set(value):
		can_click = value
		queue_redraw()
@export var info_type: C.INFO = C.INFO.UNIT


## 获取全局位置的矩形
func get_global_click_rect(origin: Vector2) -> Rect2:
	return Rect2(origin + click_rect.position, click_rect.size)


## 检测是否点击矩形
func is_click_at(origin: Vector2, clicked_global_pos: Vector2) -> bool:
	return (
		can_click 
		and get_global_click_rect(origin).has_point(clicked_global_pos)
	)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	if not can_click:
		return
		
	# 绘制边框矩形
	draw_rect(
		Rect2(click_rect.position, click_rect.size), 
		Color.GREEN, 
		false, 
		1.0
	)
