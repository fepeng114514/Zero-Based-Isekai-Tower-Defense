extends Node
class_name RangedComponent

var list: Array[Ranged] = []
var order: Array[Ranged] = []


func sort_attacks() -> void:
	order = list.duplicate()
	order.sort_custom(U.attacks_sort_fn)
