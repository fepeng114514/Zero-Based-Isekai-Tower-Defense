extends System

"""近战系统:
	管理实体的近战攻击拦截
	对于拦截者: 寻找与标记被拦截者状态，仅前往拦截第一个被拦截者（前往被拦截者的近战位置）
	对于被拦截者: 如果是被第一个拦截，则原地等待拦截者到达自身近战位置，反之前往拦截者的近战位置
"""

	
func _on_create(e: Entity) -> bool:
	if not e.has_c(C.CN_MELEE):
		return true
		
	var melee_c: RangedComponent = e.get_c(C.CN_MELEE)
	
	for a: Melee in melee_c.get_children():
		melee_c.list.append(a)
		
	return true
		

func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_MELEE):
		return true
		
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	melee_c.sort_attacks()
	
	return true


func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_entities_group(C.CN_MELEE).filter(
		func(e: Entity) -> bool:
			return not e.waiting and e.has_state(C.STATE.MELEE | C.STATE.IDLE)
	)

	for e: Entity in entities:
		var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
		melee_c.cleanup_blocker()
		melee_c.cleanup_blockeds()
		melee_c.calculate_blocked_count()
			
		if melee_c.is_blocker:
			process_blocker(e, melee_c)
		elif melee_c.is_blocked:
			process_blocked(e, melee_c)
			
		do_attacks(e, melee_c)
	

func process_blocker(e: Entity, melee_c: MeleeComponent) -> void:
	var blockeds_ids: Array = melee_c.blockeds_ids
	
	if blockeds_ids and melee_c.blocked_count >= melee_c.max_blocked:
		return
		
	if not melee_c.melee_slot_arrived:
		go_melee_slot(e, melee_c)
		return
		
	var targets: Array = find_blocked(e, melee_c)
		
	if not targets and not blockeds_ids:
		melee_c.melee_slot_arrived = true
		
		if melee_c.origin_pos_arrived:
			return
			
		back_origin_pos(e, melee_c)
	
	if not targets or melee_c.is_passive_obstacle:
		return
		
	var blocked: Entity = EntityDB.get_entity_by_id(blockeds_ids[0])
	var blocked_melee_c: MeleeComponent = blocked.get_c(C.CN_MELEE)
	var melee_slot: Vector2 = blocked.position + blocked_melee_c.melee_slot_offset
	e.state = C.STATE.MELEE

	melee_c.set_melee_slot(melee_slot)
	if melee_c.origin_pos_arrived:
		melee_c.set_origin_pos(e.position)
	

func find_blocked(e: Entity, melee_c: MeleeComponent) -> Array:
	var filter = func(entity) -> bool: return (
		entity.has_c(C.CN_MELEE) and not entity.id in melee_c.blockeds_ids
	)

	var targets = EntityDB.search_targets_in_range(
		melee_c.search_mode, 
		e.position, 
		melee_c.block_max_range, 
		melee_c.block_min_range, 
		melee_c.block_flag_bits, 
		melee_c.block_ban_bits, 
		filter
	)	
	
	for t in targets:
		melee_c.calculate_blocked_count()
		if melee_c.blocked_count >= melee_c.max_blocked:
			break
		
		var t_melee_c: MeleeComponent = t.get_c(C.CN_MELEE)
		var t_melee_slot: Vector2 = e.position + melee_c.melee_slot_offset
		t_melee_c.blocker_id = e.id
		melee_c.blockeds_ids.append(t.id)
		t.state = C.STATE.MELEE
		t_melee_c.set_melee_slot(t_melee_slot)
		t_melee_c.set_origin_pos(t.position)
	
	return targets
	

func process_blocked(e: Entity, melee_c: MeleeComponent) -> void:
	var blocker_id: int = melee_c.blocker_id
	
	if not U.is_valid_number(blocker_id):
		melee_c.melee_slot_arrived = true
		
		if melee_c.origin_pos_arrived:
			return
			
		back_origin_pos(e, melee_c)
		return
	
	var blocker: Entity = EntityDB.get_entity_by_id(blocker_id)
	var blocker_melee_c: MeleeComponent = blocker.get_c(C.CN_MELEE)
	var blocker_blockeds_ids: Array = blocker_melee_c.blockeds_ids
	
	if (
		not blocker_blockeds_ids 
		or not blocker_melee_c.is_passive_obstacle
		and blocker_blockeds_ids[0] == e.id
	):
		return
		
	if not melee_c.melee_slot_arrived:
		go_melee_slot(e, melee_c)
		return
	
	if not melee_c.melee_slot_arrived:
		go_melee_slot(e, melee_c)


func go_melee_slot(e: Entity, melee_c: MeleeComponent) -> void:
	melee_c.motion_direction = (melee_c.melee_slot - e.position).normalized()
	e.position += melee_c.motion_direction * melee_c.motion_speed * TimeDB.frame_length
	
	if not U.is_at_destination(e.position, melee_c.melee_slot, melee_c.arrived_dist):
		return
		
	melee_c.melee_slot_arrived = true
	

func back_origin_pos(e: Entity, melee_c: MeleeComponent) -> void:
	melee_c.motion_direction = (melee_c.origin_pos - e.position).normalized()
	e.position += melee_c.motion_direction * melee_c.motion_speed * TimeDB.frame_length
	
	if not U.is_at_destination(e.position, melee_c.origin_pos, melee_c.arrived_dist):
		return
		
	melee_c.origin_pos_arrived = true
	e.state = C.STATE.IDLE


func do_attacks(e: Entity, melee_c: MeleeComponent) -> void:
	if not melee_c.blockeds_ids:
		return
		
	var blocked_id: int = melee_c.blockeds_ids[0]
	var blocked: Entity = EntityDB.get_entity_by_id(blocked_id)
	for a: Melee in melee_c.order:
		if not can_attack(a, blocked):
			continue
			
		attack(e, a, melee_c, blocked)


func attack(e: Entity, a: Melee, _melee_c: MeleeComponent, blocked: Entity) -> void:
	EntityDB.create_damage(
		blocked.id, a.min_damage, a.max_damage, a.damage_type, e.id
	)
	EntityDB.create_mods(blocked.id, a.mods, e.id)
	a.ts = TimeDB.tick_ts
