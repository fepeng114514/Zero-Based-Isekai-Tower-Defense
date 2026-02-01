extends System
class_name RangedSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_RANGED):
		return true
		
	var ranged_c = e.get_c(CS.CN_RANGED)
	Utils.sort_attacks(ranged_c)

	return true
