extends Node

"""系统管理器:
	控制系统主循环与实体插入移除。
	使用队列控制实体插入与移除。
"""

var systems: Array[System] = []
var remove_queue: Array[Entity] = []
var insert_queue: Array[Entity] = []
var damage_queue: Array[Entity] = []


func load(required_systems_name: Array) -> void:
	systems = []
	remove_queue = []
	insert_queue = []
	damage_queue = []
	
	var required_systems: Array[System] = []

	# 加载需要的系统
	for sys_name in required_systems_name:
		var system_path: String = C.PATH_SYSTEMS % sys_name
		
		if not ResourceLoader.exists(system_path):
			printerr("未找到系统: %s" % system_path)
			continue
			
		var system = load(system_path)

		required_systems.append(system.new())

	systems = required_systems
	
	# 初始化系统
	for system: System in systems:
		system._initialize()


## 系统主循环
func _physics_process(delta: float) -> void:
	for system: System in systems:
		var system_func = system.get("_on_update")
		
		system_func.call(delta)
	
	# 帧末尾处理插入与移除
	call_deferred("_process_insert_queue")
	call_deferred("_process_remove_queue")


## 处理实体插入队列
func _process_insert_queue() -> void:
	var entities: Array = EntityDB.entities
	
	while insert_queue:
		var e: Entity = insert_queue.pop_front()
	
		if entities:
			var entities_len: int = entities.size()
			if e.id != entities_len:
				printerr("实体列表长度未与实体 id 对应: id %d, 长度 %d" % [e.id, entities_len])
		
		entities.append(e)
		# 调用所有系统中的插入回调函数，遇到一个返回 false 的系统表示当前实体不能插入，中断并移除当前实体
		if not call_systems("_on_insert", e):
			e.remove_entity()
			continue
		
		EntityDB.mark_entity_dirty_id(e.id)
		print_verbose("插入实体: %s(%d)" % [e.template_name, e.id])
		
		e.visible = true


## 处理实体移除队列
func _process_remove_queue() -> void:	
	while remove_queue:
		var e = remove_queue.pop_front()
		
		if not is_instance_valid(e):
			continue
		
		# 调用所有系统中的移除回调函数
		call_systems("_on_remove", e)
			
		EntityDB.mark_entity_dirty_id(e.id)
		e.free()


## 调用所有系统中的指定回调函数
func call_systems(fn_name: String, arg) -> bool:
	for system: System in systems:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
