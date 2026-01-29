extends AnimatedSprite2D
class_name SpriteComponent
@onready var parent = get_parent()

func _ready() -> void:
	var setting_data: Dictionary = Utils.get_setting_data(get_template_name(), Utils.get_component_name(name))
	Utils.set_setting_data(self, setting_data)
	parent.components[name] = self
	
func get_template_name() -> String:
	return parent.template_name
