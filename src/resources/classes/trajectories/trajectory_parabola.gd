extends BulletTrajectory
class_name TrajectoryParabola
## 抛物线轨迹
##
## 子弹沿抛物线从起点飞向目标点。


## 子弹从发射到命中或消失的时间
@export var flight_total_time: float = 0
## 重力加速度
@export var flight_gravity: float = 980


func _get_predict_time() -> float:
	return flight_total_time


func _init_trajectory(bullet_c: BulletComponent, e: Entity, _target: Entity) -> void:
	var from: Vector2 = bullet_c.from
	var to: Vector2 = bullet_c.to

	var velocity: Vector2 = U.initial_parabola_velocity(
		from, to, flight_total_time, flight_gravity
	)
	bullet_c.velocity = velocity

	var next_pos: Vector2 = U.position_in_parabola(
		velocity, from, 0.1, flight_gravity
	)

	if bullet_c.look_to:
		e.look_at(next_pos)


func _update_trajectory(e: Entity, bullet_c: BulletComponent, _target: Entity, flying_time: float, _delta: float) -> void:
	var current_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, flying_time, flight_gravity
	)

	var next_time: float = flying_time + TimeMgr.frame_length
	var next_pos: Vector2 = U.position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, flight_gravity
	)

	e.global_position = current_pos

	if bullet_c.look_to:
		e.look_at(next_pos)


func _should_miss(_bullet_c: BulletComponent, flying_time: float) -> bool:
	return flight_total_time > 0 and flying_time >= flight_total_time


func _has_arrived(e: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	# 抛物线在飞行时间未达到 80% 时不检查是否到达目标
	if flying_time <= flight_total_time * 0.8:
		return false
	return super._has_arrived(e, bullet_c, flying_time)
