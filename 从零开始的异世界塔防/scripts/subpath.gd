extends Path2D
class_name Subpath
@onready var parent = get_parent()
var follow: PathFollow2D

func _ready() -> void:
	parent.subpaths.append(self)

	follow = PathFollow2D.new()
	follow.name = "Follow"
	add_child(follow)
