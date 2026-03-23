extends Behavior
class_name BlockedMeleeBehavior
## 近战行为系统
##
## 处理拥有 [MeleeComponent] 近战攻击组件的被拦截者实体（见 [annotation MeleeComponent.is_blocker]）
## 的攻击与拦截，如果是被第一个拦截，原地等待拦截者到达自身近战位置，
## 反之前往拦截者的近战位置


func _on_remove(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c or melee_c.is_blocker:
		return true
	
	erase_blocked_from_blockers(e.id, melee_c)

	return true


func _on_return_true(e: Entity, break_behavior: Behavior) -> void:
	if break_behavior == self:
		return

	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c or melee_c.is_blocker:
		return
	
	erase_blocked_from_blockers(e.id, melee_c)
	melee_c.blockers_ids.clear()


func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if not melee_c:
		return false
	
	if melee_c.is_blocker:
		return false

	var blockers_ids: Array[int] = melee_c.blockers_ids
	
	if blockers_ids.is_empty():
		## need_origin_setup 默认为 true
		if not melee_c.need_origin_setup:
			melee_c.need_origin_setup = true
			melee_c.melee_pos_arrived = true
			melee_c.origin_pos_arrived = false
		
		if not back_origin_pos(e, melee_c):
			return true
		
		e.state = C.State.IDLE
		return false
	
	e.state = C.State.MELEE
	var blocker: Entity = EntityDB.get_entity_by_id(blockers_ids[0])
	var blocker_melee_c: MeleeComponent = blocker.get_c(C.CN_MELEE)
	var is_first_blocked: bool = e.id == blocker_melee_c.blockeds_ids[0]
	
	# 不是被第一个拦截且非被动拦截者前往近战位置，否则等待拦截者到达近战位置
	if (
			not is_first_blocked 
			and not melee_c.is_passive
		):
		if (
			not blocker_melee_c.melee_pos_arrived
		):
			e.play_idle_animation()
			return true

		if melee_c.need_origin_setup:
			melee_c.need_origin_setup = false
			melee_c.melee_pos_arrived = false
			melee_c.origin_pos = e.global_position
			
		melee_c.melee_pos = (
			blocker.global_position 
			+ blocker_melee_c.melee_pos_offset
		)
		if not go_melee_pos(e, melee_c):
			return true

	if (
			not is_first_blocked and not melee_c.melee_pos_arrived
			or is_first_blocked and not blocker_melee_c.melee_pos_arrived
		):
		e.play_idle_animation()
		return true
	
	try_melee_attack(e, melee_c, blocker)
	return true
