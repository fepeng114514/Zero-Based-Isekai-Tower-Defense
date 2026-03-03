extends System


func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_entities_group(C.CN_RANGED).filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and e.has_state(C.STATE.RANGED | C.STATE.MELEE | C.STATE.IDLE)
	)

	for e: Entity in entities:
		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	
		for a: Ranged in ranged_c.order:
			if not a.together_melee and e.has_state(C.STATE.MELEE):
				continue
			
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
				continue
				
			e.state = C.STATE.RANGED
			_do_attack(a, e, target)
			
		
func _do_attack(a: Ranged, e: Entity, target: Entity) -> void:
	e.play_animation(a.animation)
	await e.y_wait(a.delay)
	a.ts = TimeDB.tick_ts
	e.play_animation(e.default_animation)

	if not target:
		return
	
	var b = EntityDB.create_entity(a.bullet)
	b.target_id = target.id
	b.source_id = e.id
	b.global_position = e.global_position
	
	b.insert_entity()

	e.state = C.STATE.IDLE
