extends Behavior
class_name MeleeBehavior
## 近战行为系统
##
## 处理拥有 [MeleeComponent] 组件的实体的攻击与拦截。
## 若 [member MeleeComponent.is_blocker] 为 `true`，作为拦截者：搜索并标记被拦截者，前往第一个被拦截者的近战位置。
## 若 [member MeleeComponent.is_blocked] 为 `true`，作为被拦截者：根据是否第一个被拦截者决定等待拦截者到达，或主动前往拦截者的近战位置。


func _on_remove(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return true
	
	melee_c.cleanup_melee_relations(e)
	melee_c.unbind_melee_relations(e.id)
	
	return true


func _on_skip(e: Entity) -> void:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return
	
	melee_c.unbind_melee_relations(e.id)
	if melee_c.is_blocker:
		melee_c.blocked_ids.clear()
		melee_c.blocked_count = 0
		melee_c.melee_state = C.MeleeState.ORIGIN_POS_ARRIVED
	elif melee_c.is_blocked:
		melee_c.blocker_ids.clear()
		
	if e.state & C.State.IDLE:
		melee_c.origin_pos = e.global_position


func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return false
		
	melee_c.cleanup_melee_relations(e)
	
	if melee_c.is_blocker:
		return _update_blocker(e, melee_c)
	elif melee_c.is_blocked:
		return _update_blocked(e, melee_c)
		
	return false


func _update_blocker(e: Entity, melee_c: MeleeComponent) -> bool:
	if not melee_c.blocked_ids:
		melee_c.is_extra_blocker = false
	
	# 索敌
	var center: Vector2 = e.global_position
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if rally_c:
		var rally_center_position: Vector2 = rally_c.rally_center_position
		
		if rally_center_position != Vector2.ZERO:
			center = rally_center_position
	
	var pending_blockeds: Array[Entity] = EntityMgr.search_targets(
		melee_c.search_mode,
		center,
		melee_c.block_max_range,
		melee_c.block_min_range,
		melee_c.block_flags,
		melee_c.block_bans,
		func(t: Entity) -> bool:
			var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)
			if not t_melee_c:
				return false
			return not t_melee_c.blocker_ids
	)
	
	if pending_blockeds:
		if melee_c.blocked_ids and melee_c.is_extra_blocker:
			var first_blocked_id: int = melee_c.blocked_ids[0]
			var first_blocked_target: Entity = EntityMgr.get_entity_by_id(first_blocked_id)
			var blocked_melee_c: MeleeComponent = first_blocked_target.get_node_or_null(C.CN_MELEE)
			if blocked_melee_c.blocker_ids.size() > 1:
				melee_c.blocked_count = 0
				melee_c.unbind_melee_relations(e.id)
		
		var max_blocked: int = melee_c.max_blocked
		for t: Entity in pending_blockeds:
			if melee_c.blocked_count >= max_blocked:
				break
			
			melee_c.bind_melee_relations(t, e)
	else:
		if not melee_c.blocked_ids:
			var blocked_targets: Array[Entity] = EntityMgr.search_targets(
				melee_c.search_mode,
				center,
				melee_c.block_max_range,
				melee_c.block_min_range,
				melee_c.block_flags,
				melee_c.block_bans,
				func(t: Entity) -> bool:
				var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)
				if not t_melee_c:
					return false
					
				return true
			)
			var first_blocked_target: Entity = blocked_targets[0] if blocked_targets else null
			if first_blocked_target and not melee_c.is_extra_blocker:
				melee_c.bind_melee_relations(first_blocked_target, e)
				melee_c.is_extra_blocker = true
	
	var blocked_ids: Array = melee_c.blocked_ids
	if not blocked_ids:
		match melee_c.melee_state:
			C.MeleeState.ORIGIN_POS_ARRIVED:
				melee_c.origin_pos = e.global_position
			_:
				if not _back_origin_pos(e, melee_c):
					return true
		
		return false
	else:
		e.state = C.State.MELEE
		var blocked: Entity = EntityMgr.get_entity_by_id(blocked_ids[0])
		var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
		
		# 不是被动被拦截者，前往近战位置
		if not melee_c.is_passive:
			var melee_pos: Vector2 = blocked.global_position
			if e.global_position.x < melee_pos.x:
				melee_pos -= blocked_melee_c.melee_pos_offset
			else:
				melee_pos += blocked_melee_c.melee_pos_offset
			
			melee_c.melee_pos = melee_pos
			if not _go_melee_pos(e, melee_c, melee_pos):
				return true
		
		_try_melee_attack(e, melee_c, blocked)
		return true


