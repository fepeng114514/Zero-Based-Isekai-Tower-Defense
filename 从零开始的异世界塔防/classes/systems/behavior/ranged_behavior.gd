extends Behavior
class_name RangedBehavior
## 远程攻击行为系统
##
## 处理拥有 [RangedComponent] 远程攻击组件的实体的远程攻击


func _on_update(e: Entity) -> bool:
	var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	if not ranged_c:
		return false
		
	for a: RangedBase in ranged_c.list:
		var target: Entity = null
		
		if U.is_valid_number(e.target_id):
			target = EntityMgr.get_entity_by_id(e.target_id)
		elif not ranged_c.disabled_search:
			target = EntityMgr.search_target(
				a.search_mode, 
				e.global_position, 
				a.max_range, 
				a.min_range, 
				a.flag_bits, 
				a.ban_bits
			)
			
		if not can_attack(a, target):
			return false
		
		if a is RangedAttack:
			_do_single_attack(a, e, target)
		elif a is RangedLoopAttack:
			_do_loop_attack(a, e, target)
		return true
			
	return false
	
	
func _do_single_attack(a: RangedAttack, e: Entity, target: Entity) -> void:
	e.look_at_point = target.global_position
	var result: Array = e.mixed_play_animation_by_look(a.animation, "ranged")
	AudioMgr.play_sfx(a.sfx)
	await e.y_wait(a.delay, func() -> bool:
		return not U.is_vaild_entity(target)
	)
	var direction: C.Direction = result[1]
	
	a.ts = TimeMgr.tick_ts

	if not target:
		return

	spawn_bullets(a, e, target, direction)

	await e.mixed_wait_animation(a.animation)
	e.play_idle_animation()


func _do_loop_attack(a: RangedLoopAttack, e: Entity, target: Entity) -> void:
	e.look_at_point = target.global_position
	e.mixed_play_animation_by_look(a.start_animation, "ranged")
	a.ts = TimeMgr.tick_ts

	AudioMgr.play_sfx(a.start_sfx)
	await e.mixed_wait_animation(a.start_animation)

	if not target:
		return

	for i: int in range(a.loop_count):
		e.look_at_point = target.global_position
		var result: Array = e.mixed_play_animation_by_look(a.loop_animation)
		var direction: C.Direction = result[1]

		AudioMgr.play_sfx(a.loop_sfx)
		await e.y_wait(a.delay, func() -> bool:
			return not U.is_vaild_entity(target)
		)

		spawn_bullets(a, e, target, direction)
		await e.mixed_wait_animation(a.loop_animation)

	await e.mixed_wait_animation(a.loop_animation)

	e.mixed_play_animation_by_look(a.end_animation)
	AudioMgr.play_sfx(a.end_sfx)
	await e.mixed_wait_animation(a.end_animation)

	e.play_idle_animation()


func spawn_bullets(a: RangedBase, e: Entity, target: Entity, direction: C.Direction) -> void:
	var e_to_target_angle: float = e.global_position.angle_to_point(target.global_position)
	var bullet_count: int = a.bullet_count
	var bullet_angle_range: float = a.bullet_angle_range
	var half_angle_range: float = bullet_angle_range / 2
	var da: float = (bullet_angle_range) / bullet_count + 1
	
	for i: int in range(bullet_count):
		var b = EntityMgr.create_entity(a.bullet)
		b.target_id = target.id
		b.source_id = e.id

		var rotation: float = 0
		match a.bullet_spawn_mode:
			C.BulletSpawnMode.EQUAL_INTERVAL:
				rotation = e_to_target_angle + (da * i + -half_angle_range)
			C.BulletSpawnMode.RANDOM:
				var random_angle: float = randf_range(
					-half_angle_range, half_angle_range	
				)
				rotation = e_to_target_angle + random_angle
		b.rotation = rotation
		b.global_position = e.global_position + a.bullet_offsets.get_offset_by_direction(direction)

		b.insert_entity()