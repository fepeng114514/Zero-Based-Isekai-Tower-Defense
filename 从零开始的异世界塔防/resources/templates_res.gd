extends Resource
class_name TemplatesRes

@export var templates_name: Array = [
	"enemy_goblin",
	"bullet_bolt",
	"bullet_arrow",
	"bullet_bomb",
	"bullet_sword",
	"tower_mage",
	"damage"
]

var templates: Dictionary = {}

func _init():
	for template_name in templates_name:
		templates[template_name] = load(CS.PATH_TEMPLATES_SCENES % template_name)
