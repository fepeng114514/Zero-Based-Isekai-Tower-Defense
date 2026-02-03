extends Node
class_name RangedComponent

var attacks: Array = []
var attack_templates: Dictionary = {}
var order: Array = []

func sort_attacks():
	order = attacks.duplicate()
	order.sort_custom(Utils.attacks_sort_fn)
