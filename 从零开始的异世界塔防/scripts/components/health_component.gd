extends BaseComponent
class_name HealthComponent

var hp_max: int = 0
var hp: int = 0
var health_bar_hidden: bool = false
var dead: bool = false

func _ready() -> void:
	component_name = "Health"
	set_setting_data()

func get_hp_percent() -> float:
	return float(self.hp) / float(self.hp_max)
