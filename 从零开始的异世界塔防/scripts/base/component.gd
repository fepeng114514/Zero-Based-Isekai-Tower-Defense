extends Node
class_name Component
@onready var parent = get_parent()
var component_flags: int = 0

func _ready() -> void:
	var setting_data: Dictionary = Utils.get_setting_data(get_template_name(), Utils.get_component_name(name))
	Utils.set_setting_data(self, setting_data)
	parent.components[name] = self
	parent.flags = parent.flags | component_flags
	
func get_template_name() -> String:
	return parent.template_name
	
