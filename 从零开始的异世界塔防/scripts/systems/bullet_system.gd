extends System

func _on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_BULLET):
		return true

	var bullet_c: BulletComponent = e.get_c(CS.CN_BULLET)
	var target: Entity = EntityDB.get_entity_by_id(e.target_id)
	if not target:
		return false

	if bullet_c.flight_trajectory & CS.TRAJECTORY_LINEAR:
		trajectory_liniear_init(e, bullet_c, target)
	elif bullet_c.flight_trajectory & CS.TRAJECTORY_PARABOLA:
		trajectory_parabola_init(e, bullet_c, target)
	elif bullet_c.flight_trajectory & CS.TRAJECTORY_TRACKING:
		trajectory_tracking_init(e, bullet_c, target)
	# elif bullet_c.flight_trajectory & CS.TRAJECTORY_HOMING:
	# 	trajectory_homing_init(e, bullet_c, target)
	# elif bullet_c.flight_trajectory & CS.TRAJECTORY_INSTANT:
	# 	trajectory_instant_init(e, bullet_c, target)
	# elif bullet_c.flight_trajectory & CS.TRAJECTORY_CUSTOM:
	# 	e.custom_bullet_trajectory_init(e, bullet_c, target)
	else:
		push_error("未知子弹飞行轨迹类型: %s, 子弹: %s(%d)" % [bullet_c.flight_trajectory, e.template_name, e.id])
		return false

	bullet_c.ts = TM.tick_ts
	return true

func _on_update(delta: float) -> void:
	for e: Entity in EntityDB.get_entities_by_group(CS.GROUP_BULLETS):
		var bullet_c: BulletComponent = e.get_c(CS.CN_BULLET)

		var target: Entity = EntityDB.get_entity_by_id(e.target_id)

		if bullet_c.flight_trajectory & CS.TRAJECTORY_LINEAR:
			trajectory_liniear_update(e, bullet_c, target)
		elif bullet_c.flight_trajectory & CS.TRAJECTORY_PARABOLA:
			trajectory_parabola_update(e, bullet_c, target)
		elif bullet_c.flight_trajectory & CS.TRAJECTORY_TRACKING:
			trajectory_tracking_update(e, bullet_c, target)
		# elif bullet_c.flight_trajectory & CS.TRAJECTORY_HOMING:
		# 	trajectory_homing_update(e, bullet_c, target)
		# elif bullet_c.flight_trajectory & CS.TRAJECTORY_INSTANT:
		# 	trajectory_instant_update(e, bullet_c, target)
		# elif bullet_c.flight_trajectory & CS.TRAJECTORY_CUSTOM:
		# 	e.custom_bullet_trajectory_update(e, bullet_c, target)

		if not bullet_c.hit_rect.has_point(bullet_c.to - e.position):
			continue
			
		hit(e, bullet_c, target)
		
func hit(e: Entity, bullet_c: BulletComponent, target: Entity):
	e._on_bullet_hit(e, target)

	EntityDB.create_damage(
		e.target_id, 
		bullet_c.min_damage, 
		bullet_c.max_damage, 
		bullet_c.damage_type, 
		e.source_id
	)
	e.remove_entity()

func trajectory_liniear_init(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	bullet_c.predict_target_pos = PathDB.predict_target_pos(
		target, bullet_c.flight_time * TM.fps
	)
	bullet_c.to = bullet_c.predict_target_pos
	bullet_c.from = e.position
	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.look_at(bullet_c.to)

	bullet_c.speed = Utils.initial_linear_speed(
		e.position, bullet_c.to, bullet_c.flight_time
	)

func trajectory_liniear_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	bullet_c.to = bullet_c.predict_target_pos

	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.position += bullet_c.direction * bullet_c.speed * TM.frame_length

	e.look_at(bullet_c.to)

func trajectory_parabola_init(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	bullet_c.predict_target_pos = PathDB.predict_target_pos(
		target, bullet_c.flight_time * TM.fps
	)
	bullet_c.to = bullet_c.predict_target_pos
	bullet_c.from = e.position
	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.look_at(bullet_c.to)
	
	bullet_c.speed = Utils.initial_parabola_speed(
		e.position, bullet_c.to, bullet_c.flight_time, bullet_c.g
	)

func trajectory_parabola_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	var current_time = TM.get_time(bullet_c.ts)
	var current_pos = Utils.position_in_parabola(
		current_time, bullet_c.from, bullet_c.speed, bullet_c.g
	)
	
	var next_time = current_time + TM.frame_length
	var next_pos = Utils.position_in_parabola(
		next_time, bullet_c.from, bullet_c.speed, bullet_c.g
	)
	
	e.position = current_pos
	
	e.look_at(next_pos)

func trajectory_tracking_init(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	bullet_c.to = target.position
	bullet_c.from = e.position
	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.look_at(bullet_c.to)

func trajectory_tracking_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	if is_instance_valid(target):
		bullet_c.to = target.position
	
	bullet_c.direction = (bullet_c.to - e.position).normalized()
	e.position += bullet_c.direction * bullet_c.speed * TM.frame_length
	e.look_at(bullet_c.to)
