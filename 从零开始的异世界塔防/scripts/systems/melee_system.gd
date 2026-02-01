extends System
class_name MeleeSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_MELEE):
		return true
		
	var melee_c = e.get_c(CS.CN_MELEE)
	Utils.sort_attacks(melee_c)
	
	return true
