extends System
class_name BulletSystem
## 子弹系统
##
## 处理拥有 [BulletComponent] 子弹组件的实体的飞行轨迹、命中检测和伤害计算等相关逻辑。


func _on_insert(e: Entity) -> bool:
	var bullet_c: BulletComponent = e.get_node_or_null(C.CN_BULLET)
	if not bullet_c:
		return true

	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		return false

	bullet_c.ts = TimeMgr.tick_ts
	if not bullet_c.disabled_predict_pos:
		var predict_time: float = bullet_c.trajectory._get_predict_time() if bullet_c.trajectory else 0.0
		bullet_c.predict_target_pos = PathwayMgr.predict_target_pos(
			target, predict_time
		)
	else:
		bullet_c.predict_target_pos = target.global_position
	
	var to: Vector2 = bullet_c.predict_target_pos
	if target.hit_offsets:
		var hit_offset: Vector2 = target.hit_offsets.get_offset_for_point(
			target.global_position, target.look_point
		)
		to += hit_offset
	bullet_c.to = to
	bullet_c.from = e.global_position
	if bullet_c.look_to:
		e.look_at(to)

	if bullet_c.trajectory:
		bullet_c.trajectory._init_trajectory(bullet_c, e, target)

	return true


func _on_update(delta: float) -> void:
	var entity_list: Array = EntityMgr.get_entities_group(C.CN_BULLET).filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and not e.state & C.State.REMOVED
	)

	for e: Entity in entity_list:
		var bullet_c: BulletComponent = e.get_node_or_null(C.CN_BULLET)
		if not bullet_c or not bullet_c.trajectory:
			continue
			
		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		var flying_time: float = TimeMgr.get_time_by_ts(bullet_c.ts)

		bullet_c.trajectory._update_trajectory(e, bullet_c, target, flying_time, delta)
		
		if bullet_c.flight_animation:
			e.play_animation_by_look(bullet_c.flight_animation)
		e.rotation += bullet_c.rotation_speed * delta

		# 未击中处理
		if (
			bullet_c.trajectory._should_miss(bullet_c, flying_time)
			or not target
			and U.is_at_destination(
				e.global_position, bullet_c.to, bullet_c.hit_distance
			)
		):
			_miss(e, bullet_c)
		else:
			if not bullet_c.can_arrived:
				continue
			
			if not bullet_c.trajectory._has_arrived(e, bullet_c, flying_time):
				continue
				
			_hit(e, bullet_c, target)

		
func _miss(e: Entity, bullet_c: BulletComponent) -> void:
	e._on_bullet_miss(bullet_c)
	
	AudioMgr.play_sfx(bullet_c.miss_sfx)
	if bullet_c.miss_animation:
		e.play_animation_by_look(bullet_c.miss_animation)
		await e.wait_animation(bullet_c.miss_animation)

	if bullet_c.damage_area_enable:
		var targets: Array[Entity] = _get_area_targets(e, bullet_c)
		_take_damage(e, bullet_c, targets, bullet_c.miss_payloads)

	if bullet_c.miss_remove:
		e.remove_entity()
				
		
func _hit(e: Entity, bullet_c: BulletComponent, target) -> void:
	AudioMgr.play_sfx(bullet_c.hit_sfx)
	if bullet_c.hit_animation:
		e.play_animation_by_look(bullet_c.hit_animation)
		await e.y_wait(bullet_c.hit_delay)
		
	var targets: Array[Entity] = [null]
	if bullet_c.damage_area_enable:
		targets = _get_area_targets(e, bullet_c)
	else:
		targets[0] = target

	_take_damage(e, bullet_c, targets, bullet_c.hit_payloads)
	e._on_bullet_hit(target, bullet_c)
	
	if bullet_c.hit_animation:
		e.wait_animation(bullet_c.hit_animation)
		await e.wait_animation(bullet_c.hit_animation)

	if bullet_c.hit_remove:
		e.remove_entity()
		

func _get_area_targets(
		e: Entity, 
		bullet_c: BulletComponent
	) -> Array[Entity]:
	var e_global_pos: Vector2 = e.global_position
	var search_pos: Vector2 = e_global_pos

	if bullet_c.damage_offsets:
		var damage_offset: Vector2 = bullet_c.damage_offsets.get_offset_for_point(
			e_global_pos, e_global_pos + bullet_c.velocity
		)
		search_pos += damage_offset

	return EntityMgr.search_targets(
		bullet_c.damage_search_mode, 
		search_pos, 
		bullet_c.damage_max_radius, 
		bullet_c.damage_min_radius, 
		e.flags, 
		e.bans,
		func(t: Entity) -> bool:
			return bullet_c.can_damage_same or t.id not in bullet_c.damaged_entity_ids
	)


func _take_damage(
		e: Entity, 
		bullet_c: BulletComponent, 
		targets: Array[Entity], 
		payloads: PackedStringArray
		) -> void:
	var damage_max_count: int = bullet_c.damage_max_count
	var e_id: int = e.id
		
	for i: int in targets.size():
		if U.is_valid_number(damage_max_count) and i > damage_max_count:
			break
			
		var t: Entity = targets[i]
		var t_id: int = t.id
		
		var d := Damage.new()
		d.target_id = t.id
		d.source_id = e_id
		d.source_name = e.name
		d.value = d.get_random_value(bullet_c.damage_min, bullet_c.damage_max)
		d.damage_type = bullet_c.damage_type
		d.damage_flags = bullet_c.damage_flags
		if bullet_c.damage_area_enable and bullet_c.damage_falloff_enabled:
			d.damage_factor = U.dist_factor_inside_radius(
				e.global_position, 
				t.global_position, 
				bullet_c.damage_max_radius,
				bullet_c.damage_min_radius
			)
		d.insert_damage()
		EntityMgr.create_mods(t.id, bullet_c.mods, e_id)
		
		bullet_c.damaged_entity_ids.append(t_id)
		
	EntityMgr.create_entities_at_pos(payloads, bullet_c.to)
