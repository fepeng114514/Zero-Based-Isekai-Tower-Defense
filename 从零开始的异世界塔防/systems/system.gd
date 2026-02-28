extends Node
class_name System

var blacklist_state: int = C.STATE.NONE
var whitelist_state: int = C.STATE.NONE
var wait_entity: bool = false


#region 回调函数
## 系统初始化时调用
func _initialize() -> void: pass


## 准备插入实体时调用（创建实体），返回 false 的实体不会被创建
## [br]
## 注：此时节点还未初始化
func _on_ready_insert(e: Entity) -> bool: return true


## 正式插入实体时调用，返回 false 的实体将会被移除
## [br]
## 注：此时节点已准备完毕
func _on_insert(e: Entity) -> bool: return true


## 准备移除实体时调用，返回 false 的实体将不会被移除
## [br]
## 注：此时进入移除队列
func _on_ready_remove(e: Entity) -> bool: return true


## 正式移除实体时调用
func _on_remove(e: Entity) -> void: pass


## 更新实体时调用
func _on_update(delta: float) -> void: pass
#endregion


func can_attack(a: Variant, target: Entity) -> bool:
	return (
		U.is_vaild_entity(target)
		and TimeDB.is_ready_time(a.ts, a.cooldown) 
		and not (
			a.vis_ban_set.has_flags(target.flag_set.bits)
			or a.vis_flag_set.has_flags(target.ban_set.bits)
		)
		and U.is_allowed_entity(a, target)
	)


## 遍历实体组中所有实体，其中 process_func 为 func(e: Entity) -> void
func process_entities(group_name: String, process_func: Callable) -> void:
	for e: Entity in EntityDB.get_entities_group(group_name):
		if (
			e.state & blacklist_state 
			or (whitelist_state and not e.state & whitelist_state)
		):
			continue

		if wait_entity and e.is_waiting():
			continue
		
		process_func.call(e)
