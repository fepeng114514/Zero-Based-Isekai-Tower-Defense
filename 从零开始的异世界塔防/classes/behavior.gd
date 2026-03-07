extends Node
class_name Behavior


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert(e: Entity) -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
func _on_remove(e: Entity) -> bool: return true


## 更新实体时调用，返回 true 的实体表示阻断后续行为
func _on_update(e: Entity) -> bool: return false


func _on_return_false(e: Entity) -> void: pass


func _on_return_true(e: Entity) -> void: pass
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
