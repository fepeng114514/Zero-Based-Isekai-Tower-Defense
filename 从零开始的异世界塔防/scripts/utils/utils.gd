extends Node

var rng = RandomNumberGenerator.new()

func random_int(from: int, to: int) -> int:
	return rng.randi_range(from, to)

func is_in_ellipse(p: Vector2, center: Vector2, radius: float, aspect: float = 0.7, r: float = 0.0) -> bool:
	var radius_x: float = radius	# 椭圆X轴半径
	var radius_y: float = radius * aspect	# 椭圆Y轴半径
	r = deg_to_rad(r)
	p = p.rotated(-r)
	
	# 椭圆方程: (x/rx)² + (y/ry)² <= 1
	var value = ((p.x - center.x) / radius_x) ** 2 + ((p.y - center.y) / radius_y) ** 2
	
	return value <= 1

# 加载 JSON 文件并解析
func load_json_file(path: String):
	# 检查文件是否存在
	if not FileAccess.file_exists(path):
		push_error("JSON 文件不存在: " + path)
		return null
	
	# 读取文件
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("无法打开文件: " + path)
		return null
	
	# 读取内容
	var content = file.get_as_text()
	file.close()
	
	# 解析 JSON
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		push_error("JSON 解析错误: " + json.get_error_message())
		push_error("错误行: " + str(json.get_error_line()))
		return null
	
	# 返回解析后的数据
	return json.get_data()

func is_has_c(entity: Entity, c_name: String) -> bool:
	return c_name in entity.components_name

# 从字典解析 Vector2
func dict_to_vector2(data: Dictionary):
	if data.is_empty():
		return data
	
	# 多种格式支持
	if data.has("x") and data.has("y"):
		return Vector2(int(data.x), int(data.y))
	elif data.has("width") and data.has("height"):
		return Vector2(int(data.width), int(data.height))
	
	return data
