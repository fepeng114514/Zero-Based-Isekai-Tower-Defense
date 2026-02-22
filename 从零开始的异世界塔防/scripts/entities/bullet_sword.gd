extends Entity

@onready var bullet_c = get_c(C.CN_BULLET)
var stay_height: int = 0
var stay_time: float = 0
var to_predict_time: float = 0
var is_stay: bool = true
var is_to_predict: bool = true
var has_to_predict: bool = false
var has_init_fall: bool = false


func _on_insert() -> bool:
	position.y -= stay_height

	return true


func _on_update(delta: float) -> void:
	var target = EntityDB.get_entity_by_id(target_id)

	# 停留状态
	if target and is_stay and not TimeDB.is_ready_time(bullet_c.ts, stay_time):
		var t_pos: Vector2 = target.position
		position = Vector2(t_pos.x, t_pos.y - stay_height)
		bullet_c.to = position
		bullet_c.from = position
		return
	
	# 初始化预判位置
	if not has_to_predict:
		is_stay = false
		has_to_predict = true
		
		if is_instance_valid(target):
			bullet_c.predict_target_pos = PathDB.predict_target_pos(
				target, (bullet_c.flight_time + to_predict_time)
			)
		else:
			bullet_c.predict_target_pos = Vector2(
				bullet_c.to.x, bullet_c.to.y + stay_height
			)
		bullet_c.to = bullet_c.predict_target_pos
		
		bullet_c.velocity = U.initial_linear_velocity(
			position, 
			Vector2(bullet_c.to.x, bullet_c.to.y - stay_height), 
			to_predict_time
		)
		bullet_c.ts = TimeDB.tick_ts
		
	# 飞向预判位置
	if is_to_predict and not TimeDB.is_ready_time(bullet_c.ts, to_predict_time):
		position = U.position_in_linear(
			bullet_c.velocity, bullet_c.from, TimeDB.get_time(bullet_c.ts)
		)
		
		return
	
	# 初始化下落
	if not has_init_fall:
		is_to_predict = false
		has_init_fall = true
		bullet_c.can_arrived = true
		bullet_c.from = position

		bullet_c.velocity = U.initial_linear_velocity(
			position, bullet_c.to, bullet_c.flight_time
		)

		bullet_c.ts = TimeDB.tick_ts

	# 下落
	position = U.position_in_linear(
		bullet_c.velocity, bullet_c.from, TimeDB.get_time(bullet_c.ts)
	)


func _on_bullet_calculate_damage_factor(
		target: Entity, bullet_c: BulletComponent
	) -> float:
	return U.dist_factor_inside_radius(
		position, 
		target.position, 
		bullet_c.min_damage_radius, 
		bullet_c.max_damage_radius
	)
