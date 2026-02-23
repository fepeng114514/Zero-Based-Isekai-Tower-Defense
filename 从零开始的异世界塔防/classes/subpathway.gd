extends Path2D
class_name Subpathway

var follow: PathFollow2D
var idx: int = -1
var spacing: float = 0
var nodes: Array[PathwayNode] = []
var length: float = 0
var origin_path: Pathway


func _ready() -> void:
	idx = origin_path.last_spi

	follow = PathFollow2D.new()
	follow.name = "Follow"
	follow.loop = false

	add_child(follow)
	curve = create_offset_curve()
	length = curve.get_baked_length()
	nodes = get_equally_spaced_nodes()


func create_offset_curve() -> Curve2D:
	var origin_path_curve: Curve2D = origin_path.curve
	var new_curve := Curve2D.new()
	
	# 沿着曲线采样多个点
	var sample_points: PackedVector2Array = []
	var offset_points: PackedVector2Array = []
	
	# 获取曲线的长度
	var curve_length: float = origin_path_curve.get_baked_length()
	var sample_count := int(curve_length)
	
	# 均匀采样
	for i in range(sample_count):
		var t: float = float(i) / (sample_count - 1)
		var distance: float = t * curve_length
		var point: Vector2 = origin_path_curve.sample_baked(distance)
		sample_points.append(point)
	
	# 计算每个采样点的偏移
	for i in range(sample_points.size()):
		var tangent := Vector2.ZERO
		
		# 计算切线（前向差分）
		if i < sample_points.size() - 1:
			tangent = (sample_points[i + 1] - sample_points[i]).normalized()
		
		if tangent.length_squared() > 0:
			# 计算法线并偏移
			var normal := Vector2(-tangent.y, tangent.x)
			var offset_point: Vector2 = sample_points[i] + normal * spacing
			offset_points.append(offset_point)
	
	# 将偏移点添加到新曲线
	for i in range(offset_points.size()):
		var point: Vector2 = offset_points[i]
		
		# 计算控制点（简化处理）
		if i == 0 or i == offset_points.size() - 1:
			new_curve.add_point(point)
			continue
		
		# 使用前后点计算平滑的控制点
		var prev_point: Vector2 = offset_points[i - 1]
		var next_point: Vector2 = offset_points[i + 1]
		
		var in_vec: Vector2 = (prev_point - point) * 0.25
		var out_vec: Vector2 = (next_point - point) * 0.25
		
		new_curve.add_point(point, in_vec, out_vec)
	
	return new_curve


func get_equally_spaced_nodes() -> Array[PathwayNode]:
	var nodes_list: Array[PathwayNode] = []
	
	var point_spacing: float = length / (PathDB.node_count - 1)
	
	for i: int in range(PathDB.node_count):
		var distance: float = i * point_spacing
		var pos: Vector2 = to_global(curve.sample_baked(distance))

		nodes_list.append(
			PathwayNode.new(
				origin_path.idx,
				idx,
				i,
				pos,
				clampf(distance / length, 0, 1),
				distance,
			)
		)
	
	return nodes_list
