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
		bullet_c.predict_target_pos = PathwayMgr.predict_target_pos(
			target, bullet_c.flight_total_time
		)
	else:
		bullet_c.predict_target_pos = target.global_position
	
	var to: Vector2 = bullet_c.predict_target_pos + target.hit_offset
	bullet_c.to = to
	bullet_c.from = e.global_position
	if bullet_c.look_to:
		e.look_at(to)

	bullet_c.rotation_direction = -1 if to.x < e.global_position.x else 1

	match bullet_c.flight_trajectory:
		C.Trajectory.LINEAR:
			_trajectory_liniear_init(bullet_c)
		C.Trajectory.PARABOLA:
			_trajectory_parabola_init(e, bullet_c)
		C.Trajectory.TRACKING:
			_trajectory_tracking_init(e, bullet_c)
		C.Trajectory.INSTANT:
			_trajectory_instant_init(e, target)

	return true


func _on_update(delta: float) -> void:
	var entity_list: Array = EntityMgr.get_entities_group(C.CN_BULLET).filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and not e.state & C.State.REMOVED
	)

	for e: Entity in entity_list:
		var bullet_c: BulletComponent = e.get_node_or_null(C.CN_BULLET)
		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		var flying_time: float = TimeMgr.get_time_by_ts(bullet_c.ts)

		match bullet_c.flight_trajectory:
			C.Trajectory.LINEAR:
				_trajectory_liniear_update(e, bullet_c)
			C.Trajectory.PARABOLA:
				_trajectory_parabola_update(e, bullet_c, flying_time)
			C.Trajectory.TRACKING:
				_trajectory_tracking_update(e, bullet_c, target)
		
		if bullet_c.flight_animation:
			e.play_animation_by_look(bullet_c.flight_animation)
		e.rotation += bullet_c.rotation_speed * delta

		var flight_total_time: float = bullet_c.flight_total_time 
		
		# 未击中处理
		if (
				flight_total_time > 0 and flying_time >= flight_total_time 
				or not target 
				and U.is_at_destination(
					e.global_position, bullet_c.to, bullet_c.hit_distance
				)
			):
			_miss(e, bullet_c)
		else:
			if not bullet_c.can_arrived:
				continue
			
			match bullet_c.flight_trajectory:
				C.Trajectory.PARABOLA:
					if flying_time <= flight_total_time * 0.8:
						continue
			
			if not U.is_at_destination(
					e.global_position, bullet_c.to, bullet_c.hit_distance
				):
				continue
				
			_hit(e, bullet_c, target)

		
func _miss(e: Entity, bullet_c: BulletComponent) -> void:
	e._on_bullet_miss(bullet_c)
	if bullet_c.miss_animation:
		e.play_animation_by_look(bullet_c.miss_animation)
		AudioMgr.play_sfx(bullet_c.miss_sfx)
		await e.wait_animation(bullet_c.miss_animation)

	if bullet_c.damage_area_enable:
		var targets: Array[Entity] = [null]
		targets = EntityMgr.search_targets(
			bullet_c.damage_search_mode, 
			bullet_c.to + bullet_c.damage_offset, 
			bullet_c.damage_max_radius, 
			bullet_c.damage_min_radius, 
			e.flags, 
			e.bans,
			func(t: Entity) -> bool:
				return bullet_c.can_damage_same or t.id not in bullet_c.damaged_entity_ids
		)

		_take_damage(e, bullet_c, targets, bullet_c.miss_payloads)

	if bullet_c.miss_remove:
		e.remove_entity()
				
		
func _hit(e: Entity, bullet_c: BulletComponent, target) -> void:
	if bullet_c.hit_animation:
		e.play_animation_by_look(bullet_c.hit_animation)
		AudioMgr.play_sfx(bullet_c.hit_sfx)
		await e.y_wait(bullet_c.hit_delay)
		
	var targets: Array[Entity] = [null]
	if bullet_c.damage_area_enable:
		targets = EntityMgr.search_targets(
			bullet_c.damage_search_mode, 
			bullet_c.to + bullet_c.damage_offset, 
			bullet_c.damage_max_radius, 
			bullet_c.damage_min_radius, 
			e.flags, 
			e.bans,
			func(t: Entity) -> bool:
				return bullet_c.can_damage_same or t.id not in bullet_c.damaged_entity_ids
		)
	else:
		targets[0] = target

	_take_damage(e, bullet_c, targets, bullet_c.hit_payloads)
	e._on_bullet_hit(target, bullet_c)
	
	if bullet_c.hit_animation:
		e.wait_animation(bullet_c.hit_animation)
		await e.wait_animation(bullet_c.hit_animation)

	if bullet_c.hit_remove:
		e.remove_entity()
		

func _take_damage(
		e: Entity, 
		bullet_c: BulletComponent, 
		targets: Array[Entity], 
		payloads: Array[String]
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


#region 轨迹相关函数
## 直线轨迹初始化
func _trajectory_liniear_init(bullet_c: BulletComponent) -> void:
	bullet_c.velocity = U.initial_linear_velocity(
		bullet_c.from, bullet_c.to, bullet_c.flight_total_time
	)


## 直线轨迹更新
func _trajectory_liniear_update(e: Entity, bullet_c: BulletComponent) -> void:
	e.global_position = U.position_in_linear(
		bullet_c.velocity, bullet_c.from, TimeMgr.get_time_by_ts(bullet_c.ts)
	)


## 抛物线轨迹初始化
func _trajectory_parabola_init(
		e: Entity, bullet_c: BulletComponent
	) -> void:
	var from: Vector2 = bullet_c.from
	var to: Vector2 = bullet_c.to
	
	var velocity: Vector2 = U.initial_parabola_velocity(
		from, to, bullet_c.flight_total_time, bullet_c.flight_gravity
	)
	bullet_c.velocity = velocity
	
	var next_pos = U.position_in_parabola(
		velocity, from, 0.1, bullet_c.flight_gravity
	)
	
	if bullet_c.look_to:
		e.look_at(next_pos)
	

## 抛物线轨迹更新
func _trajectory_parabola_update(
		e: Entity, bullet_c: BulletComponent, flying_time: float
	) -> void:
	var current_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, flying_time, bullet_c.flight_gravity
	)
	
	var next_time: float = flying_time + TimeMgr.frame_length
	var next_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, bullet_c.flight_gravity
	)
	
	e.global_position = current_pos
	
	if bullet_c.look_to:
		e.look_at(next_pos)


## 追踪轨迹初始化
func _trajectory_tracking_init(
		e: Entity, bullet_c: BulletComponent
	) -> void:
	if bullet_c.look_to:
		e.look_at(bullet_c.to)


## 追踪轨迹更新
func _trajectory_tracking_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	if is_instance_valid(target):
		bullet_c.to = target.global_position + target.hit_offset
	
	var direction: Vector2 = e.global_position.direction_to(bullet_c.to)
	e.global_position += direction * bullet_c.flight_speed * TimeMgr.frame_length
	
	if bullet_c.look_to:
		e.look_at(bullet_c.to)


## 瞬移轨迹初始化
func _trajectory_instant_init(e: Entity, target: Entity) -> void:
	e.global_position = target.global_position
	
	e.rotation = deg_to_rad(90)
#endregion
