extends AttackComponent
class_name RangedComponent

func _ready() -> void:
	attack_template = {
		"min_range": 0,
		"max_range": 0,
		"cooldown": 0,
		"bullet": "",
		"ts": 0,
		"search_mode": CS.SEARCH_MODE_FIRST,
		"flags": ["int", 0],
		"bans": ["int", 0],
		"animation": "",
		"chance": 1
	}
	super._ready()
