@tool
extends Entity


func _on_bullet_calculate_damage_factor(
		target: Entity, bullet_c: BulletComponent
	) -> float:
	return U.dist_factor_inside_radius(
		global_position, 
		target.global_position, 
		bullet_c.damage_min_radius, 
		bullet_c.damage_max_radius
	)
