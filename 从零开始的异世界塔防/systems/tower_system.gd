extends System

func _on_create(e: Entity) -> bool:
	var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
	
	if not tower_c:
		return true
		
	for sub_e: Entity in tower_c.get_children():
		tower_c.list.append(sub_e)
	
	return true


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
	var entities: Array = EntityDB.get_entities_group(C.CN_TOWER).filter(
		func(e: Entity) -> bool:
			return not e.state & C.STATE.BLOCK
	)

	for e: Entity in entities:
		var tower_c: TowerComponent = e.get_c(C.CN_TOWER)

		tower_c.cleanup_list()
		var list: Array[Entity] = tower_c.list
		
		if list.is_empty():
			continue

		var target: Entity = EntityDB.search_target(
			tower_c.search_mode, 
			e.global_position, 
			tower_c.max_range, 
			tower_c.min_range, 
			tower_c.vis_flag_bits, 
			tower_c.vis_ban_bits
		)
		
		if not target:
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
				sub_e.target_id = C.UNSET
				continue
				
			sub_e.target_id = target.id
			
		tower_c.ts = TimeDB.tick_ts
