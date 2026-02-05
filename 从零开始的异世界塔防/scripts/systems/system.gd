extends Node
class_name System

## 系统初始化时调用
func _initialize() -> void: pass

## 创建实体时调用
func _on_create(e: Entity) -> bool: return true

## 插入实体时调用
func _on_insert(e: Entity) -> bool: return true
	
## 移除实体时调用
func _on_remove(e: Entity) -> bool: return true

## 更新实体时调用
func _on_update(delta: float) -> void: pass

func can_attack(a: Dictionary, target: Entity) -> bool:
	return TM.is_ready_time(a.ts, a.cooldown) and\
		not (a.bans & target.flags or a.flags & target.bans)
