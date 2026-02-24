extends Camera2D
class_name Camera

var dragging: bool = false
var drag_start_position := Vector2.ZERO

func _ready() -> void:
	limit_left = 0
	limit_top = 0
	limit_right = 2560
	limit_bottom = 1440
	editor_draw_limits = true
	position = Vector2(1280, 720) 

func _unhandled_input(event: InputEvent) -> void:
	# 左键点击事件开始拖动
	if event.is_action_pressed("left_click"):
		dragging = true
		drag_start_position = event.position
			
	# 左键点击事件松开结束拖动
	if event.is_action_released("left_click"):
		dragging = false
	
	# 拖动时鼠标移动移动相机
	if not dragging:
		return
		
	# 计算鼠标移动距离
	var drag_offset: Vector2 = drag_start_position - event.position
	# 移动相机（注意：要除以缩放倍数，否则缩放后拖动速度不对）
	position += drag_offset / zoom
	# 更新起始位置
	drag_start_position = event.position
