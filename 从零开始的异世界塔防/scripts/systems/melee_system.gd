extends System
class_name MeleeSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_MELEE):
		return true
		
	var melee_c: MeleeComponent = e.get_c(CS.CN_MELEE)
	melee_c.sort_attacks()
	
	return true

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e) or not e.has_c(CS.CN_MELEE):
			continue
			
		var state: int = e.state
			
		if e.waitting or not state & (CS.STATE_IDLE | CS.STATE_MELEE):
			continue
		
		var melee_c: MeleeComponent = e.get_c(CS.CN_MELEE)
			
		if e.flags & CS.FLAG_FRIENDLY:
			process_friendly(e, melee_c)
		elif e.flags & CS.FLAG_ENEMY:
			process_enemy(e, melee_c)
			
		attacks(e, melee_c)

## 友军控制谁应被拦截
func process_friendly(e: Entity, melee_c: MeleeComponent):
	melee_c.cleanup_blockeds()
	var blockeds_ids: Array = melee_c.blockeds_ids
	
	if not melee_c.melee_slot_arrived:
		go_melee_slot(e, melee_c)
		return
	
	if blockeds_ids and blockeds_ids.size() >= melee_c.max_blocked:
		return
		
	var targets: Array = friendly_find_enemies(e, melee_c)
	
	if not targets:
		if not melee_c.origin_pos_arrived:
			back_origin_pos(e, melee_c)
		return
		
	for t in targets:
		if blockeds_ids.size() >= melee_c.max_blocked:
			return
		
		var t_melee_c: MeleeComponent = t.get_c(CS.CN_MELEE)
		var t_melee_slot: Vector2 = e.position + melee_c.melee_slot_offset
		t_melee_c.blocker_id = e.id
		blockeds_ids.append(t.id)
		t.state = CS.STATE_MELEE
		t_melee_c.set_melee_slot(t_melee_slot)
		
	var blocked: Entity = EntityDB.get_entity_by_id(blockeds_ids[0])
	var blocked_melee_c: MeleeComponent = blocked.get_c(CS.CN_MELEE)
	var melee_slot: Vector2 = blocked.position + blocked_melee_c.melee_slot_offset
	e.state = CS.STATE_MELEE

	melee_c.set_origin_pos(e.position)
	melee_c.set_melee_slot(melee_slot)
	
func friendly_find_enemies(e: Entity, melee_c: MeleeComponent):
	var filter = func(entity, origin): return entity.has_c(CS.CN_MELEE) and not entity.id in melee_c.blockeds_ids
	var targets = EntityDB.search_targets_in_range(melee_c.search_mode, e.position, melee_c.block_min_range, melee_c.block_max_range, melee_c.block_flags, melee_c.block_bans, filter)	
	
	return targets
	
func process_enemy(e: Entity, melee_c: MeleeComponent):
	var blocker_id = melee_c.blocker_id
	
	if blocker_id == null:
		return
		
	melee_c.cleanup_blocker()
	
	var blocker: Entity = EntityDB.get_entity_by_id(blocker_id)
	var blocker_melee_c: MeleeComponent = blocker.get_c(CS.CN_MELEE)
	var blocker_blockeds_ids: Array = blocker_melee_c.blockeds_ids
	
	if not blocker_blockeds_ids or blocker_blockeds_ids[0] == e.id:
		return
	
	if not melee_c.melee_slot_arrived:
		go_melee_slot(e, melee_c)
		return
		
	var melee_slot: Vector2 = blocker.position + blocker_melee_c.melee_slot_offset
	melee_c.set_melee_slot(melee_slot)

func attacks(e: Entity, melee_c: MeleeComponent):
	for a: Dictionary in melee_c.order:
		pass

func go_melee_slot(e: Entity, melee_c: MeleeComponent):
	melee_c.motion_direction = (melee_c.melee_slot - e.position).normalized()
	e.position += melee_c.motion_direction * melee_c.motion_speed * TM.frame_length
	
	if melee_c.arrived_rect.has_point(melee_c.melee_slot - e.position):
		melee_c.melee_slot_arrived = true
		return
	
func back_origin_pos(e: Entity, melee_c: MeleeComponent):
	melee_c.motion_direction = (melee_c.origin_pos - e.position).normalized()
	e.position += melee_c.motion_direction * melee_c.motion_speed * TM.frame_length
	
	if melee_c.arrived_rect.has_point(melee_c.origin_pos - e.position):
		melee_c.origin_pos_arrived = true
		return
