extends Node

var systems: Array[System] = []
var remove_queue: Array[Entity] = []
var insert_queue: Array[Entity] = []
var damage_queue: Array[Entity] = []

func clean() -> void:
	systems = []
	remove_queue = []
	insert_queue = []
	damage_queue = []

func set_required_systems(required_systems_name: Array) -> void:
	var required_systems: Array[System] = []

	for sys_name in required_systems_name:
		var system = DataManager.reqiured_data.required_systems[sys_name]

		required_systems.append(system.new())

	systems = required_systems
	
	for system: System in systems:
		system.init()

func _process(delta: float) -> void:
	# 待优化，每个系统重复遍历所有实体
	for system: System in systems:
		var system_func = system.get("on_update")
		system_func.call(delta)
	
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

func process_systems(fn_name, arg) -> bool:
	for system: System in systems:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
