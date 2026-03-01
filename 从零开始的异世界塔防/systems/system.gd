extends Node
class_name System


#region 回调函数
@warning_ignore_start("unused_parameter")
## 系统初始化时调用
func _initialize() -> void: pass


## 创建实体实体时调用，返回 false 的实体不会被创建
## [br]
## 注：此时节点还未初始化
func _on_create(e: Entity) -> bool: return true


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
@warning_ignore_restore("unused_parameter")
#endregion


func can_attack(a: Variant, target: Entity) -> bool:
	return (
		target
		and TimeDB.is_ready_time(a.ts, a.cooldown) 
		and not (
			a.vis_ban_bits & target.flag_bits
			or a.vis_flag_bits & target.ban_bits
		)
		and U.is_allowed_entity(a, target)
	)
