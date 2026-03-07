extends System
class_name BulletSystem

"""子弹系统:
	管理子弹实体的飞行轨迹、命中检测和伤害计算等相关逻辑。子弹系统会在每一帧更新子弹实体的位置，
	并检测子弹是否命中目标或飞行到达目标位置。如果子弹命中目标，系统将计算伤害并应用状态效果，
	同时触发相关事件回调。如果子弹飞行到达目标位置但未命中目标，系统将触发未命中事件回调。
"""


func _on_insert(e: Entity) -> bool:
	var bullet_c: BulletComponent = e.get_c(C.CN_BULLET)
	if not bullet_c:
		return true

	var target: Entity = EntityDB.get_entity_by_id(e.target_id)
	if not target:
		return false

	bullet_c.ts = TimeDB.tick_ts
	var flying_time: float = TimeDB.get_time(bullet_c.ts)
	if not bullet_c.disabled_predict_pos:
		bullet_c.predict_target_pos = PathDB.predict_target_pos(
			target, bullet_c.flight_time
		)
	else:
		bullet_c.predict_target_pos = target.global_position
	
	bullet_c.to = bullet_c.predict_target_pos
	bullet_c.from = e.global_position
	e.look_at(bullet_c.to)

	bullet_c.rotation_direction = -1 if bullet_c.to.x < e.global_position.x else 1

	if bullet_c.flight_trajectory & C.TRAJECTORY.LINEAR:
		_trajectory_liniear_init(bullet_c)
	elif bullet_c.flight_trajectory & C.TRAJECTORY.PARABOLA:
		_trajectory_parabola_init(e, bullet_c, flying_time)
	elif bullet_c.flight_trajectory & C.TRAJECTORY.TRACKING:
		_trajectory_tracking_init(e, bullet_c)
	elif bullet_c.flight_trajectory & C.TRAJECTORY.INSTANT:
		_trajectory_instant_init(e, target)

	return true


func _on_update(delta: float) -> void:
	for e: Entity in EntityDB.get_entities_group(C.CN_BULLET):
		var bullet_c: BulletComponent = e.get_c(C.CN_BULLET)

		var target: Entity = EntityDB.get_entity_by_id(e.target_id)
		var flying_time: float = TimeDB.get_time(bullet_c.ts)

		if bullet_c.flight_trajectory & C.TRAJECTORY.LINEAR:
			_trajectory_liniear_update(e, bullet_c)
		elif bullet_c.flight_trajectory & C.TRAJECTORY.PARABOLA:
			_trajectory_parabola_update(e, bullet_c, flying_time)
		elif bullet_c.flight_trajectory & C.TRAJECTORY.TRACKING:
			_trajectory_tracking_update(e, bullet_c, target)

		e.rotation += bullet_c.rotation_speed * delta
		
		if flying_time >= bullet_c.flight_time:
			e._on_bullet_miss(target, bullet_c)

			if bullet_c.miss_remove:
				e.remove_entity()
			continue
			
		if not bullet_c.can_arrived:
			continue
		
		if not target:
			continue
		
		if U.is_at_destination(
				e.global_position, target.global_position, bullet_c.hit_dist
		):
			_hit(e, bullet_c, target)


## 击中目标调用
func _hit(e: Entity, bullet_c: BulletComponent, target: Entity) -> void:
	if bullet_c.min_damage_radius > 0 or bullet_c.max_damage_radius > 0:
		var targets: Array = EntityDB.search_targets_in_range(
			bullet_c.search_mode, 
			bullet_c.to, 
			bullet_c.max_damage_radius, 
			bullet_c.min_damage_radius, 
			e.flag_bits, 
			e.ban_bits
		)

		for t in targets:
			_damege_target(e, bullet_c, t)
	else:
		_damege_target(e, bullet_c, target)

	e._on_bullet_hit(target, bullet_c)

	if bullet_c.hit_remove:
		e.remove_entity()
	
	
## 伤害目标
func _damege_target(e: Entity, bullet_c: BulletComponent, target: Entity) -> void:
	var damage_factor: float = e._on_bullet_calculate_damage_factor(
			target, bullet_c
		)
	EntityDB.create_damage(
		target.id, 
		bullet_c.min_damage, 
		bullet_c.max_damage, 
		bullet_c.damage_type, 
		e.id, 
		damage_factor
	)
	EntityDB.create_mods(target.id, bullet_c.mods, e.id)
	EntityDB.create_entities_at_pos(bullet_c.payloads, e.global_position)


#region 轨迹相关函数
## 直线轨迹初始化
func _trajectory_liniear_init(bullet_c: BulletComponent) -> void:
	bullet_c.velocity = U.initial_linear_velocity(
		bullet_c.from, bullet_c.to, bullet_c.flight_time
	)


## 直线轨迹更新
func _trajectory_liniear_update(e: Entity, bullet_c: BulletComponent) -> void:
	e.global_position = U.position_in_linear(
		bullet_c.velocity, bullet_c.from, TimeDB.get_time(bullet_c.ts)
	)


## 抛物线轨迹初始化
func _trajectory_parabola_init(
		e: Entity, bullet_c: BulletComponent, flying_time: float
	) -> void:
	bullet_c.velocity = U.initial_parabola_velocity(
		e.global_position, bullet_c.to, bullet_c.flight_time, bullet_c.g
	)
	
	var next_time: float = flying_time + TimeDB.frame_length
	var next_pos = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, bullet_c.g
	)
	e.look_at(next_pos)
	

## 抛物线轨迹更新
func _trajectory_parabola_update(
		e: Entity, bullet_c: BulletComponent, flying_time: float
	) -> void:
	var current_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, flying_time, bullet_c.g
	)
	
	var next_time: float = flying_time + TimeDB.frame_length
	var next_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, bullet_c.g
	)
	
	e.global_position = current_pos
	
	e.look_at(next_pos)


## 追踪轨迹初始化
func _trajectory_tracking_init(
		e: Entity, bullet_c: BulletComponent
	) -> void:
	e.look_at(bullet_c.to)


## 追踪轨迹更新
func _trajectory_tracking_update(
		e: Entity, bullet_c: BulletComponent, target: Entity
	) -> void:
	if is_instance_valid(target):
		bullet_c.to = target.global_position
	
	var direction: Vector2 = e.global_position.direction_to(bullet_c.to)
	e.global_position += direction * bullet_c.speed * TimeDB.frame_length
	e.look_at(bullet_c.to)


## 瞬移轨迹初始化
func _trajectory_instant_init(e: Entity, target: Entity) -> void:
	e.global_position = target.global_position
	
	e.rotation = deg_to_rad(90)
#endregion
