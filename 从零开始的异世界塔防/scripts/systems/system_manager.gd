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
		var system_path: String = CS.PATH_SYSTEMS_SCRIPTS % sys_name
		
		if not ResourceLoader.exists(system_path):
			push_error("未找到系统: %s" % system_path)
			continue
			
		var system = load(system_path)

		required_systems.append(system.new())

	systems = required_systems
	
	for system: System in systems:
		system._initialize()

func _process(delta: float) -> void:
	for system: System in systems:
		var system_func = system.get("_on_update")
		system_func.call(delta)
	
	call_deferred("_process_remove_queue")
	call_deferred("_process_insert_queue")

func _process_remove_queue() -> void:	
	while remove_queue:
		var e = remove_queue.pop_front()
		if not is_instance_valid(e):
			continue
			
		EntityDB.mark_entity_dirty_id(e.id)
		e.free()

func _process_insert_queue() -> void:
	var entities: Array = EntityDB.entities
	while insert_queue:
		var e: Entity = insert_queue.pop_front()
	
		if entities:
			var entities_len: int = entities.size()
			if e.id != entities_len:
				push_error("实体列表长度未与实体 id 对应： id %d，长度 %d" % [e.id, entities_len])
		
		entities.append(e)
		EntityDB.mark_entity_dirty_id(e.id)
		#print("插入实体: %s（%d）" % [e.template_name, e.id])
		
		e.visible = true

func process_systems(fn_name, arg) -> bool:
	for system: System in systems:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
