extends Node2D
class_name Entity

var id: int = -1
var template_name: String = ""
var target_id: int = -1
var source_id: int = -1
var components: Dictionary = {}
var state: String = "idle"
var bans: int = 0
var flags: int = 0
var ts: float = 0
var waiting: bool = false
var mod_bans: int = 0
var mod_type_bans: int = 0
var removed: bool = false
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)
var has_mods: Dictionary = {}

func _ready() -> void:
	Utils.set_setting_data(self, template_name)
	
func get_c(c_name: String):
	return components.get(c_name)

func has_component(c_name: String) -> bool:
	return components.has(c_name)
