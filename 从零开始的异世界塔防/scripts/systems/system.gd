extends Node
class_name System

func init() -> void: pass

func on_create(e: Entity) -> bool: return true

func on_insert(e: Entity) -> bool: return true
	
func on_remove(e: Entity) -> bool: return true

# 返回 false 阻断后续更新
func on_update(delta: float) -> bool:  return true
