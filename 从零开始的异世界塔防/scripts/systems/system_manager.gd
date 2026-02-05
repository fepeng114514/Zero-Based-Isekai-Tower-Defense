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
		system.init()

func _process(delta: float) -> void:
	# 待优化，每个系统重复遍历所有实体
	for system: System in systems:
		var system_func = system.get("on_update")
		system_func.call(delta)
	
	call_deferred("_process_remove_queue")
	call_deferred("_process_insert_queue")
	call_deferred("_process_grouping_entities")

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

func _process_grouping_entities() -> void:
	var new_entities_groups: Dictionary[String, Array] = {
		"enemies": [],
		"friendlys": [],
		"towers": [],
		"modifiers": [],
		"auras": [],
	}
	var new_entities_groups_with_components: Dictionary[String, Array] = {}
	
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e):
			continue

		if e.is_enemy():
			new_entities_groups[CS.GROUP_ENEMIES].append(e)
		if e.is_friendly():
			new_entities_groups[CS.GROUP_FRIENDLYS].append(e)
		if e.is_tower():
			new_entities_groups[CS.GROUP_TOWERS].append(e)
		if e.is_modifier():
			new_entities_groups[CS.GROUP_MODIFIERS].append(e)
		if e.is_aura():
			new_entities_groups[CS.GROUP_AURAS].append(e)

		for c_name: String in e.has_components.keys():
			if not new_entities_groups_with_components.has(c_name):
				new_entities_groups_with_components[c_name] = []

			if not e.has_c(c_name):
				continue

			new_entities_groups_with_components[c_name].append(e)

	EntityDB.entities_groups = new_entities_groups
	EntityDB.entities_groups_with_components = new_entities_groups_with_components

func process_systems(fn_name, arg) -> bool:
	for system: System in systems:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
