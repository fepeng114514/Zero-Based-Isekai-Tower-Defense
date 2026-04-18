extends Behavior
class_name MeleeBehavior

## 近战行为系统
##
## 处理拥有 [MeleeComponent] 组件的实体的攻击与拦截。
## - 若 [member MeleeComponent.is_blocker] 为 `true`，作为拦截者：搜索并标记被拦截者，前往第一个被拦截者的近战位置。
## - 若 [member MeleeComponent.is_blocker] 为 `false`，作为被拦截者：根据是否第一个被拦截者决定等待拦截者到达，或主动前往拦截者的近战位置。

func _on_remove(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_child_node(C.CN_MELEE)
	if not melee_c:
		return true
	
	melee_c.unbind_melee_relations(e.id)
	
	return true


func _on_return_true(e: Entity, break_behavior: Behavior) -> void:
	if break_behavior == self:
		return
	
	var melee_c: MeleeComponent = e.get_child_node(C.CN_MELEE)
	if not melee_c:
		return
	
	melee_c.unbind_melee_relations(e.id)
	if melee_c.is_blocker:
		melee_c.blockeds_ids.clear()
		melee_c.blocked_count = 0
		melee_c.melee_state = C.MeleeState.IDLE
	else:
		melee_c.blockers_ids.clear()


func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_child_node(C.CN_MELEE)
	if not melee_c:
		return false
		
	melee_c.cleanup_melee_relations()
	
	if melee_c.is_blocker:
		return _update_blocker(e, melee_c)
	else:
		return _update_blocked(e, melee_c)


func _update_blocker(e: Entity, melee_c: MeleeComponent) -> bool:
	var max_blocked: int = melee_c.max_blocked

	# 不超过最大拦截数量时索敌
	if melee_c.blocked_count < max_blocked:
		var pending_blockeds: Array[Entity] = EntityMgr.search_targets(
			melee_c.search_mode,
			e.global_position,
			melee_c.block_max_range,
			melee_c.block_min_range,
			melee_c.block_flags,
			melee_c.block_bans
		)
		
		if pending_blockeds:
			var new_blockeds_ids: Array[int] = []
			
			for t: Entity in pending_blockeds:
				if melee_c.blocked_count >= max_blocked:
					break
				
				var t_melee_c: MeleeComponent = t.get_child_node(C.CN_MELEE)
				if not t_melee_c:
					continue
				
				t_melee_c.blockers_ids.append(e.id)
				new_blockeds_ids.append(t.id)
				melee_c.blocked_count += t_melee_c.block_cost
				
			melee_c.blockeds_ids = new_blockeds_ids
	
	var blockeds_ids: Array = melee_c.blockeds_ids
	# 没有被拦截者
	if not blockeds_ids:
		match melee_c.melee_state:
			# 在原点
			C.MeleeState.IDLE:
				melee_c.origin_pos = e.global_position
			# 没有被拦截者，在近战位置，返回原点
			C.MeleeState.MELEE_POS_ARRIVED:
				if not _back_origin_pos(e, melee_c):
					return true
		
		return false
	
	# 有被拦截者
	e.state = C.State.MELEE
	var blocked: Entity = EntityMgr.get_entity_by_id(blockeds_ids[0])
	var blocked_melee_c: MeleeComponent = blocked.get_child_node(C.CN_MELEE)
	
	# 不是被动被拦截者，前往近战位置
	if not melee_c.is_passive:
		melee_c.melee_pos = blocked.global_position + blocked_melee_c.melee_pos_offset
		if not _go_melee_pos(e, melee_c):
			return true
	
	_try_melee_attack(e, melee_c, blocked)
	return true


func _update_blocked(e: Entity, melee_c: MeleeComponent) -> bool:
	var blockers_ids: Array[int] = melee_c.blockers_ids
	if not blockers_ids:
		match melee_c.melee_state:
			# 在原点
			C.MeleeState.IDLE:
				melee_c.origin_pos = e.global_position
			# 没有被拦截者，在近战位置，返回原点
			C.MeleeState.MELEE_POS_ARRIVED:
				if not _back_origin_pos(e, melee_c):
					return true
		
		return false
	
	e.state = C.State.MELEE
	var blocker: Entity = EntityMgr.get_entity_by_id(blockers_ids[0])
	var blocker_melee_c: MeleeComponent = blocker.get_child_node(C.CN_MELEE)
	var is_first_blocked: bool = e.id == blocker_melee_c.blockeds_ids[0]

	if is_first_blocked:
		if blocker_melee_c.melee_state != C.MeleeState.MELEE_POS_ARRIVED:
			e.play_animation_by_look(e.idle_animation)
			return true
	else:
		if melee_c.melee_state != C.MeleeState.MELEE_POS_ARRIVED:
			e.play_animation_by_look(e.idle_animation)
			return true

		if not melee_c.is_passive:
			melee_c.melee_pos = blocker.global_position + blocker_melee_c.melee_pos_offset
			if not _go_melee_pos(e, melee_c):
				return true
	
	_try_melee_attack(e, melee_c, blocker)
	return true
	
	
func _go_melee_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if U.is_at_destination(
			e.global_position, melee_c.melee_pos, melee_c.arrived_distance	 
	):
		melee_c.melee_state = C.MeleeState.MELEE_POS_ARRIVED
		return true
	
	melee_c.melee_state = C.MeleeState.MOVING_TO_POS
	var direction: Vector2 = e.global_position.direction_to(
		melee_c.melee_pos
	)
	var velocity: Vector2 = (
		direction 
		* melee_c.speed 
		* TimeMgr.frame_length
	)
	melee_c.velocity = velocity

	var next_position: Vector2 = e.global_position + velocity
	e.look_point = next_position
	e.play_animation_by_look(melee_c.motion_animation, "walk")

	e.global_position = next_position
	
	return false
	
	
func _back_origin_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if U.is_at_destination(
		e.global_position, melee_c.origin_pos, melee_c.arrived_distance
	):
		melee_c.melee_state = C.MeleeState.IDLE
		e.state = C.State.IDLE
		return true
	
	var direction: Vector2 = e.global_position.direction_to(
		melee_c.origin_pos
	)
	var velocity: Vector2 = (
		direction 
		* melee_c.speed 
		* TimeMgr.frame_length
	)
	melee_c.velocity = velocity

	var next_position: Vector2 = e.global_position + velocity
	e.look_point = next_position
	e.play_animation_by_look(melee_c.motion_animation, "walk")

	e.global_position = next_position
	
	return false
	

func _try_melee_attack(e: Entity, melee_c: MeleeComponent, target: Entity) -> void:
	for a: MeleeAttack in melee_c.list:
		if not TimeMgr.is_ready_time(a.ts, a.cooldown):
			continue

		if not can_attack(a, target):
			continue
			
		Log.verbose("近战攻击: %s" % e)

		e.look_point = target.global_position
		e.play_animation_by_look(a.animation, "melee")
		await e.y_wait(a.delay, func() -> bool:
			return not U.is_valid_entity(target)
		)
		a.ts = TimeMgr.tick_ts
			
		var targets: Array[Entity] = [null]

		var is_range_damage: bool = a.damage_max_radius > 0
			
		if is_range_damage:
			targets = EntityMgr.search_targets(
				a.damage_search_mode, 
				e.global_position + a.damage_offset, 
				a.damage_max_radius, 
				a.damage_min_radius, 
				e.flags, 
				e.bans,
				func(t: Entity) -> bool:
					return a.can_damage_same or t.id not in a.damaged_entity_ids
			)
		else:
			if not U.is_valid_entity(target):
				return
				
			targets[0] = target

		var damage_max_count: int = a.damage_max_count
		var e_id: int = e.id
		
		for i: int in targets.size():
			if U.is_valid_number(damage_max_count) and i > damage_max_count:
				break
				
			var t: Entity = targets[i]
			var t_id: int = t.id
			
			var d := Damage.new()
			d.target_id = t_id
			d.source_id = e_id
			d.source_name = e.name
			d.value = d.get_random_value(a.damage_min, a.damage_max)
			d.damage_type = a.damage_type
			d.damage_flags = a.damage_flags
			if is_range_damage and a.damage_falloff_enabled:
				d.damage_factor = U.dist_factor_inside_radius(
					e.global_position, 
					t.global_position, 
					a.damage_max_radius,
					a.damage_min_radius
				)
			d.insert_damage()

			EntityMgr.create_mods(t_id, a.mods, e_id)
			a.damaged_entity_ids.append(t_id)
		
		await e.wait_animation(a.animation)
		e.play_animation_by_look(e.idle_animation)
		break
