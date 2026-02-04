extends System
class_name MeleeSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_MELEE):
		return true
		
	var melee_c: MeleeComponent = e.get_c(CS.CN_MELEE)
	melee_c.sort_attacks()
	
	return true

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e) or not e.flags & CS.FLAG_FRIENDLY or not e.has_c(CS.CN_MELEE):
			continue
			
		var state: int = e.state
			
		if e.waitting or not state & (CS.STATE_IDLE | CS.STATE_MELEE):
			continue
			
		var melee_c: MeleeComponent = e.get_c(CS.CN_MELEE)
		var blockers: Dictionary = melee_c.blockers
			
		# 仅处理友军
		var filter = func(entity): return entity.has_c(CS.CN_MELEE) and not blockers.has(entity.id)
		var targets = EntityDB.search_targets_in_range(melee_c.search_mode, e.position, melee_c.block_min_range, melee_c.block_max_range, melee_c.block_flags, melee_c.block_bans, filter)	
		
		for t in targets:
			if melee_c.blockers.size() > melee_c.max_blocked:
				break
			
			var t_melee_c: MeleeComponent = t.get_c(CS.CN_MELEE)
			t_melee_c.blockers[t.id] = self
			blockers[t.id] = t
		
		for a: Dictionary in melee_c.order:
			pass
