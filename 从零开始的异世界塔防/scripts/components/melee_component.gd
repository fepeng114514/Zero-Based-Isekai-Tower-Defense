extends AttackComponent
class_name MeleeComponent

var melee_range: int = 0
var blockers: Dictionary = {}
var block_level: int = 0

func _ready() -> void:
	attack_template = {
		"min_damage": 0,
		"max_damage": 0,
		"cooldown": 0,
		"mod": "",
		"damage_type": ["int", 0],
		"ts": 0,
		"animation": "",
		"chance": 1
	}
	super._ready()
