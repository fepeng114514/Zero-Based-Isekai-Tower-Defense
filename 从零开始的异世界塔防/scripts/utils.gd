class_name Utils
static var constants = CS.new()
static var rng = RandomNumberGenerator.new()

static func random_int(from: int, to: int) -> int:
	return rng.randi_range(from, to)

static func is_in_ellipse(p: Vector2, center: Vector2, radius: float, aspect: float = 0.7) -> bool:
	var a: float = radius
	var b: float = radius * aspect
	var dx: float = p.x - center.x
	var dy: float = p.y - center.y
	
	var value = (dx / a) ** 2 + (dy / b) ** 2
	
	return value <= 1

static func dist_factor_inside_ellipse(p: Vector2, center: Vector2, radius: float, min_radius: float = 0, aspect: float = 0.7) -> float:
	var angle: float = center.angle_to(p)
	var a: float = radius
	var b: float = radius * aspect
	var v_len: float = Vector2(p.x - center.x, p.y - center.y).length()
	var e_len: float = Vector2(a * cos(angle), b * sin(angle)).length()

	if min_radius == 0:
		return clampf(v_len / e_len, 0, 1)
		
	var ma: float = min_radius
	var mb: float = min_radius * aspect
	var me_len: float = Vector2(ma * cos(angle), mb * sin(angle)).length()

	return clampf((v_len - me_len) / (e_len - me_len), 0, 1)

static func load_json_file(path: String):
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
	
	return json.get_data()

static func convert_json_data(data):
	var new_data
	
	match typeof(data):
		TYPE_DICTIONARY:
			new_data = {}

			for key in data:
				new_data[key] = convert_json_data(data[key])
		TYPE_ARRAY:
			new_data = []

			for value in data:
				new_data.append(convert_json_data(value))
		TYPE_STRING:
			new_data = parse_json_value(data)
		_:
			new_data = data

	return new_data

static var type_handlers: Dictionary = {
	"int": func(val): return int(val),
	"float": func(val): return float(val),
	"bool": func(val): return val == "true",
	"str": func(val): return str(val),
	"vec2": func(val): 
		var parts = val.split(",")
		return Vector2(float(parts[0]), float(parts[1])),
	"rect2": func(val): 
		var parts = val.split(",")
		return Rect2(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])),
	"color": func(val):
		var parts = val.split(",")
		return Color(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])),
	"const": func(val):
		return constants.get(val)
}
static func parse_json_value(value: String):
	var regex = RegEx.new()
	regex.compile("%(\\w+)\\(([^)]*)\\)")
	
	var result = regex.search(value)
	if not result:
		return value
	
	var type_name = result.get_string(1)
	var default_str = result.get_string(2)
	
	if type_name not in type_handlers:
		return value

	var handler = type_handlers[type_name]
	return handler.call(default_str) if default_str != "" else null
	
static func get_component_name(node_name) -> String:
	return node_name.replace("Component", "")
	
static func initial_linear_speed(from: Vector2, to: Vector2, t: float) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y) / t
	
	return Vector2(x, y)

static func position_in_linear(speed: Vector2, from: Vector2, t: float) -> Vector2:
	var x: float = speed.x * t + from.x
	var y: float = speed.y * t + from.y
	
	return Vector2(x, y)
	
static func initial_parabola_speed(from: Vector2, to: Vector2, t: float, g: int) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y - g * t * t / 2) / t
	
	return Vector2(x, y)

static func position_in_parabola(t: float, from: Vector2, speed: Vector2, g: int) -> Vector2:
	var x: float = speed.x * t + from.x
	var y: float = g * t * t / 2 + speed.y * t + from.y

	return Vector2(x, y)

static func merge_dict_recursive(dict1: Dictionary, dict2: Dictionary, overwrite: bool = true):
	for key in dict2:
		if not dict1.has(key):
			dict1[key] = dict2[key]
			continue

		if dict1[key] is Dictionary and dict2[key] is Dictionary:
			dict1[key] = merge_dict_recursive(dict1[key], dict2[key], overwrite)
		elif dict1[key] is Array and dict2[key] is Array:
			if overwrite:
				dict1[key] = dict2[key].duplicate()
			else:
				dict1[key] = merge_arrays(dict1[key], dict2[key])
		else:
			if overwrite:
				dict1[key] = dict2[key]

static func merge_dict_recursive_new(dict1: Dictionary, dict2: Dictionary, overwrite: bool = true):
	var new_dict: Dictionary = dict1.duplicate_deep()
	
	merge_dict_recursive(new_dict, dict2, overwrite)
	
	return new_dict

static func merge_arrays(arr1: Array, arr2: Array) -> Array:
	var result = arr1.duplicate()

	for item in arr2:
		if not item in result:
			result.append(item)

	return result
