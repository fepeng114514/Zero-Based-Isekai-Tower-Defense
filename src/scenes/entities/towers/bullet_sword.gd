@tool
extends Entity

@onready var bullet_c = get_node_or_null(C.CN_BULLET)
var stay_height: int = 0
var stay_time: float = 0
var to_predict_time: float = 0
var is_stay: bool = true
var is_to_predict: bool = true
var has_to_predict: bool = false
var has_init_fall: bool = false


func _on_insert() -> bool:
	global_position.y -= stay_height

	return true


func _on_update(_delta: float) -> void:
	var target: Entity = EntityMgr.get_entity_by_id(target_id)

	# 停留状态
	if target and is_stay and not TimeMgr.is_ready_time(bullet_c.ts, stay_time):
		var t_pos: Vector2 = target.global_position
		global_position = Vector2(t_pos.x, t_pos.y - stay_height)
		bullet_c.to = global_position
		bullet_c.from = global_position
		return
	
	# 初始化预判位置
	if not has_to_predict:
		is_stay = false
		has_to_predict = true
		
		if is_instance_valid(target):
			var predict_time: float = (
				bullet_c.trajectory.flight_total_time
				if bullet_c.trajectory and "flight_total_time" in bullet_c.trajectory
				else 0.0
			)
			bullet_c.predict_target_pos = PathwayMgr.predict_target_pos(
				target, (predict_time + to_predict_time)
			)
		else:
			bullet_c.predict_target_pos = Vector2(
				bullet_c.to.x, bullet_c.to.y + stay_height
			)
		bullet_c.to = bullet_c.predict_target_pos
		
		bullet_c.velocity = U.initial_linear_velocity(
			global_position, 
			Vector2(bullet_c.to.x, bullet_c.to.y - stay_height), 
			to_predict_time
		)
		bullet_c.ts = TimeMgr.tick_ts
		
	# 飞向预判位置
	if is_to_predict and not TimeMgr.is_ready_time(bullet_c.ts, to_predict_time):
		global_position = U.position_in_linear(
			bullet_c.velocity, bullet_c.from, TimeMgr.get_time_by_ts(bullet_c.ts)
		)
		
		return
	
	# 初始化下落
	if not has_init_fall:
		is_to_predict = false
		has_init_fall = true
		bullet_c.can_arrived = true
		bullet_c.from = global_position

		var fall_time: float = (
			bullet_c.trajectory.flight_total_time
			if bullet_c.trajectory and "flight_total_time" in bullet_c.trajectory
			else 0.0
		)
		bullet_c.velocity = U.initial_linear_velocity(
			global_position, bullet_c.to, fall_time
		)

		bullet_c.ts = TimeMgr.tick_ts

	# 下落
	global_position = U.position_in_linear(
		bullet_c.velocity, bullet_c.from, TimeMgr.get_time_by_ts(bullet_c.ts)
	)
