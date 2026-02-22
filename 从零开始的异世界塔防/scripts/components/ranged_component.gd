extends Node
class_name RangedComponent

var list: Array = []
var templates: Dictionary = {}
var order: Array = []

func sort_attacks() -> void:
	order = list.duplicate()
	order.sort_custom(U.attacks_sort_fn)
