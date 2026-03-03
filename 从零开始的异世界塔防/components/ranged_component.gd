extends Node
class_name RangedComponent

## 是否禁用索敌
@export var disabled_search: bool = false

var list: Array[Ranged] = []
var order: Array[Ranged] = []

func sort_attacks() -> void:
	order = list.duplicate()
	order.sort_custom(U.attacks_sort_fn)
