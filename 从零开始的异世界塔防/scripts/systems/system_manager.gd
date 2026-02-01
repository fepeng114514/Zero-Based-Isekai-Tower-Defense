extends Node

var systems: Array[System] = []
var remove_queue: Array[Entity] = []
var insert_queue: Array[Entity] = []
var damage_queue: Array[Entity] = []

func set_required_systems(required_systems_name: Array) -> void:
	var required_systems: Array[System] = []

	for sys_name in required_systems_name:
		var system = DataManager.reqiured_data.required_systems[sys_name]

		required_systems.append(system.new())

	systems = required_systems

func _process(delta: float) -> void:
	call_deferred("_process_remove_queue")
	call_deferred("_process_insert_queue")
	
	if not process_systems("on_update", delta):
		return

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

func process_systems(fn_name, arg) -> bool:
	for system: System in systems:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
