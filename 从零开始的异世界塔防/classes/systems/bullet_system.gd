extends System
class_name BulletSystem
## 子弹系统
##
## 处理拥有 [BulletComponent] 子弹组件的实体的飞行轨迹、命中检测和伤害计算等相关逻辑。


func _on_insert(e: Entity) -> bool:
	var bullet_c: BulletComponent = e.get_c(C.CN_BULLET)
	if not bullet_c:
		return true

	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		return false

	bullet_c.ts = TimeMgr.tick_ts
	var flying_time: float = TimeMgr.get_time_by_ts(bullet_c.ts)
	if not bullet_c.disabled_predict_pos:
		bullet_c.predict_target_pos = PathwayMgr.predict_target_pos(
			target, bullet_c.flight_time
		)
	else:
		bullet_c.predict_target_pos = target.global_position
	
	bullet_c.to = bullet_c.predict_target_pos + target.hit_offset
	bullet_c.from = e.global_position
	e.look_at(bullet_c.to)

	bullet_c.rotation_direction = -1 if bullet_c.to.x < e.global_position.x else 1

	if bullet_c.flight_trajectory & C.Trajectory.LINEAR:
		_trajectory_liniear_init(bullet_c)
	elif bullet_c.flight_trajectory & C.Trajectory.PARABOLA:
		_trajectory_parabola_init(e, bullet_c, flying_time)
	elif bullet_c.flight_trajectory & C.Trajectory.TRACKING:
		_trajectory_tracking_init(e, bullet_c)
	elif bullet_c.flight_trajectory & C.Trajectory.INSTANT:
		_trajectory_instant_init(e, target)

	return true


func _on_update(delta: float) -> void:
	var entity_list: Array = EntityMgr.get_entities_group(C.CN_BULLET).filter(
		func(e: Entity):
			return not e.is_waiting() and not e.removed
	)

	for e: Entity in entity_list:
		var bullet_c: BulletComponent = e.get_c(C.CN_BULLET)

		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		var flying_time: float = TimeMgr.get_time_by_ts(bullet_c.ts)

		if bullet_c.flight_trajectory & C.Trajectory.LINEAR:
			_trajectory_liniear_update(e, bullet_c)
		elif bullet_c.flight_trajectory & C.Trajectory.PARABOLA:
			_trajectory_parabola_update(e, bullet_c, flying_time)
		elif bullet_c.flight_trajectory & C.Trajectory.TRACKING:
			_trajectory_tracking_update(e, bullet_c, target)
		
		if bullet_c.flight_animation:
			e.mixed_play_animation_by_look(bullet_c.flight_animation)
		e.rotation += bullet_c.rotation_speed * delta
		
		# 未击中处理
		if (
				flying_time >= bullet_c.flight_time 
				or not target 
				and U.is_at_destination(
					e.global_position, bullet_c.to, bullet_c.hit_distance
				)
			):
			e._on_bullet_miss(bullet_c)
			if bullet_c.miss_animation:
				e.mixed_play_animation_by_look(bullet_c.miss_animation)
				AudioMgr.play_sfx(bullet_c.miss_sfx)
				await e.mixed_wait_animation(bullet_c.miss_animation)

			EntityMgr.create_entities_at_pos(bullet_c.miss_payloads, bullet_c.to)

			if bullet_c.miss_remove:
				e.remove_entity()
				
			continue
			
		if not bullet_c.can_arrived:
			continue
		
		# 击中处理
		if not U.is_at_destination(
				e.global_position, bullet_c.to, bullet_c.hit_distance
			):
			continue

		if bullet_c.hit_animation:
			e.mixed_play_animation_by_look(bullet_c.hit_animation)
			AudioMgr.play_sfx(bullet_c.hit_sfx)
			await e.y_wait(bullet_c.hit_delay)

		var targets: Array = [target]
			
		if bullet_c.damage_min_radius > 0 or bullet_c.damage_max_radius > 0:
			targets = EntityMgr.search_targets_in_range(
				bullet_c.search_mode, 
				bullet_c.to, 
				bullet_c.damage_max_radius, 
				bullet_c.damage_min_radius, 
				e.flag_bits, 
				e.ban_bits
			)
		
		for t in targets:
			var d := Damage.new()
			d.target_id = target.id
			d.source_id = e.id
			d.value = d.get_random_value(bullet_c.damage_min, bullet_c.damage_max)
			d.damage_type = bullet_c.damage_type
			d.damage_flags = bullet_c.damage_flag_bits
			d.damage_factor = e._on_bullet_calculate_damage_factor(
				target, bullet_c
			)
			d.insert_damage()
			EntityMgr.create_mods(target.id, bullet_c.mods, e.id)
			
		EntityMgr.create_entities_at_pos(bullet_c.hit_payloads, bullet_c.to)

		e._on_bullet_hit(target, bullet_c)
		
		if bullet_c.hit_animation:
			e.mixed_wait_animation(bullet_c.hit_animation)

		if bullet_c.hit_remove:
			e.remove_entity()
		

#region 轨迹相关函数
## 直线轨迹初始化
func _trajectory_liniear_init(bullet_c: BulletComponent) -> void:
	bullet_c.velocity = U.initial_linear_velocity(
		bullet_c.from, bullet_c.to, bullet_c.flight_time
	)


## 直线轨迹更新
func _trajectory_liniear_update(e: Entity, bullet_c: BulletComponent) -> void:
	e.global_position = U.position_in_linear(
		bullet_c.velocity, bullet_c.from, TimeMgr.get_time_by_ts(bullet_c.ts)
	)


## 抛物线轨迹初始化
func _trajectory_parabola_init(
		e: Entity, bullet_c: BulletComponent, flying_time: float
	) -> void:
	bullet_c.velocity = U.initial_parabola_velocity(
		e.global_position, bullet_c.to, bullet_c.flight_time, bullet_c.flight_gravity
	)
	
	var next_time: float = flying_time + TimeMgr.frame_length
	var next_pos = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, bullet_c.flight_gravity
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
