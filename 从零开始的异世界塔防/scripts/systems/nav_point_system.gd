extends System
class_name NavPointSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_NAV_POINT):
		return true
		
	var nav_point_c = e.get_c(CS.CN_NAV_POINT)

	nav_point_c.direction = nav_point_c.to.normalized()
		
	return true


func on_update(delta: float):
	for e in EntityDB.entities:
		if not is_instance_valid(e) or not e.has_c(CS.CN_NAV_POINT):
			continue
			
		var nav_point_c = e.get_c(CS.CN_NAV_POINT)
		
		if nav_point_c.reversed:
			continue
		
		if e.position.is_equal_approx(nav_point_c.to):
			nav_point_c.reversed = true
			return
			
		e.position = nav_point_c.direction * nav_point_c.speed
		e.on_nav_walk()
