extends Node
class_name System

func _ready() -> void:
	get_parent().systems.append(self)
#
#func _process(delta: float) -> void:
	#pass

func is_has_c(entity: Entity, c_name: String) -> bool:
	return c_name in entity.components_name
