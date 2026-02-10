extends System

func _on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_RANGED):
		return true
		
	var ranged_c = e.get_c(CS.CN_RANGED)
	ranged_c.sort_attacks()

	return true

func _on_update(delta: float) -> void:
	for e: Entity in E.get_entities_group(CS.CN_RANGED):
		var state: int = e.state
			
		if e.waitting:
			continue
			
		var ranged_c: RangedComponent = e.get_c(CS.CN_RANGED)
	
		for a: Dictionary in ranged_c.order:
			if (
				not state & CS.STATE_IDLE 
				and (not a.together_melee or state & CS.STATE_MELEE)
			):
				continue
				
			var target = E.search_target(
				a.search_mode, e.position, a.min_range, a.max_range, a.flags, a.bans
			)
			if not can_attack(a, target):
				return
				
			attack(e, a, target)
	
func attack(e: Entity, a: Dictionary, target: Entity) -> void:
	var b = E.create_entity(a.bullet)
	b.target_id = target.id
	b.source_id = e.id
	b.position = e.position
	
	b.insert_entity()
		
	a.ts = TM.tick_ts
