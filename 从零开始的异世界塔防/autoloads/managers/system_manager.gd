extends Node
## 系统管理器
##
## 控制系统主循环与实体插入移除，使用队列控制实体插入与移除。


## 系统列表
var system_list: Array[System] = []
## 实体移除队列
var remove_queue: Array[Entity] = []
## 实体插入队列
var insert_queue: Array[Entity] = []
## 伤害队列
var damage_queue: Array[Damage] = []


func load(new_system_list: Array[System]) -> void:
	system_list.clear()
	remove_queue.clear()
	insert_queue.clear()
	damage_queue.clear()
	
	system_list = new_system_list

## 系统主循环
func _physics_process(delta: float) -> void:
	for system: System in system_list:
		system._on_update(delta)
	
	# 帧末尾处理插入与移除
	call_deferred("_process_insert_queue")
	call_deferred("_process_remove_queue")


## 处理实体插入队列
func _process_insert_queue() -> void:
	var entity_list: Array = EntityMgr.entity_list
	
	while insert_queue:
		var e: Entity = insert_queue.pop_front()
	
		if entity_list:
			var entities_len: int = entity_list.size()
			if e.id != entities_len:
				Log.error(
					"实体列表长度未与实体 id 对应: id %d, 长度 %d" 
					% [e.id, entities_len]
				)
		
		entity_list.append(e)
		# 调用所有系统中的插入回调函数，遇到一个返回 false 的系统表示当前实体不能插入，中断并移除当前实体
		if not call_systems("_on_insert", e):
			e.remove_entity()
			continue
		
		Log.verbose("插入实体: %s" % e)
		
		e.visible = true


## 处理实体移除队列
func _process_remove_queue() -> void:	
	while remove_queue:
		var e = remove_queue.pop_front()
		
		if not is_instance_valid(e):
			continue
		
		# 调用所有系统中的移除回调函数，遇到一个返回 false 的系统表示当前实体不能移除，中断并保留当前实体
		if not call_systems("_on_remove", e):
			e.visible = true
			e.removed = false
			continue
			
		e.free()


## 调用所有系统中的指定回调函数
## 
## 如果遇到一个返回 false 的系统则返回 false，否则返回 true
func call_systems(fn_name: String, arg) -> bool:
	for system: System in system_list:
		var system_func = system.get(fn_name)

		if not system_func.call(arg):
			return false

	return true
