extends Behavior
class_name MeleeBehavior

"""近战系统:
	管理实体的近战攻击拦截
	对于拦截者: 寻找与标记被拦截者状态，仅前往拦截第一个被拦截者（前往被拦截者的近战位置）
	对于被拦截者: 如果是被第一个拦截，则原地等待拦截者到达自身近战位置，反之前往拦截者的近战位置
"""


func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c:
		return false
	
	if melee_c.is_blocker:
		return _process_blocker(e, melee_c)
	else:
		return _process_blocked(e, melee_c)
		

## 处理拦截者
func _process_blocker(e: Entity, melee_c: MeleeComponent) -> bool:
	# 清理与计算被拦截者数量（考虑代价）
	melee_c.cleanup_blockeds()
	melee_c.reset_blocked_count()
	
	# 超过最大拦截数量不进行索敌
	if melee_c.blocked_count < melee_c.max_blocked:
		var pending_blockeds: Array = _find_pending_blocked(
			e, melee_c
		)
		
		_process_pending_blockeds(e, melee_c, pending_blockeds)
	
	var blockeds_ids: Array = melee_c.blockeds_ids
	# 没有被拦截者
	if not blockeds_ids:
		if not melee_c.is_first_found_target:
			melee_c.is_first_found_target = true
			melee_c.origin_pos_arrived = false
		else:
			melee_c.reset_blocker()
		
		if not _back_origin_pos(e, melee_c):
			return true
		
		return false
		
	# 有被拦截者，前往近战位置，尝试攻击被拦截者
	var blocked: Entity = EntityDB.get_entity_by_id(
		blockeds_ids[0]
	)
		
	if melee_c.is_first_found_target:
		melee_c.is_first_found_target = false
		melee_c.melee_pos_arrived = false
		melee_c.origin_pos = e.global_position
	
	# 非被动拦截者前往近战位置
	if not melee_c.is_passive:
		var blocked_melee_c: MeleeComponent = blocked.get_c(
			C.CN_MELEE
		)
		melee_c.melee_pos = (
			blocked.global_position 
			+ blocked_melee_c.melee_pos_offset
		)
		if not _go_melee_pos(e, melee_c):
			return true
		
	_try_attack(e, melee_c, blocked)
	return true


## 寻找待定被拦截者
func _find_pending_blocked(e: Entity, melee_c: MeleeComponent) -> Array:
	var filter = func(entity) -> bool: return (
		entity.has_c(C.CN_MELEE) and not entity.id in melee_c.blockeds_ids
	)
	
	var targets: Array = EntityDB.search_targets_in_range(
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
		melee_c.reset_blocked_count()
		if melee_c.blocked_count >= melee_c.max_blocked:
			break
		
		var t_melee_c: MeleeComponent = t.get_c(C.CN_MELEE)
		t_melee_c.blocker_id = e.id
		melee_c.blockeds_ids.append(t.id)


## 处理被拦截者
func _process_blocked(e: Entity, melee_c: MeleeComponent) -> bool:
	melee_c.cleanup_blocker(e)
	var blocker_id: int = melee_c.blocker_id
	
	if not U.is_valid_number(blocker_id):
		if not melee_c.is_first_found_target:
			melee_c.is_first_found_target = true
			melee_c.origin_pos_arrived = false
		
		if not _back_origin_pos(e, melee_c):
			return true
		
		return false
	
	var blocker: Entity = EntityDB.get_entity_by_id(blocker_id)
	var blocker_melee_c: MeleeComponent = blocker.get_c(C.CN_MELEE)
	var is_first_blocked: bool = e.id == blocker_melee_c.blockeds_ids[0]
	
	# 不是被第一个拦截且非被动拦截者前往近战位置，否则等待拦截者到达近战位置
	if (
			not is_first_blocked 
			and not melee_c.is_passive
		):
		if melee_c.is_first_found_target:
			melee_c.is_first_found_target = false
			melee_c.melee_pos_arrived = false
			melee_c.origin_pos = e.global_position
			
		melee_c.melee_pos = (
			blocker.global_position 
			+ blocker_melee_c.melee_pos_offset
		)
		if not _go_melee_pos(e, melee_c):
			return true
	
	if (
			not is_first_blocked
			or not blocker_melee_c.melee_pos_arrived
		):
		e.play_animation(e.default_animation)
		return true
	
	_try_attack(e, melee_c, blocker)
	return true


func _go_melee_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if melee_c.melee_pos_arrived or U.is_at_destination(
			e.global_position, melee_c.melee_pos, melee_c.arrived_dist
	):
		melee_c.melee_pos_arrived = true
		return true
	
	var direction: Vector2 = e.global_position.direction_to(melee_c.melee_pos)

	e.global_position += (
		direction 
		* melee_c.speed 
		* TimeDB.frame_length
	)
	e.play_animation(melee_c.motion_animation)
	return false
	
func _back_origin_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if melee_c.origin_pos_arrived or U.is_at_destination(
		e.global_position, melee_c.origin_pos, melee_c.arrived_dist
	):
		melee_c.origin_pos_arrived = true
		return true
	
	var direction: Vector2 = e.global_position.direction_to(melee_c.origin_pos)
	
	e.global_position += (
		direction 
		* melee_c.speed 
		* TimeDB.frame_length
	)
	e.play_animation(melee_c.motion_animation)
	return false
	

func _try_attack(e: Entity, melee_c: MeleeComponent, target: Entity) -> void:
	for a: MeleeAttack in melee_c.list:
		if not can_attack(a, target):
			continue
			
		_do_attack(e, a, melee_c, target)
		break


func _do_attack(e: Entity, a: MeleeAttack, _melee_c: MeleeComponent, target: Entity) -> void:
	Log.verbose("近战攻击: %s" % e)
	e.play_animation(a.animation)
	await e.y_wait(a.delay)
	e.play_animation(e.default_animation)
	a.ts = TimeDB.tick_ts
	
	EntityDB.create_damage(
		target.id, a.min_damage, a.max_damage, a.damage_type, e.id
	)
	EntityDB.create_mods(target.id, a.mods, e.id)
