extends Behavior
class_name BlockerMeleeBehavior

## 近战行为系统
##
## 处理拥有 [MeleeComponent] 近战攻击组件的被拦截者实体（见 [annotation MeleeComponent.is_blocker]）
## 的攻击与拦截，寻找与标记被拦截者状态，仅前往第一个被拦截者的近战位置


func _on_remove(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c or not melee_c.is_blocker:
		return true
	
	erase_blocker_from_blockeds(e.id, melee_c)

	return true


func _on_return_true(e: Entity, break_behavior: Behavior) -> void:
	if break_behavior == self:
		return

	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c or not melee_c.is_blocker:
		return
		
	erase_blocker_from_blockeds(e.id, melee_c)
	
	if not melee_c.blockeds_ids.is_empty():
		melee_c.blockeds_ids.clear()
		melee_c.need_origin_setup = true
		melee_c.blocked_count = 0

func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c:
		return false
	
	if not melee_c.is_blocker:
		return false
		
	# 超过最大拦截数量不进行索敌
	if melee_c.blocked_count < melee_c.max_blocked:
		var pending_blockeds: Array = _find_pending_blocked(
			e, melee_c
		)
		
		_process_pending_blockeds(e, melee_c, pending_blockeds)

		if pending_blockeds:
			# 计算被拦截者数量（考虑代价）
			melee_c.reset_blocked_count()
	
	var blockeds_ids: Array = melee_c.blockeds_ids
	# 没有被拦截者
	if not blockeds_ids:
		## need_origin_setup 默认为 true
		if not melee_c.need_origin_setup:
			melee_c.need_origin_setup = true
			melee_c.origin_pos_arrived = false
		else:
			melee_c.melee_pos_arrived = true
		
		if not back_origin_pos(e, melee_c):
			return true
		
		e.state = C.State.IDLE
		return false
		
	# 有被拦截者
	e.state = C.State.MELEE
	var blocked: Entity = EntityMgr.get_entity_by_id(
		blockeds_ids[0]
	)
	if not blocked:
		return false
	
	var blocked_melee_c: MeleeComponent = blocked.get_c(
		C.CN_MELEE
	)
	
	if melee_c.need_origin_setup:
		melee_c.need_origin_setup = false
		melee_c.melee_pos_arrived = false
		melee_c.origin_pos = e.global_position
	
	# 非被动拦截者前往近战位置
	if not melee_c.is_passive:
		melee_c.melee_pos = (
			blocked.global_position 
			+ blocked_melee_c.melee_pos_offset
		)
		if not go_melee_pos(e, melee_c):
			return true

	try_melee_attack(e, melee_c, blocked)
	return true


## 寻找待定被拦截者
func _find_pending_blocked(e: Entity, melee_c: MeleeComponent) -> Array:
	var filter: Callable = func(entity: Entity) -> bool: return (
		entity.has_c(C.CN_MELEE) and entity.id not in melee_c.blockeds_ids
	)
	
	var targets: Array = EntityMgr.search_targets_in_range(
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
		t_melee_c.blockers_ids.push_front(e.id)
		melee_c.blockeds_ids.push_front(t.id)
