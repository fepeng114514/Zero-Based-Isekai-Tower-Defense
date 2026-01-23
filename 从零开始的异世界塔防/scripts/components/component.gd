extends Node
class_name Component

func _ready() -> void:
	set_setting_data()
	
func get_setting_data() -> Dictionary:
	var template_name: String = get_template_name()
	var templates_data: Dictionary = EntityDB.templates_data[template_name]
	var c_name: String = name.replace("Component", "")
	var setting_data = templates_data.get(c_name)
	
	if not setting_data:
		return {}
	
	return setting_data

func get_template_name() -> String:
	return get_parent().template_name
	
func set_setting_data():
	var setting_data = get_setting_data()
	
	for key: String in setting_data.keys():
		var property = setting_data[key]
		
		set(key, property)
