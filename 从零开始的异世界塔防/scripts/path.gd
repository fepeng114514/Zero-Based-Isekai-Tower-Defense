extends Path2D
class_name Path

var subpaths: Array[Subpath] = []
var last_spi: int = 0
var active: bool = true
var idx: int = -1

func _ready():
	PathDB.paths.append(self)
	idx = PathDB.last_pi

	var max_subpath: int = PathDB.max_subpath
	var spacing: int = PathDB.subpath_spacing
	
	var half_total_spacing: int = max_subpath * spacing / 2

	for i: int in range(max_subpath):
		var offset: int = half_total_spacing - (spacing * i)
		var subpath: Subpath = create_subpath(offset)
	
		add_line_visualization(subpath, Color.RED)

	PathDB.last_pi += 1
	
func enable() -> void:
	active = true

func disable() -> void:
	active = false

func is_active() -> bool:
	return active

func create_subpath(s: int) -> Subpath:
	var subpath = Subpath.new()
	subpath.spacing = s
	subpath.origin_path = self
	add_child(subpath)

	subpaths.append(subpath)

	last_spi += 1

	return subpath

func add_line_visualization(subpath: Subpath, color: Color):
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = color
	
	# 从曲线获取点
	var c = subpath.curve
	line.points = c.get_baked_points()
	
	subpath.add_child(line)
