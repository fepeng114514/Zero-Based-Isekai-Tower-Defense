class_name U
static var constants := C.new()

## 判断点是否在圆中
static func is_in_radius(center: Vector2, point: Vector2, radius: float) -> bool:
	return center.distance_to(point) <= radius
	
## 计算根据点与圆的距离衰减的因子
static func dist_factor_inside_radius(
		center: Vector2, 
		point: Vector2, 
		max_radius: float, 
		min_radius: float = 0, 
	) -> float:
	var dist: float = center.distance_to(point)
	
	if min_radius == 0:
		return dist / max_radius
		
	var ring_dist: float = dist - min_radius
	var ring_radius: float = max_radius - min_radius
		
	return ring_dist / ring_radius
	
## 计算点在指定方向和距离上的另一个点
static func point_on_circle(
		point: Vector2, radius: float, angle: float = 0
	) -> Vector2:
	return point + Vector2.from_angle(angle) * radius

## 判断点是否位于椭圆中
static func is_in_ellipse(
		center: Vector2, point: Vector2, radius: float, aspect: float = 0.7
	) -> bool:
	var a: float = radius
	var b: float = radius * aspect
	var dx: float = point.x - center.x
	var dy: float = point.y - center.y
	
	var value = (dx / a) ** 2 + (dy / b) ** 2
	
	return value <= 1

## 计算根据点与椭圆的距离衰减的因子
static func dist_factor_inside_ellipse(
		center: Vector2, 
		point: Vector2, 
		max_radius: float, 
		min_radius: float = 0, 
		aspect: float = 0.7
	) -> float:
	var angle: float = center.angle_to(point)
	var a: float = max_radius
	var b: float = max_radius * aspect
	var v_len: float = Vector2(point.x - center.x, point.y - center.y).length()
	var e_len: float = Vector2(a * cos(angle), b * sin(angle)).length()

	if min_radius == 0:
		return v_len / e_len
		
	var ma: float = min_radius
	var mb: float = min_radius * aspect
	var me_len: float = Vector2(ma * cos(angle), mb * sin(angle)).length()

	return (v_len - me_len) / (e_len - me_len)

## 计算点在指定方向和距离上椭圆空间的另一个点
static func point_on_ellipse(
		point: Vector2, radius: float, angle: float = 0, aspect: float = 0.7
	) -> Vector2:
	var a: float = radius
	var b: float = radius * aspect
	var x: float = point.x + a * cos(angle)
	var y: float = point.y + b * sin(angle)

	return Vector2(x, y)

## 根据距离与时间计算直线速度
static func initial_linear_velocity(from: Vector2, to: Vector2, t: float) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y) / t
	
	return Vector2(x, y)

## 根据时间与速度计算位于直线上的位置
static func position_in_linear(velocity: Vector2, from: Vector2, t: float) -> Vector2:
	var x: float = velocity.x * t + from.x
	var y: float = velocity.y * t + from.y
	
	return Vector2(x, y)
	
## 根据距离与时间计算抛物线速度
static func initial_parabola_velocity(
		from: Vector2, to: Vector2, t: float, g: int
	) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y - g * t * t / 2) / t
	
	return Vector2(x, y)
	
## 根据时间与速度计算位于抛物线上的位置
static func position_in_parabola(
		velocity: Vector2, from: Vector2, t: float, g: int
	) -> Vector2:
	var x: float = velocity.x * t + from.x
	var y: float = g * t * t / 2 + velocity.y * t + from.y

	return Vector2(x, y)

static func is_at_destination(current_pos: Vector2, target_pos: Vector2, threshold: float = 5.0) -> bool:
	return current_pos.distance_to(target_pos) <= threshold

## 加载 JSON 文件
static func load_json_file(path: String):
	if not FileAccess.file_exists(path):
		printerr("JSON 文件不存在: " + path)
		return null
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("无法打开文件: " + path)
		return null
	
	var content: String = file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result: int = json.parse(content)
	
	if parse_result != OK:
		printerr("JSON 解析错误: " + json.get_error_message())
		printerr("错误行: " + str(json.get_error_line()))
		return null
	
	return json.get_data()

## 递归转换 JSON 数据中的格式化字符串
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
		return (
			Rect2(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3]))
		),
	"color": func(val):
		var parts = val.split(",")
		return (
			Color(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3]))
		),
	"const": func(val):
		var parts = val.split(",")
		
		if parts.size() == 1:
			return constants.get(parts[0])
		
		var new_value: int = 0
		
		for p in parts:
			new_value &= p
			
		return new_value
}

## 解析格式化字符串
static func parse_json_value(value: String):
	var regex := RegEx.new()
	regex.compile("%(\\w+)\\(([^)]*)\\)")
	
	var result: RegExMatch = regex.search(value)
	if not result:
		return value
	
	var type_name: String = result.get_string(1)
	var default_str: String = result.get_string(2)
	
	if type_name not in type_handlers:
		return value

	var handler: Callable = type_handlers[type_name]
	return handler.call(default_str) if default_str != "" else null
	
static func get_component_name(node_name) -> String:
	return node_name.replace("Component", "")

## 浅拷贝，不同于 duplicate 此方法会安全处理不同类型
static func clone(value):
	if value is Dictionary:
		var result = {}
		for key in value:
			result[key] = value[key]
		return result
	
	if value is Array:
		var result = []
		for item in value:
			result.append(item)
		return result
	
	# 基础类型和不可变对象直接返回
	return value
	