func _update_blocked(e: Entity, melee_c: MeleeComponent) -> bool:
	var blocker_ids: PackedInt32Array = melee_c.blocker_ids
	if not blocker_ids:
		match melee_c.melee_state:
			C.MeleeState.ORIGIN_POS_ARRIVED:
				melee_c.origin_pos = e.global_position
			_:
				if not _back_origin_pos(e, melee_c):
					return true
		
		return false
	else:
		e.state = C.State.MELEE
		var blocker: Entity = EntityMgr.get_entity_by_id(blocker_ids[0])
		var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(C.CN_MELEE)
		var is_first_blocked: bool = e.id == blocker_melee_c.blocked_ids[0]

		if is_first_blocked:
			if blocker_melee_c.melee_state != C.MeleeState.MELEE_POS_ARRIVED:
				e.look_point = blocker.global_position
				e.play_animation_by_look(e.idle_animation)
				return true
		else:
			if not melee_c.is_passive:
				var melee_pos: Vector2 = blocker.global_position
				if e.global_position.x < melee_pos.x:
					melee_pos -= blocker_melee_c.melee_pos_offset
				else:
					melee_pos += blocker_melee_c.melee_pos_offset
				
				melee_c.melee_pos = melee_pos
				if not _go_melee_pos(e, melee_c, melee_pos):
					return true
		
		_try_melee_attack(e, melee_c, blocker)
		return true
	
	
func _go_melee_pos(e: Entity, melee_c: MeleeComponent, melee_pos: Vector2) -> bool:
	if U.is_at_destination(
			e.global_position, melee_pos, melee_c.arrived_distance	 
	):
		#Log.verbose("Arrived! Pos: %s, Target: %s, Dist: %s" % [e.global_position, melee_c.melee_pos, e.global_position.distance_to(melee_c.melee_pos)])
		melee_c.melee_state = C.MeleeState.MELEE_POS_ARRIVED
		return true
	else:
		#Log.verbose("Moving to %s, current %s, velocity %s" % [melee_c.melee_pos, e.global_position, melee_c.velocity])
		melee_c.melee_state = C.MeleeState.MELEE_POS_MOVING
		var direction: Vector2 = e.global_position.direction_to(melee_pos)
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
		melee_c.melee_state = C.MeleeState.ORIGIN_POS_ARRIVED
		e.state = C.State.IDLE
		return true
	else:
		melee_c.melee_state = C.MeleeState.ORIGIN_POS_MOVING
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
	

func _try_melee_attack(
		e: Entity, melee_c: MeleeComponent, target: Entity
	) -> void:
	if U.is_valid_entity(target):
		e.look_point = target.global_position
	e.play_animation_by_look(e.idle_animation)
	
	for a: MeleeAttack in melee_c.get_children():
		if not TimeMgr.is_ready_time(a.ts, a.cooldown):
			continue

		if not can_attack(a, target):
			continue
			
		Log.verbose("近战攻击: %s" % e)

		a.ts = TimeMgr.tick_ts
		e.play_animation_by_look(a.animation, "melee")
		await e.y_wait(a.delay)
			
		var targets: Array[Entity] = [null]
			
		if a.damage_area_enable:
			targets = EntityMgr.search_targets(
				a.damage_search_mode, 
				e.global_position + a.damage_offset, 
				a.damage_max_radius, 
				a.damage_min_radius, 
				e.flags, 
				e.bans
			)
		else:
			if not U.is_valid_entity(target):
				break
				
			targets[0] = target

		var damage_max_count: int = a.damage_max_count
		var e_id: int = e.id
		
		for i: int in targets.size():
			if U.is_valid_number(damage_max_count) and i > damage_max_count:
				break
				
			var t: Entity = targets[i]
			if not U.is_valid_entity(t):
				continue
			
			var t_id: int = t.id
			
			var d := Damage.new()
			d.target_id = t_id
			d.source_id = e_id
			d.source_name = e.name
			d.value = d.get_random_value(a.damage_min, a.damage_max)
			d.damage_type = a.damage_type
			d.damage_flags = a.damage_flags
			if a.damage_area_enable and a.damage_falloff_enabled:
				d.damage_factor = U.dist_factor_inside_radius(
					e.global_position, 
					t.global_position, 
					a.damage_max_radius,
					a.damage_min_radius
				)
			d.insert_damage()

			EntityMgr.create_mods(t_id, a.mods, e_id)
		
		await e.wait_animation(a.animation)
		e.play_animation_by_look(e.idle_animation)
		break
