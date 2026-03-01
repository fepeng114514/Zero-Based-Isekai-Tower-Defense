extends System


func _on_create(e: Entity) -> bool:
	if not e.has_c(C.CN_RANGED):
		return true
		
	var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	
	for a: Ranged in ranged_c.get_children():
		ranged_c.list.append(a)
		
	return true
		

func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_RANGED):
		return true
		
	var ranged_c = e.get_c(C.CN_RANGED)
	ranged_c.sort_attacks()

	return true


func _on_update(_delta: float) -> void:
	var entities: Array = EntityDB.get_entities_group(C.CN_RANGED).filter(
		func(e: Entity) -> bool:
			return not e.waiting and e.has_state(C.STATE.RANGED | C.STATE.MELEE | C.STATE.IDLE)
	)

	for e: Entity in entities:
		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	
		for a: Ranged in ranged_c.order:
			if not a.together_melee and e.has_state(C.STATE.MELEE):
				continue
				
			var target: Entity = EntityDB.search_target(
				a.search_mode, 
				e.position, 
				a.max_range, 
				a.min_range, 
				a.vis_flag_bits, 
				a.vis_ban_bits
			)
			if not can_attack(a, target):
				continue
				
			e.state = C.STATE.RANGED
			do_attack(a, e, target)
		
		
func do_attack(a: Ranged, e: Entity, target: Entity) -> void:
	e.play_animation(a.animation)
	await e.y_wait(a.delay)
	e.play_animation("idle")

	if not target:
		return
	
	var b = EntityDB.create_entity(a.bullet)
	b.target_id = target.id
	b.source_id = e.id
	b.position = e.position
	
	b.insert_entity()
		
	a.ts = TimeDB.tick_ts
	e.state = C.STATE.IDLE
