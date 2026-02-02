extends System
class_name NavPointSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_NAV_POINT):
		return true
		
	var nav_point_c = e.get_c(CS.CN_NAV_POINT)

	nav_point_c.direction = nav_point_c.to.normalized()
		
	return true

func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e) or not e.has_c(CS.CN_NAV_POINT):
			continue
			
		var nav_point_c = e.get_c(CS.CN_NAV_POINT)
		
		if nav_point_c.arrived:
			continue
		
		if not Rect2(-3, -3, 6, 6).has_point(e.position - nav_point_c.to):
			nav_point_c.arrived = true
			continue
			
		e.position = nav_point_c.direction * nav_point_c.speed
		e.on_nav_walk()
		# 待实现动画播放
