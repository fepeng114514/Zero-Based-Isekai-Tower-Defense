extends Path2D
class_name Path

var subpath: Array = []

@export var spacing: float = 20.0

func _ready():
	add_child(create_follow())
	subpath.append(self)
	
	# 创建左右路径
	var left_path: Path2D = Path2D.new()
	var right_path: Path2D = Path2D.new()
	
	left_path.curve = create_offset_curve(-spacing)
	right_path.curve = create_offset_curve(spacing)
	
	# 设置不同颜色以便区分
	left_path.name = "LeftPath"
	right_path.name = "RightPath"
	
	# 添加Line2D可视化
	#add_line_visualization(left_path, Color.RED)
	#add_line_visualization(right_path, Color.BLUE)
	#add_line_visualization(self, Color.GREEN)
	
	add_child(left_path)
	add_child(right_path)
	left_path.add_child(create_follow())
	right_path.add_child(create_follow())
	subpath.append(left_path)
	subpath.append(right_path)
	PathDB.paths.append(self)
	
func create_follow():
	var follow: PathFollow2D = PathFollow2D.new()
	follow.name = "Follow"
	return follow

func create_offset_curve(offset: float) -> Curve2D:
	var new_curve = Curve2D.new()
	
	# 沿着曲线采样多个点
	var sample_points = []
	var offset_points = []
	
	# 获取曲线的长度
	var curve_length = curve.get_baked_length()
	var sample_count = int(curve_length)
	
	# 均匀采样
	for i in range(sample_count):
		var t = float(i) / (sample_count - 1)
		var distance = t * curve_length
		var point = curve.sample_baked(distance)
		sample_points.append(point)
	
	# 计算每个采样点的偏移
	for i in range(sample_points.size()):
		var tangent = Vector2.ZERO
		
		# 计算切线（前向差分）
		if i < sample_points.size() - 1:
			tangent = (sample_points[i + 1] - sample_points[i]).normalized()
		#elif i > 0:
			#tangent = (sample_points[i] - sample_points[i - 1]).normalized()
		
		if tangent.length_squared() > 0:
			# 计算法线并偏移
			var normal = Vector2(-tangent.y, tangent.x)
			var offset_point = sample_points[i] + normal * offset
			offset_points.append(offset_point)
	
	# 将偏移点添加到新曲线
	for i in range(offset_points.size()):
		var point = offset_points[i]
		
		# 计算控制点（简化处理）
		if i == 0 or i == offset_points.size() - 1:
			new_curve.add_point(point)
		else:
			# 使用前后点计算平滑的控制点
			var prev_point = offset_points[i - 1]
			var next_point = offset_points[i + 1]
			
			var in_vec = (prev_point - point) * 0.25
			var out_vec = (next_point - point) * 0.25
			
			new_curve.add_point(point, in_vec, out_vec)
	
	return new_curve

func add_line_visualization(path: Path2D, color: Color):
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = color
	
	# 从曲线获取点
	var c = path.curve
	var points = c.get_baked_points()
	line.points = points
	
	path.add_child(line)

#func get_equally_spaced_points(count: int) -> PackedVector2Array:
	#"""获取路径上等间距的多个点"""
	#var points: PackedVector2Array = []
	#if not path_follow or not path_follow.curve:
		#return points
	#
	#var total_length = path_follow.curve.get_baked_length()
	#var spacing = total_length / (count - 1) if count > 1 else 0
	#
	#for i in range(count):
		#var distance = i * spacing
		#var local_pos = path_follow.curve.sample_baked(distance)
		#points.append(path_follow.to_global(local_pos))
	#
	#return points
