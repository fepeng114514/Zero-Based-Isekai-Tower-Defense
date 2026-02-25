extends Camera2D
class_name Camera

@onready var tween: Tween = create_tween()
var dragging: bool = false
var drag_start_position := Vector2.ZERO
var zoom_factor: float = 1.1
var zoom_duration: float = 0.2
var zoom_min: float = 0
var zoom_max: float = 2

func _ready() -> void:
	S.resized_window_s.connect(_on_resized_window)
	
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	limit_left = 0
	limit_top = 0
	limit_right = 2560
	limit_bottom = 1440
	editor_draw_limits = true
	position = Vector2(1280, 720)
	
	_reset_zoom()
	

func _input(event: InputEvent) -> void:
	# 滚动事件
	if event.is_action("scroll_up"):
		_smooth_zoom(false)
		
	elif event.is_action("scroll_down"):
		_smooth_zoom(true)
	
	# 左键点击事件开始拖动
	elif event.is_action_pressed("left_click"):
		dragging = true
		drag_start_position = event.position
	# 左键点击事件松开结束拖动
	elif event.is_action_released("left_click"):
		dragging = false
	
	# 拖动时鼠标移动移动相机
	if not dragging:
		return
		
	_move(event.position)


func _smooth_zoom(reversed: bool = false) -> void:
	var target_zoom: Vector2
	
	if reversed:
		target_zoom = zoom / zoom_factor
	else:
		target_zoom = zoom * zoom_factor
	
	# 限制缩放范围
	target_zoom = target_zoom.clampf(zoom_min, zoom_max)
	
	# 重启tween
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)
	#tween.parallel().tween_property(
		#self, "position", get_global_mouse_position() * target_zoom, zoom_duration
	#)


func _move(target_pos: Vector2) -> void:
	# 计算鼠标移动距离
	var drag_offset: Vector2 = drag_start_position - target_pos
	# 移动相机（注意：要除以缩放倍数，否则缩放后拖动速度不对）
	position += drag_offset / zoom
	drag_start_position = target_pos


func _reset_zoom() -> void:
	var window_size_factor: Vector2 = (
		Global.WINDOW_SIZE / Global.MAX_WINDOW_SIZE
	)
	zoom_min = window_size_factor.x
	zoom = Vector2(zoom_min, zoom_min)


func _on_resized_window() -> void:
	_reset_zoom()
