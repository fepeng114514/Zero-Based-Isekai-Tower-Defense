extends Behavior
class_name RangedBehavior

func _on_update(e: Entity) -> bool:
	var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	if not ranged_c:
		return false
		
	for a: RangedAttack in ranged_c.list:
		if not a.with_melee:
			return false
		
		var target: Entity = null
		
		if U.is_valid_number(e.target_id):
			target = EntityDB.get_entity_by_id(e.target_id)
		elif not ranged_c.disabled_search:
			target = EntityDB.search_target(
				a.search_mode, 
				e.global_position, 
				a.max_range, 
				a.min_range, 
				a.vis_flag_bits, 
				a.vis_ban_bits
			)
			
		if not can_attack(a, target):
			return false
			
		_do_attack(a, e, target)
		return true
			
	return false
	
	
func _do_attack(a: RangedAttack, e: Entity, target: Entity) -> void:
	e.play_animation(a.animation)
	await e.y_wait(a.delay)
	e.play_animation(e.default_animation)
	a.ts = TimeDB.tick_ts

	if not target:
		return
	
	var b = EntityDB.create_entity(a.bullet)
	b.target_id = target.id
	b.source_id = e.id
	b.global_position = e.global_position + a.bullet_offset
	
	b.insert_entity()
