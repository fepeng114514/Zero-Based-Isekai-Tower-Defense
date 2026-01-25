extends Node2D
class_name Entity

var id: int = -1
var template_name: String = ""
var target_id: int = -1
var source_id: int = -1
var components: Dictionary = {}
var state: String = "idle"
var vis_bans: int = 0
var vis_flags: int = 0

func _ready() -> void:
	set_setting_data()
	
func get_setting_data() -> Dictionary:
	var setting_data = EntityDB.templates_data.get(template_name)
	
	if not setting_data:
		return {}
	
	return setting_data

func set_setting_data():
	var setting_data = get_setting_data()
	
	for key: String in setting_data.keys():
		var property = setting_data[key]
		
		set(key, property)
	
func get_component(c_name: String):
	return components.get(c_name)
