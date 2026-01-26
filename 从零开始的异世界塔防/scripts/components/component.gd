extends Node
class_name Component
@onready var parent = get_parent()

func _ready() -> void:
	Utils.set_setting_data(self, get_template_name(), Utils.get_component_name(name))
	parent.components[name] = self
	
func get_template_name() -> String:
	return parent.template_name
	
