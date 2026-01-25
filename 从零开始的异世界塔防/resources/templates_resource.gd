extends Resource
class_name TemplatesResource

@export var templates_scenes: Array = [
	"enemy_goblin",
	"bolt",
	"tower_mage",
	"damage"
]

var templates: Dictionary = {}

func _init():
	for template_name in templates_scenes:
		templates[template_name] = load("res://scenes/templates/%s.tscn" % template_name)
