extends Resource
class_name BulletTrajectory
## 子弹轨迹基类
##
## 每种轨迹类型继承此类，实现各自的初始化与更新逻辑。


@warning_ignore_start("unused_parameter")
## 初始化轨迹（子弹创建时调用）
func _init_trajectory(bullet_c: BulletComponent, e: Entity, target: Entity) -> void:
	pass


## 更新子弹位置（每帧调用）
func _update_trajectory(e: Entity, bullet_c: BulletComponent, target: Entity, flying_time: float, delta: float) -> void:
	pass


## 预判目标位置时使用的飞行时间（默认 0 表示当前时刻的位置）
func _get_predict_time() -> float:
	return 0.0


## 子弹是否超出飞行时间限制而应该进入未击中处理
func _should_miss(bullet_c: BulletComponent, flying_time: float) -> bool:
	return false


## 子弹是否已到达目标位置
func _has_arrived(e: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	return U.is_at_destination(e.global_position, bullet_c.to, bullet_c.hit_distance)
@warning_ignore_restore("unused_parameter")