## 深拷贝，不同于 duplicate_deep 此方法会安全处理不同类型
static func deepclone(value):
	# 对于字典，递归复制
	if value is Dictionary:
		var result = {}
		for key in value:
			result[key] = deepclone(value[key])
		return result
	
	# 对于数组，同样递归复制
	if value is Array:
		var result = []
		for item in value:
			result.append(deepclone(item))
		return result
	
	# 尝试调用对象的 duplicate 方法
	if value is Object and value.has_method("duplicate"):
		return value.duplicate()
	
	# 基础类型和不可变对象直接返回
	return value

## 深合并字典, source 的键值会覆盖或合并到 target
static func deepmerge_dict(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> void:
	for key in source:
		var source_value = deepclone(source[key])
		
		# 如果 target 没有这个键，直接赋值
		if not target.has(key):
			target[key] = source_value
			continue
		
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[key] = source_value
		
## 创建新字典并深合并字典, source 的键值会覆盖或合并到 target
static func deepmerge_dict_new(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> Dictionary:
	var result = deepclone(target)
	deepmerge_dict(result, source, overwrite)
	return result

## 浅合并数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func merge_array(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	var target_size = target.size()
	for i in range(source.size()):
		var mv = source[i]
		
		if i >= target_size:
			target.append(mv)
			continue
		
		if not overwrite:
			continue
		
		target[i] = mv
	
## 创建新数组并浅合并数组, 按索引合并，source 的元素会合并到 target 对应索引,
## 如果 source 更长，多出的元素会追加到 target
static func merge_array_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result = deepclone(target)
	merge_array(result, source, overwrite)
	return result
		
## 深合并数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func deepmerge_array(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	var target_size = target.size()
	for i in range(source.size()):
		var mv = deepclone(source[i])
		
		if i >= target_size:
			target.append(mv)
			continue
		
		if not overwrite:
			continue
		
		target[i] = mv

## 创建新数组并深合并数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func deepmerge_array_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result = deepclone(target)
	deepmerge_array(result, source, overwrite)
	return result
	
## 递归浅合并字典, source 的键值会覆盖或合并到 target
static func merge_dict_recursive(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> void:
	for key in source:
		var source_value = source[key]
		
		# 如果 target 没有这个键，直接赋值
		if not target.has(key):
			target[key] = source_value
			continue
			
		var target_value = target[key]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			merge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			merge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[key] = source_value
		
## 创建新字典并递归浅合并两个字典, source 的键值会覆盖或合并到 target
static func merge_dict_recursive_new(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> Dictionary:
	var result = deepclone(target)
	merge_dict_recursive(result, source, overwrite)
	return result

## 递归深合并字典, source 的键值会覆盖或合并到 target
static func deepmerge_dict_recursive(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> void:
	for key in source:
		var source_value = deepclone(source[key])
		
		# 如果 target 没有这个键，直接赋值
		if not target.has(key):
			target[key] = source_value
			continue
			
		var target_value = target[key]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			deepmerge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			deepmerge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[key] = source_value
		
## 创建新字典并递归深合并两个字典, source 的键值会覆盖或合并到 target
static func deepmerge_dict_recursive_new(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> Dictionary:
	var result = deepclone(target)
	deepmerge_dict_recursive(result, source, overwrite)
	return result

## 递归浅合并数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func merge_array_recursive(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	for i in range(source.size()):
		var source_value = source[i]
		
		# 如果 target 没有这个索引，直接追加
		if i >= target.size():
			target.append(source_value)
			continue
			
		var target_value = target[i]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			merge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			merge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[i] = source_value

## 创建新数组并递归浅合并两个数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func merge_array_recursive_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result = deepclone(target)
	merge_array_recursive(result, source, overwrite)
	return result
	
## 递归深合并数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func deepmerge_array_recursive(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	for i in range(source.size()):
		var source_value = deepclone(source[i])
		
		# 如果 target 没有这个索引，直接追加
		if i >= target.size():
			target.append(source_value)
			continue
			
		var target_value = target[i]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			deepmerge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			deepmerge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[i] = source_value

## 创建新数组并递归深合并两个数组, 按索引合并，source 的元素会合并到 target 对应索引, 
## 如果 source 更长，多出的元素会追加到 target
static func deepmerge_array_recursive_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result = deepclone(target)
	deepmerge_array_recursive(result, source, overwrite)
	return result

static func attacks_sort_fn(a1, a2) -> bool:
	var a1_chance: float = a1.chance
	var a2_chance: float = a2.chance
	var a1_cooldown: float = a1.cooldown
	var a2_cooldown: float = a2.cooldown
	
	return (
		(a1_chance != a2_chance and a1_chance < a2_chance)
		or (a1_cooldown != a2_cooldown and a1_cooldown > a2_cooldown)
	)

## 判断实体是否有效
static func is_vaild_entity(e) -> bool:
	return e and is_instance_valid(e) and not e.removed

static func is_allowed_entity(e, target: Entity):
	var t_template_name: String = target.template_name
	
	return (
		(
			not e.whitelist_template
			or t_template_name in e.whitelist_template
		)
		and t_template_name not in e.blacklist_template
	)

static func fts(time: float) -> float:
	return time / C.FPS

static func to_percent(num: float) -> float:
	return num / 100
