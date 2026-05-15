extends BulletTrajectory
class_name TrajectoryInstant
## 瞬移轨迹
##
## 子弹瞬间移动到目标位置。


func _init_trajectory(_bullet_c: BulletComponent, e: Entity, target: Entity) -> void:
	e.global_position = target.global_position
	e.rotation = deg_to_rad(90)
