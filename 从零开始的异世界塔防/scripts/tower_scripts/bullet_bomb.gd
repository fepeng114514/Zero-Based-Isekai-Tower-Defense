extends Entity

@onready var B: BulletComponent = $BulletComponent
var target
var min_damage_radius: int = 0
var max_damage_radius: int = 0

func on_insert() -> bool:
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
	
	B.predict_target_pos = PathDB.predict_target_pos(target, B.flight_time * TM.fps)
	B.to = B.predict_target_pos
	B.from = position
	
	rotation = deg_to_rad(-90)
	
	var total_rotation_needed = deg_to_rad(180)
	B.rotation_direction = -1 if B.to.x < position.x else 1
	B.rotation_speed = total_rotation_needed / B.flight_time * B.rotation_direction
	
	B.speed = Utils.initial_parabola_speed(position, B.to, B.flight_time, B.g)
	ts = TM.tick_ts
	return true

func on_update(delta: float) -> void:
	var time: float = TM.tick_ts - ts
	
	position = Utils.position_in_parabola(time, B.from, B.speed, B.g)
	rotation += B.rotation_speed * delta
	
	if not B.hit_rect.has_point(B.to - position):
		return
	
	var targets = EntityDB.find_enemies_in_range(position, min_damage_radius, max_damage_radius, flags, bans)

	for t in targets:
		var damage_factor = Utils.dist_factor_inside_ellipse(t.position, position, min_damage_radius, max_damage_radius)
		
		EntityDB.create_damage(t.id, B.min_damage, B.max_damage, source_id, damage_factor)
	
	EntityDB.remove_entity(self)
