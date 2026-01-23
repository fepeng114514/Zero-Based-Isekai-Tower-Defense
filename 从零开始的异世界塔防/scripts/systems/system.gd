extends Node
class_name System

func _ready() -> void:
	get_parent().systems.append(self)

func _process(delta: float) -> void:
	pass
