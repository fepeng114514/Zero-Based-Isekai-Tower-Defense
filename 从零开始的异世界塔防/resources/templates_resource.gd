extends Resource
class_name TemplatesResource

# 使用 @export 让资源在编辑器中可视
@export var templates_scenes: Array = [
	"enemy_goblin"
	#"bullet"
]

var preloaded_templates: Dictionary = {}

func _init():
	for template_name in templates_scenes:
		preloaded_templates[template_name] = load("res://scenes/templates/%s" % template_name + ".tscn")
		
	print()
