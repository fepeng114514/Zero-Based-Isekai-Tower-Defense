extends Node
class_name SystemManager

@onready var Entities = $Entities
var systems: Array = []

func _process_systems(system_name: String, entity: Entity) -> void:
	for system: System in systems:
		var system_func = system.get(system_name)
		
		if not system_func:
			continue
			
		if not system_func.call(entity):
			break

func _process(delta: float) -> void:
	for system: System in systems:
		if not system.get("on_update"):
			continue
			
		system.on_update(delta)
	
	_process_entities_update(delta)
	call_deferred("_process_remove_queue")
	call_deferred("_process_insert_queue")

func _process_remove_queue() -> void:
	for i: int in range(EntityDB.remove_queue.size() - 1, -1, -1):
		var entity: Entity = EntityDB.remove_queue.pop_at(i)
		
		_process_systems("on_remove", entity)
		
		entity.free()

func _process_insert_queue() -> void:
	var insert_queue = EntityDB.insert_queue
	for i: int in range(insert_queue.size() - 1, -1, -1):
		var entity: Entity = insert_queue.pop_at(i)
		
		_process_systems("on_insert", entity)
		
		Entities.add_child(entity)
			
		EntityDB.insert_entity(entity)

func _process_entities_update(delta: float) -> void:
	for entity in EntityDB.entities:
		if not is_instance_valid(entity) or not entity.get("update"):
			continue
			
		entity.update(delta)
		
