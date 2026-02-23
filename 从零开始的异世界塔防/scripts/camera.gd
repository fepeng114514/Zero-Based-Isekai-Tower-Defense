extends Camera2D
class_name Camera

@export var scroll_speed: int = 500  # 相机移动速度
@export var edge_threshold: int = 50  # 边缘检测阈值（像素）

# 缩放相关变量
@export var zoom_speed: float = 0.1  # 缩放速度
@export var min_zoom: float = 0.1    # 最小缩放值
@export var max_zoom: float = 0.5    # 最大缩放值
@export var zoom_smooth_speed: float = 8.0  # 缩放平滑速度（可选）

var screen_size: Vector2
var camera: Camera2D
var target_zoom: Vector2  # 目标缩放值（用于平滑缩放）

func _ready():
	# 获取屏幕大小
	screen_size = get_viewport().get_visible_rect().size
	# 获取相机节点
	camera = get_viewport().get_camera_2d()
	# 初始化目标缩放
	target_zoom = zoom

func _process(delta):
	# 获取鼠标位置
	var mouse_pos = get_viewport().get_mouse_position()
	
	# 计算移动方向
	var direction = Vector2.ZERO
	
	# 检测左边缘
	if mouse_pos.x <= edge_threshold:
		direction.x -= 1
	# 检测右边缘
	elif mouse_pos.x >= screen_size.x - edge_threshold:
		direction.x += 1
	
	# 检测上边缘
	if mouse_pos.y <= edge_threshold:
		direction.y -= 1
	# 检测下边缘
	elif mouse_pos.y >= screen_size.y - edge_threshold:
		direction.y += 1
	
	# 移动相机
	if direction != Vector2.ZERO:
		camera.position += direction.normalized() * scroll_speed * delta
	
	# 平滑缩放（可选）
	zoom = zoom.lerp(target_zoom, zoom_smooth_speed * delta)

func _input(event):
	# 检测滚轮事件
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:  # 滚轮向上
			zoom_in(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:  # 滚轮向下
			zoom_out(event.position)

# 以鼠标位置为中心放大
func zoom_in(mouse_position: Vector2):
	# 计算新的缩放值
	var new_zoom = target_zoom - Vector2(zoom_speed, zoom_speed)
	# 限制最小缩放
	if new_zoom.x >= min_zoom and new_zoom.y >= min_zoom:
		# 获取鼠标在世界坐标中的位置
		var mouse_world_pos = get_global_mouse_position()
		
		# 方法1：直接缩放（不平滑）
		# zoom = new_zoom
		# position = mouse_world_pos - (mouse_position - position) / zoom
		
		# 方法2：平滑缩放
		target_zoom = new_zoom
		# 调整相机位置以鼠标为中心缩放
		position = mouse_world_pos - (mouse_position - position) / target_zoom

# 以鼠标位置为中心缩小
func zoom_out(mouse_position: Vector2):
	# 计算新的缩放值
	var new_zoom = target_zoom + Vector2(zoom_speed, zoom_speed)
	# 限制最大缩放
	if new_zoom.x <= max_zoom and new_zoom.y <= max_zoom:
		# 获取鼠标在世界坐标中的位置
		var mouse_world_pos = get_global_mouse_position()
		
		# 方法1：直接缩放（不平滑）
		# zoom = new_zoom
		# position = mouse_world_pos - (mouse_position - position) / zoom
		
		# 方法2：平滑缩放
		target_zoom = new_zoom
		# 调整相机位置以鼠标为中心缩放
		position = mouse_world_pos - (mouse_position - position) / target_zoom
