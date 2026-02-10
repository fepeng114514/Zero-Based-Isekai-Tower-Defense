extends System

"""子弹系统:
负责管理子弹实体的飞行轨迹、命中检测和伤害计算等相关逻辑。子弹系统会在每一帧更新子弹实体的位置，
并检测子弹是否命中目标或飞行到达目标位置。如果子弹命中目标，系统将计算伤害并应用状态效果，
同时触发相关事件回调。如果子弹飞行到达目标位置但未命中目标，系统将触发未命中事件回调。
"""

func _on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_BULLET):
		return true

	var bullet_c: BulletComponent = e.get_c(CS.CN_BULLET)
	var target: Entity = E.get_entity_by_id(e.target_id)
	if not U.is_vaild_entity(target):
		return false

	bullet_c.ts = TM.tick_ts
	if bullet_c.predict_pos_disabled:
		bullet_c.predict_target_pos = PathDB.predict_target_pos(
			target, bullet_c.flight_time * TM.fps
		)
	else:
		bullet_c.predict_target_pos = target.position
	
	bullet_c.to = bullet_c.predict_target_pos
	bullet_c.from = e.position
	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.look_at(bullet_c.to)

	bullet_c.rotation_direction = -1 if bullet_c.to.x < e.position.x else 1

	if bullet_c.flight_trajectory & CS.TRAJECTORY_LINEAR:
		trajectory_liniear_init(e, bullet_c, target)
	elif bullet_c.flight_trajectory & CS.TRAJECTORY_PARABOLA:
		trajectory_parabola_init(e, bullet_c, target)
	elif bullet_c.flight_trajectory & CS.TRAJECTORY_TRACKING:
		trajectory_tracking_init(e, bullet_c, target)
	#elif bullet_c.flight_trajectory & CS.TRAJECTORY_HOMING:
	#	trajectory_homing_init(e, bullet_c, target)
	elif bullet_c.flight_trajectory & CS.TRAJECTORY_INSTANT:
		trajectory_instant_init(e, bullet_c, target)

	return true

func _on_update(delta: float) -> void:
	for e: Entity in E.get_entities_group(CS.GROUP_BULLETS):
		var bullet_c: BulletComponent = e.get_c(CS.CN_BULLET)

		var target: Entity = E.get_entity_by_id(e.target_id)

		if bullet_c.flight_trajectory & CS.TRAJECTORY_LINEAR:
			trajectory_liniear_update(e, bullet_c, target)
		elif bullet_c.flight_trajectory & CS.TRAJECTORY_PARABOLA:
			trajectory_parabola_update(e, bullet_c, target)
		elif bullet_c.flight_trajectory & CS.TRAJECTORY_TRACKING:
			trajectory_tracking_update(e, bullet_c, target)
		# elif bullet_c.flight_trajectory & CS.TRAJECTORY_HOMING:
		# 	trajectory_homing_update(e, bullet_c, target)

		e.rotation += bullet_c.rotation_speed * delta
		
		if not bullet_c.can_arrived:
			continue
			
		if U.is_at_destination(e.position, target.position, bullet_c.hit_dist):
			hit(e, bullet_c, target)

		if (
			not U.is_vaild_entity(target)
			or U.is_at_destination(e.position, bullet_c.to, bullet_c.hit_dist)
		):
			e._on_bullet_miss(target, bullet_c)

			if bullet_c.miss_remove:
				e.remove_entity()

			continue
		
func hit(e: Entity, bullet_c: BulletComponent, target: Entity) -> void:
	if bullet_c.min_damage_radius > 0 or bullet_c.max_damage_radius > 0:
		var targets = E.search_targets_in_range(
			bullet_c.search_mode, 
			bullet_c.to, 
			bullet_c.min_damage_radius, 
			bullet_c.max_damage_radius, 
			e.flags,
			e.bans,
		)

		for t in targets:
			var damage_factor: float = e._on_bullet_calculate_damage_factor(
				t, bullet_c
			)
			E.create_damage(
				t.id, 
				bullet_c.min_damage, 
				bullet_c.max_damage, 
				bullet_c.damage_type, 
				e.id, 
				damage_factor
			)
			E.create_mods(t.id, e.id, bullet_c.mods)
			E.create_entities_at_pos(bullet_c.payloads, e.position)
	else:
		var damage_factor: float = e._on_bullet_calculate_damage_factor(
			target, bullet_c
		)
		E.create_damage(
			target.id, 
			bullet_c.min_damage, 
			bullet_c.max_damage, 
			bullet_c.damage_type, 
			e.id, 
			damage_factor
		)
		E.create_mods(target.id, e.id, bullet_c.mods)
		E.create_entities_at_pos(bullet_c.payloads, e.position)

	e._on_bullet_hit(target, bullet_c)

	if bullet_c.hit_remove:
		e.remove_entity()

func trajectory_liniear_init(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	bullet_c.velocity = U.initial_linear_velocity(
		bullet_c.from, bullet_c.to, bullet_c.flight_time
	)

func trajectory_liniear_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	e.position = U.position_in_linear(bullet_c.velocity, bullet_c.from, TM.get_time(bullet_c.ts))

func trajectory_parabola_init(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	bullet_c.velocity = U.initial_parabola_velocity(
		e.position, bullet_c.to, bullet_c.flight_time, bullet_c.g
	)
	
	var current_time: float = TM.get_time(bullet_c.ts)
	var next_time: float = current_time + TM.frame_length
	var next_pos = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, bullet_c.g
	)
	e.look_at(next_pos)
	
func trajectory_parabola_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	var current_time: float = TM.get_time(bullet_c.ts)
	var current_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, current_time, bullet_c.g
	)
	
	var next_time: float = current_time + TM.frame_length
	var next_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, bullet_c.g
	)
	
	e.position = current_pos
	
	e.look_at(next_pos)

func trajectory_tracking_init(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	e.look_at(bullet_c.to)

func trajectory_tracking_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	if is_instance_valid(target):
		bullet_c.to = target.position
	
	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.position += bullet_c.direction * bullet_c.speed * TM.frame_length
	e.look_at(bullet_c.to)

func trajectory_instant_init(e: Entity, bullet_c: BulletComponent, target: Entity):
	e.position = target.position
	
	e.rotation = deg_to_rad(90)
