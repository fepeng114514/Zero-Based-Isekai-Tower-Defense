extends Node
@onready var curren_scene = get_tree()
var rng = RandomNumberGenerator.new()

func random_int(from: int, to: int) -> int:
	return rng.randi_range(from, to)

func is_in_ellipse(p: Vector2, center: Vector2, radius: float, aspect: float = 0.7) -> bool:
	var a: float = radius
	var b: float = radius * aspect
	var dx: float = p.x - center.x
	var dy: float = p.y - center.y
	
	var value = (dx / a) ** 2 + (dy / b) ** 2
	
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

# 从字典解析 Vector2
func dict_to_vector2(data: Dictionary):
	if data.is_empty():
		return null
	
	# 多种格式支持
	if data.has("x") and data.has("y"):
		return Vector2(data.x, data.y)
	elif data.has("w") and data.has("h"):
		return Vector2(data.w, data.h)
	
	return null
	
func dict_to_rect2(data: Dictionary):
	if data.is_empty():
		return null
	
	if data.has("x") and data.has("y") and data.has("w") and data.has("h"):
		return Rect2(data.x, data.y, data.w, data.h)
	
	return null
	
func try_convert_dict(data):
	if typeof(data) != TYPE_DICTIONARY:
		return data
	
	var rect2 = dict_to_rect2(data)
	if rect2 != null:
		return rect2
		
	var vec2 = dict_to_vector2(data)
	if vec2 != null:
		return vec2
		
	return data

func get_component_name(node_name) -> String:
	return node_name.replace("Component", "")
	
func get_setting_data(template_name: String, component_name = null) -> Dictionary:
	var templates_data = EntityDB.templates_data.get(template_name)
	
	if not templates_data:
		if template_name != "damage":
			push_error("未找到模板数据： %s", template_name)
		return {}
	
	var data
	
	if component_name:
		data = templates_data.get(component_name)
	else:
		data = templates_data
		
	if not data:
		return {}
	
	return data
	
func set_setting_data(component, template_name: String, component_name = null) -> void:
	var setting_data = get_setting_data(template_name, component_name)
	
	for key: String in setting_data.keys():
		var property = setting_data[key]
		property = try_convert_dict(property)
		
		component.set(key, property)

func initial_linear_speed(from: Vector2, to: Vector2, t: float) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y) / t
	
	return Vector2(x, y)

func position_in_linear(speed: Vector2, from: Vector2, t: float) -> Vector2:
	var x: float = speed.x * t + from.x
	var y: float = speed.y * t + from.y
	
	return Vector2(x, y)
	
func initial_parabola_speed(from: Vector2, to: Vector2, t: float, g: int) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y - g * t * t / 2) / t
	
	return Vector2(x, y)

func position_in_parabola(t: float, from: Vector2, speed: Vector2, g: int) -> Vector2:
	var x: float = speed.x * t + from.x
	var y: float = g * t * t / 2 + speed.y * t + from.y

	return Vector2(x, y)
