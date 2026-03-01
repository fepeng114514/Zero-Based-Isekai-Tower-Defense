extends Path2D

## 路径类
class_name Pathway


@export var active: bool = true
var subpathways: Array[Subpathway] = []
var last_spi: int = 0
var idx: int = C.UNSET


func _ready() -> void:
	PathDB.pathways.append(self)
	idx = PathDB.last_pi

	var max_subpathway: int = PathDB.max_subpathway
	var spacing: float = PathDB.subpathway_spacing
	
	var half_total_spacing: float = max_subpathway * spacing / 2

	for i: int in range(max_subpathway):
		var offset: float = half_total_spacing - (spacing * i)
		var subpathway: Subpathway = create_subpathway(offset)
	
		#add_line_visualization(subpathway, Color.RED)

	PathDB.last_pi += 1
	

func enable() -> void:
	active = true


func disable() -> void:
	active = false


func is_active() -> bool:
	return active


func create_subpathway(spacing: float) -> Subpathway:
	var subpathway := Subpathway.new()
	subpathway.spacing = spacing
	subpathway.origin_path = self
	add_child(subpathway)

	subpathways.append(subpathway)

	last_spi += 1

	return subpathway


func add_line_visualization(subpathway: Subpathway, color: Color) -> void:
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = color
	
	# 从曲线获取点
	var c: Curve2D = subpathway.curve
	line.points = c.get_baked_points()
	
	subpathway.add_child(line)
