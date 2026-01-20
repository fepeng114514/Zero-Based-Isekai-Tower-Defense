extends Node
signal director_update
signal director_start

func _ready() -> void:
	EntitySystem.init()

func _process(delta: float) -> void:
	emit_signal("director_update")
	
	EntitySystem.update(delta)
