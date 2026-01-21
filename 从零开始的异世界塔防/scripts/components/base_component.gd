extends Node
class_name BaseComponent

var component_name: String = ""

func get_setting_data() -> Dictionary:
	var template_name: String = get_template_name()
	return EntitySystem.templates_data[template_name][component_name]

func get_template_name() -> String:
	return get_parent().template_name
	
func set_setting_data():
	var setting_data = get_setting_data()
	
	for key: String in setting_data.keys():
		var property = setting_data[key]
		
		set(key, property)
