extends Node
class_name System
## 系统类


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert(e: Entity) -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
func _on_remove(e: Entity) -> bool: return true


## 更新实体时调用
func _on_update(delta: float) -> void: pass
@warning_ignore_restore("unused_parameter")
#endregion
