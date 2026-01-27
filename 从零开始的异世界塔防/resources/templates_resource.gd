extends Resource
class_name TemplatesResource

@export var templates_scenes: Array = [
	"enemy_goblin",
	"bolt",
	"arrow",
	"tower_mage",
	"damage"
]

var templates: Dictionary = {}

func _init():
	for template_name in templates_scenes:
		templates[template_name] = load(CS.PATH_TEMPLATES_SCENES % template_name)
