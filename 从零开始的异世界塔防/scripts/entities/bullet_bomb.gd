extends Entity

func _on_bullet_calculate_damage_factor(
		target: Entity, bullet_c: BulletComponent
	) -> float:
	return U.dist_factor_inside_radius(
		position, 
		target.position, 
		bullet_c.min_damage_radius, 
		bullet_c.max_damage_radius
	)
