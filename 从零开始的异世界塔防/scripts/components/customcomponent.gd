extends BaseComponent
class_name CustomComponent

var custom: Dictionary = {}

func _ready() -> void:
	component_name = "Custom"
	set_setting_data()
