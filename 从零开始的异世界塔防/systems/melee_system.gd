extends System
class_name MeleeSystem

"""近战系统:
	管理实体的近战攻击拦截
	对于拦截者: 寻找与标记被拦截者状态，仅前往拦截第一个被拦截者（前往被拦截者的近战位置）
	对于被拦截者: 如果是被第一个拦截，则原地等待拦截者到达自身近战位置，反之前往拦截者的近战位置
"""


func _on_insert(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c:
		return true
		
	melee_c.set_origin_pos(e.global_position)
		
	return true

func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_entities_group(C.CN_MELEE).filter(
		func(e: Entity) -> bool:
			return (
				not e.is_waiting() 
				and e.has_state(C.STATE.MELEE | C.STATE.IDLE)
			)
	)
	
	_process_blockers(entities)
	_process_blockeds(entities)
	

## 处理拦截者
func _process_blockers(entities: Array) -> void:
	for e: Entity in entities:
		var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
		if not melee_c.is_blocker:
			continue
			
		# 清理与计算被拦截者数量（考虑代价）
		melee_c.cleanup_blockeds()
		melee_c.calculate_blocked_count()
		
		# 超过最大拦截数量不进行索敌
		if melee_c.blocked_count < melee_c.max_blocked:
			var pending_blockeds: Array = _find_pending_blocked(
				e, melee_c
			)
			_process_pending_blockeds(e, melee_c, pending_blockeds)
		
		var blockeds_ids: Array = melee_c.blockeds_ids
		
		# 有被拦截者，前往近战位置，尝试攻击被拦截者
		if blockeds_ids:
			var blocked: Entity = EntityDB.get_entity_by_id(
				blockeds_ids[0]
			)
			e.state = C.STATE.MELEE
			
			# 是被动拦截者不前往近战位置
			if not melee_c.is_passive:
				var blocked_melee_c: MeleeComponent = blocked.get_c(
					C.CN_MELEE
				)
				melee_c.set_melee_slot(
					blocked.global_position 
					+ blocked_melee_c.melee_slot_offset
				)
				melee_c.origin_pos_arrived = false
				
				if not melee_c.melee_slot_arrived:
					_go_melee_slot(e, melee_c)
					continue
			
			_try_attack(e, melee_c, blocked)
		else:
			e.state = C.STATE.IDLE
			melee_c.melee_slot_arrived = true
			# 默认 origin_pos_arrived 为 true
			# 到达原位置重设原位置
			if melee_c.origin_pos_arrived:
				melee_c.set_origin_pos(e.global_position)
			else:
				_back_origin_pos(e, melee_c)


## 寻找待定被拦截者
func _find_pending_blocked(e: Entity, melee_c: MeleeComponent) -> Array:
	var filter = func(entity) -> bool: return (
		entity.has_c(C.CN_MELEE) and not entity.id in melee_c.blockeds_ids
	)
	
	var targets: Array = []
	
	targets = EntityDB.search_targets_in_range(
		melee_c.search_mode, 
		e.global_position, 
		melee_c.block_max_range, 
		melee_c.block_min_range, 
		melee_c.block_flag_bits, 
		melee_c.block_ban_bits, 
		filter
	)	
	
	return targets
	

## 处理待定被拦截者
func _process_pending_blockeds(
		e: Entity, melee_c: MeleeComponent, pending_blockeds: Array
) -> void:
	for t: Entity in pending_blockeds:
		melee_c.calculate_blocked_count()
		if melee_c.blocked_count >= melee_c.max_blocked:
			break
		
		var t_melee_c: MeleeComponent = t.get_c(C.CN_MELEE)
		t_melee_c.blocker_id = e.id
		melee_c.blockeds_ids.append(t.id)


## 处理被拦截者
func _process_blockeds(entities: Array) -> void:
	for e: Entity in entities:
		var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
		if melee_c.is_blocker:
			continue
			
		melee_c.cleanup_blocker()
		var blocker_id: int = melee_c.blocker_id
		
		if not U.is_valid_number(blocker_id):
			e.state = C.STATE.IDLE
			melee_c.melee_slot_arrived = true
			
			if melee_c.melee_slot_arrived:
				melee_c.set_origin_pos(e.global_position)
			else:
				_back_origin_pos(e, melee_c)
			continue
		
		var blocker: Entity = EntityDB.get_entity_by_id(blocker_id)
		var blocker_melee_c: MeleeComponent = blocker.get_c(C.CN_MELEE)
		
		e.state = C.STATE.MELEE
		if e.id == blocker_melee_c.blockeds_ids[0]:
			continue
	
		melee_c.set_melee_slot(
			blocker.global_position 
			+ blocker_melee_c.melee_slot_offset
		)
		melee_c.origin_pos_arrived = false
			
		if not melee_c.melee_slot_arrived:
			_go_melee_slot(e, melee_c)
			return

		_try_attack(e, melee_c, blocker)


func _go_melee_slot(e: Entity, melee_c: MeleeComponent) -> void:
	var direction: Vector2 = (
		melee_c.melee_slot - e.global_position
	).normalized()
	e.global_position += (
		direction 
		* melee_c.speed 
		* TimeDB.frame_length
	)
	
	if not U.is_at_destination(
			e.global_position, melee_c.melee_slot, melee_c.arrived_dist
	):
		return
		
	melee_c.melee_slot_arrived = true
	

func _back_origin_pos(e: Entity, melee_c: MeleeComponent) -> void:
	var direction: Vector2 = (
		melee_c.origin_pos - e.global_position
	).normalized()
	e.global_position += (
		direction 
		* melee_c.speed 
		* TimeDB.frame_length
	)
	
	if not U.is_at_destination(
			e.global_position, melee_c.origin_pos, melee_c.arrived_dist
	):
		return
		
	melee_c.origin_pos_arrived = true
	e.state = C.STATE.IDLE


func _try_attack(e: Entity, melee_c: MeleeComponent, target: Entity) -> void:
	for a: Melee in melee_c.list:
		if not can_attack(a, target):
			continue
			
		_do_attack(e, a, melee_c, target)


func _do_attack(e: Entity, a: Melee, _melee_c: MeleeComponent, blocked: Entity) -> void:
	e.play_animation(a.animation)
	await e.y_wait(a.delay)
	
	EntityDB.create_damage(
		blocked.id, a.min_damage, a.max_damage, a.damage_type, e.id
	)
	EntityDB.create_mods(blocked.id, a.mods, e.id)
	a.ts = TimeDB.tick_ts
