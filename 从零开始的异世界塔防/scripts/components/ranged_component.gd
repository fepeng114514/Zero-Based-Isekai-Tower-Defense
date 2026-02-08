extends Node
class_name RangedComponent

var attacks: Array = []
var attack_templates: Dictionary = {}
var order: Array = []

func sort_attacks() -> void:
	order = attacks.duplicate()
	order.sort_custom(U.attacks_sort_fn)
