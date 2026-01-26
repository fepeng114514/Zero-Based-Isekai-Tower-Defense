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
var removed: bool = false
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)

func _ready() -> void:
	Utils.set_setting_data(self, template_name)
	
func get_component(c_name: String):
	return components.get(c_name)

func has_component(c_name: String) -> bool:
	return components.has(c_name)
