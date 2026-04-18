extends System
class_name HealthSystem
## 血量系统
##
## 处理拥有 [HealthComponent] 血量组件的实体


func _on_insert(e: Entity) -> bool:
	var health_c: HealthComponent = e.get_child_node(C.CN_HEALTH)
	if not health_c:
		return true
		
	health_c.hp = health_c.hp_max
	
	return true
