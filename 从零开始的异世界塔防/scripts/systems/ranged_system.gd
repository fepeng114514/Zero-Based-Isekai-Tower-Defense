extends System


func _ready() -> void:
	wait_entity = true


func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_RANGED):
		return true
		
	var ranged_c = e.get_c(C.CN_RANGED)
	ranged_c.sort_attacks()

	return true


func _on_update(delta: float) -> void:
	for e: Entity in EntityDB.get_entities_group(C.CN_RANGED):
		var state: int = e.state

		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	
		for a: Dictionary in ranged_c.order:
			if (
				not state & C.STATE_IDLE 
				and (not a.together_melee or state & C.STATE_MELEE)
			):
				continue
				
			var target = EntityDB.search_target(
				a.search_mode, e.position, a.min_range, a.max_range, a.flags, a.bans
			)
			if not can_attack(a, target):
				return
				
			attack(e, a, target)
	

func attack(e: Entity, a: Dictionary, target: Entity) -> void:
	var b = EntityDB.create_entity(a.bullet)
	b.target_id = target.id
	b.source_id = e.id
	b.position = e.position
	
	b.insert_entity()
		
	a.ts = TimeDB.tick_ts
