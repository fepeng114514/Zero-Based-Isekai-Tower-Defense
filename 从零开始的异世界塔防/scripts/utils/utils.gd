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

func load_json_file(path: String):
	if not FileAccess.file_exists(path):
		push_error("JSON 文件不存在: " + path)
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("无法打开文件: " + path)
		return null
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		push_error("JSON 解析错误: " + json.get_error_message())
		push_error("错误行: " + str(json.get_error_line()))
		return null
	
	# 返回解析后的数据
	return json.get_data()

func convert_type(value, type):
	match type:
		"int": value = int(value[1])
		"float": value = float(value[1])
		"vec2": value = Vector2(value[1], value[2])
		"rect2": value = Rect2(value[1], value[2], value[3], value[4])
		
	return value

func convert_dict_by_type(type_dict: Dictionary):
	var new_dict: Dictionary = {}
	
	for key: String in type_dict:
		var value = type_dict[key]
		
		if typeof(value) != TYPE_ARRAY:
			new_dict[key] = value
			continue
		
		var type = value[0]
		
		new_dict[key] = convert_type(value, type)

	return new_dict

func convert_data_by_type(value):
	if typeof(value) != TYPE_ARRAY:
		return value
		
	var type = value[0]

	return convert_type(value, type)

func merge_type_dict(dict1: Dictionary, dict2: Dictionary):
	for key in dict2:
		var value = dict2[key]
		var dict1_value = dict1[key]
		
		if typeof(dict1_value) != TYPE_ARRAY:
			dict1[key] = value
			continue
		
		var type = dict1_value[0]
			
		dict1[key] = convert_type(value, type)
		
	for key in dict1:
		var value = dict1[key]
		
		if typeof(value) != TYPE_ARRAY:
			dict1[key] = value
			continue
		
		var type = value[0]
			
		dict1[key] = convert_type(value, type)

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
	
func set_setting_data(obj, setting_data: Dictionary, filter = null) -> void:
	var keys: Array = setting_data.keys()
	
	if filter:
		keys = keys.filter(filter)
	
	for key: String in keys:
		var property = setting_data[key]
		property = convert_data_by_type(property)
		
		obj.set(key, property)

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
