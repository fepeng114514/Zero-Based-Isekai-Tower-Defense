extends Node
class_name MeleeComponent

var attacks: Array = []
var attack_template: Dictionary = {}
var order: Array = []
var block_min_range: int = 0
var block_max_range: int = 0
var blockers: Dictionary = {}
var max_blocked: int = 1
var block_inc: int = 1
var block_flags: int = 0
var block_bans: int = 0
var search_mode: String = CS.SEARCH_MODE_ENEMY_FIRST
var melee_slot: Vector2 = Vector2(0, 0)

func sort_attacks():
	order = attacks.duplicate()
	order.sort_custom(Utils.attacks_sort_fn)
