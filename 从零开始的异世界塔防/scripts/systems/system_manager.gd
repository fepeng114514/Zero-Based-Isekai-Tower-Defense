extends Node

var systems: Array = []
var remove_queue: Array[Entity] = []
var insert_queue: Array[Entity] = []
var damage_queue: Array[Entity] = []

func _process(delta: float) -> void:
	for system: System in systems:
		if not system.get("on_update"):
			continue
			
		system.on_update(delta)
	
	call_deferred("_process_remove_queue")
	call_deferred("_process_insert_queue")

func _process_remove_queue() -> void:	
	while remove_queue:
		var e = remove_queue.pop_front()
		if not is_instance_valid(e):
			continue
		
		e.free()

func _process_insert_queue() -> void:
	while insert_queue:
		var e: Entity = insert_queue.pop_front()
		
		EntityDB.insert(e)
		
		e.visible = true
