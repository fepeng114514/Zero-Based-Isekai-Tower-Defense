extends BulletTrajectory
class_name TrajectoryTracking
## 追踪轨迹
##
## 子弹持续追踪目标，实时更新方向。


## 子弹的飞行速度
@export var flight_speed: float = 0


func _init_trajectory(bullet_c: BulletComponent, e: Entity, _target: Entity) -> void:
	if bullet_c.look_to:
		e.look_at(bullet_c.to)


func _update_trajectory(e: Entity, bullet_c: BulletComponent, target: Entity, _flying_time: float, _delta: float) -> void:
	if is_instance_valid(target):
		var to: Vector2 = target.global_position
		if target.hit_offsets:
			var hit_offset: Vector2 = target.hit_offsets.get_offset_for_point(
				target.global_position, target.look_point
			)
			to += hit_offset
		bullet_c.to = to

	var direction: Vector2 = e.global_position.direction_to(bullet_c.to)
	e.global_position += direction * flight_speed * TimeMgr.frame_length

	if bullet_c.look_to:
		e.look_at(bullet_c.to)
