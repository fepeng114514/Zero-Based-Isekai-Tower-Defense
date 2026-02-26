extends System


func _initialize() -> void:
	wait_entity = true


func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_RANGED):
		return true
		
	var ranged_c = e.get_c(C.CN_RANGED)
	ranged_c.sort_attacks()

	return true


func _on_update(delta: float) -> void:
	process_entities(C.CN_RANGED, func(e: Entity) -> void:
		var state: int = e.state
		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	
		for a: Dictionary in ranged_c.order:
			if (
				not state & C.STATE_IDLE 
				and (not a.together_melee or state & C.STATE_MELEE)
			):
				continue
				
			var target = EntityDB.search_target(
				a.search_mode, e.position, a.max_range, a.min_range, a.flags, a.bans
			)
			if not can_attack(a, target):
				continue
				
			e.play_animation("shoot")
			e.wait(a.delay, false)

			e.insert_wait_action_queue(func(this: Entity) -> void:
				var b = EntityDB.create_entity(a.bullet)
				b.target_id = target.id
				b.source_id = this.id
				b.position = this.position
				
				b.insert_entity()
					
				a.ts = TimeDB.tick_ts
				e.play_animation("default")
			)
			return
	)
		
