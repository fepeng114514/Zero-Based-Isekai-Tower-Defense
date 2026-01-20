extends Node
signal director_update
signal director_start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EntitySystem.init()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	emit_signal("director_update")
	
	EntitySystem.update(delta)
