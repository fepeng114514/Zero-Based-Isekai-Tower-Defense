extends Node2D

@onready var path_follow = get_parent()
#
func get_equally_spaced_points(count: int) -> PackedVector2Array:
	"""获取路径上等间距的多个点"""
	var points: PackedVector2Array = []
	if not path_follow or not path_follow.curve:
		return points
	
	var total_length = path_follow.curve.get_baked_length()
	var spacing = total_length / (count - 1) if count > 1 else 0
	
	for i in range(count):
		var distance = i * spacing
		var local_pos = path_follow.curve.sample_baked(distance)
		points.append(path_follow.to_global(local_pos))
	
	return points
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#
	#var points = get_equally_spaced_points(10)
	#for i in range(points.size()):
		#print("点 %d: %s" % [i, points[i]])
		# 可以在这里创建标记或让实体移动到这些点


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
