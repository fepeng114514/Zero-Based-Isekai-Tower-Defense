extends System

"""近战系统：
对于友方：寻找与标记被拦截者状态，友方仅前往拦截第一个敌人（前往敌人的近战位置）
对于敌方：如果是被友方第一个拦截，则原地等待拦截者到达自身近战位置，反之前往拦截者的近战位置
"""

func _on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_MELEE):
		return true
		
	var melee_c: MeleeComponent = e.get_c(CS.CN_MELEE)
	melee_c.sort_attacks()
	
	return true

func _on_update(delta: float) -> void:
	for e in EntityDB.get_entities_by_group(CS.CN_MELEE):
		var state: int = e.state
			
		if e.waitting or not state & (CS.STATE_IDLE | CS.STATE_MELEE):
			continue
		
		var melee_c: MeleeComponent = e.get_c(CS.CN_MELEE)
		melee_c.cleanup_blocker()
		melee_c.cleanup_blockeds()
		melee_c.calculate_blocked_count()
			
		if e.flags & CS.FLAG_FRIENDLY:
			process_friendly(e, melee_c)
		elif e.flags & CS.FLAG_ENEMY:
			process_enemy(e, melee_c)
			
		do_attacks(e, melee_c)

func process_friendly(e: Entity, melee_c: MeleeComponent):
	var blockeds_ids: Array = melee_c.blockeds_ids
	
	if blockeds_ids and melee_c.blocked_count >= melee_c.max_blocked:
		return
		
	if not melee_c.melee_slot_arrived:
		go_melee_slot(e, melee_c)
		return
		
	var targets: Array = friendly_find_enemies(e, melee_c)
		
	if not targets and not blockeds_ids:
		melee_c.melee_slot_arrived = true
		
		if melee_c.origin_pos_arrived:
			return
			
		back_origin_pos(e, melee_c)
	
	if not targets or melee_c.is_passive_obstacle:
		return
		
	var blocked: Entity = EntityDB.get_entity_by_id(blockeds_ids[0])
	var blocked_melee_c: MeleeComponent = blocked.get_c(CS.CN_MELEE)
	var melee_slot: Vector2 = blocked.position + blocked_melee_c.melee_slot_offset
	e.state = CS.STATE_MELEE

	melee_c.set_melee_slot(melee_slot)
	if melee_c.origin_pos_arrived:
		melee_c.set_origin_pos(e.position)
	
func friendly_find_enemies(e: Entity, melee_c: MeleeComponent):
	var filter = func(entity, origin): return entity.has_c(CS.CN_MELEE) and not entity.id in melee_c.blockeds_ids
	var targets = EntityDB.search_targets_in_range(
		melee_c.search_mode, e.position, melee_c.block_min_range, 
		melee_c.block_max_range, melee_c.block_flags, melee_c.block_bans, filter
	)	
	
	for t in targets:
		melee_c.calculate_blocked_count()
		if melee_c.blocked_count >= melee_c.max_blocked:
			break
		
		var t_melee_c: MeleeComponent = t.get_c(CS.CN_MELEE)
		var t_melee_slot: Vector2 = e.position + melee_c.melee_slot_offset
		t_melee_c.blocker_id = e.id
		melee_c.blockeds_ids.append(t.id)
		t.state = CS.STATE_MELEE
		t_melee_c.set_melee_slot(t_melee_slot)
		t_melee_c.set_origin_pos(t.position)
	
	return targets
	
func process_enemy(e: Entity, melee_c: MeleeComponent):
	var blocker_id = melee_c.blocker_id
	
	if blocker_id == null:
		melee_c.melee_slot_arrived = true
		
		if melee_c.origin_pos_arrived:
			return
			
		back_origin_pos(e, melee_c)
		return
	
	var blocker: Entity = EntityDB.get_entity_by_id(blocker_id)
	var blocker_melee_c: MeleeComponent = blocker.get_c(CS.CN_MELEE)
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

func go_melee_slot(e: Entity, melee_c: MeleeComponent):
	melee_c.motion_direction = (melee_c.melee_slot - e.position).normalized()
	e.position += melee_c.motion_direction * melee_c.motion_speed * TM.frame_length
	
	if not melee_c.arrived_rect.has_point(melee_c.melee_slot - e.position):
		return
		
	melee_c.melee_slot_arrived = true
	
func back_origin_pos(e: Entity, melee_c: MeleeComponent):
	melee_c.motion_direction = (melee_c.origin_pos - e.position).normalized()
	e.position += melee_c.motion_direction * melee_c.motion_speed * TM.frame_length
	
	if not melee_c.arrived_rect.has_point(melee_c.origin_pos - e.position):
		return
		
	melee_c.origin_pos_arrived = true
	e.state = CS.STATE_IDLE
	return

func do_attacks(e: Entity, melee_c: MeleeComponent):
	if not melee_c.blockeds_ids:
		return
		
	var blocked_id: int = melee_c.blockeds_ids[0]
	var blocked: Entity = EntityDB.get_entity_by_id(blocked_id)
	for a: Dictionary in melee_c.order:
		if not can_attack(a, blocked):
			continue
			
		attack(e, a, melee_c, blocked)

func attack(e: Entity, a: Dictionary, melee_c: MeleeComponent, blocked: Entity):
	EntityDB.create_damage(blocked.id, a.min_damage, a.max_damage, a.damage_type, e.id)
	a.ts = TM.tick_ts
