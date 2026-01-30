extends AttackComponent
class_name MeleeComponent

var block_min_range: int = 0
var block_max_range: int = 0
var blockers: Dictionary = {}
var block_level: int = 1
var max_block: int = 1
var block_inc: int = 1
var block_flags: int = 0
var block_bans: int = 0
var block_search_mode: String = CS.SEARCH_MODE_ENEMY_FIRST
var melee_slot: Vector2 = Vector2(0, 0)

func _ready() -> void:
	attack_template = {
		"min_damage": 0,
		"max_damage": 0,
		"cooldown": 0,
		"mod": "",
		"damage_type": ["int", 0],
		"ts": 0,
		"animation": "",
		"chance": 1,
		"flags": ["int", 0],
		"bans": ["int", 0],
	}
	super._ready()
