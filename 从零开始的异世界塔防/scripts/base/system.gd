extends Node
class_name System
#
#func _ready() -> void:
	#SystemManager.systems.append(self)
##
#func _process(delta: float) -> void:
	#pass

func on_insert(e: Entity) -> bool: return true
	
func on_remove(e: Entity) -> bool: return true
	
func on_update(delta: float) -> void: pass
