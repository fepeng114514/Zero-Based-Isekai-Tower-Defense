extends System
class_name TowerSystem
## 防御塔系统
##
## 处理拥有 [TowerComponent] 防御塔组件的实体


func _on_insert(e: Entity) -> bool:
	var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
	
	if not tower_c:
		return true
		
	for sub_e: Entity in tower_c.list:
		sub_e.is_subentity = true
		sub_e.source_id = e.id
		EntityDB.process_create(sub_e)
		sub_e.insert_entity()
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityDB.get_entities_group(C.CN_TOWER):
		var tower_c: TowerComponent = e.get_c(C.CN_TOWER)

		tower_c.cleanup_list()
		var list: Array[Entity] = tower_c.list
		
		if list.is_empty():
			continue
			
		if tower_c.attack_loop_time == 0:
			continue
			
		if not TimeDB.is_ready_time(tower_c.ts, tower_c.attack_loop_time):
			continue
			
		tower_c.attack_entity_idx += 1
		if tower_c.attack_entity_idx >= list.size():
			tower_c.attack_entity_idx = 0
			
		var curren_e: Entity = list[tower_c.attack_entity_idx]
		
		for sub_e: Entity in list:
			if sub_e != curren_e:
				sub_e.blocking = true
				continue
				
			sub_e.blocking = false
			
		tower_c.ts = TimeDB.tick_ts
