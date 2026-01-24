extends AttackComponent
class_name MeleeComponent

var melee_range: int = 0

func _ready() -> void:
	attack_template = {
		"min_damage": 0,
		"max_damage": 0,
		"cooldown": 0,
		"mod": "",
		"damage_type": 0,
	}
	super._ready()
