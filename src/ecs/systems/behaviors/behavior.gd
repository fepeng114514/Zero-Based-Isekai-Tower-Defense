extends Node
class_name Behavior
## 行为类


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert(e: Entity) -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
func _on_remove(e: Entity) -> bool: return true


## 更新实体时调用，返回 true 的实体表示阻断后续行为
func _on_update(e: Entity) -> bool: return false

## 当行为树中断，且该行为被跳过时调用
func _on_skip(e: Entity) -> void: pass
@warning_ignore_restore("unused_parameter")
#endregion


static func can_attack(a: Variant, target: Entity) -> bool:
	return (
		target 
		and not U.is_mutual_ban(target.flags, a.bans, a.flags, target.bans)
		and U.is_allowed_entity(a, target)
	)
