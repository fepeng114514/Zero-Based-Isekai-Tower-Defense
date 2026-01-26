extends AttackComponent
class_name RangedComponent

func _ready() -> void:
	attack_template = {
		"min_range": 0,
		"max_range": 0,
		"cooldown": 0,
		"bullet": "",
		"ts": 0
	}
	super._ready()
