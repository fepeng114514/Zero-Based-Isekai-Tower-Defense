extends Path2D
class_name Subpathway
## 子路径类


var follow: PathFollow2D = null
## 子路径索引
var idx: int = C.UNSET
## 间距
var spacing: float = 0
## 节点列表
var node_list: Array[PathwayNode] = []
## 子路径长度
var length: float = 0
## 父路径
var parent_pathway: Pathway = null


func _ready() -> void:
	follow = PathFollow2D.new()
	follow.name = "Follow"
	follow.loop = false

	add_child(follow)
	curve = create_offset_curve()
	length = curve.get_baked_length()
	node_list = get_equally_spaced_nodes()


## 创建偏移曲线
func create_offset_curve() -> Curve2D:
	var source_pathway_curve: Curve2D = parent_pathway.curve
	var new_curve := Curve2D.new()
	
	# 沿着曲线采样多个点
	var sample_points: PackedVector2Array = []
	var offset_points: PackedVector2Array = []
	
	# 获取曲线的长度
	var curve_length: float = source_pathway_curve.get_baked_length()
	var sample_count := int(curve_length)
	
	# 均匀采样
	for i in range(sample_count):
		var t: float = float(i) / (sample_count - 1)
		var distance: float = t * curve_length
		var point: Vector2 = source_pathway_curve.sample_baked(distance)
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


## 获取等距的节点列表
func get_equally_spaced_nodes() -> Array[PathwayNode]:
	var nodes_list: Array[PathwayNode] = []
	
	var point_spacing: float = length / (PathDB.node_count - 1)
	
	for i: int in range(PathDB.node_count):
		var distance: float = i * point_spacing
		var pos: Vector2 = to_global(curve.sample_baked(distance))

		nodes_list.append(
			PathwayNode.new(
				parent_pathway.idx,
				idx,
				i,
				pos,
				clampf(distance / length, 0, 1),
				distance,
			)
		)
	
	return nodes_list
