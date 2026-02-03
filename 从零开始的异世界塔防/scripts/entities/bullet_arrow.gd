extends Entity

@onready var B = get_c(CS.CN_BULLET)
var target

func on_insert() -> bool:
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
	
	B.predict_target_pos = PathDB.predict_target_pos(target, B.flight_time * TM.fps)
	B.to = B.predict_target_pos
	B.from = position
	
	var direction = (B.to - position).normalized()
	rotation = atan2(direction.y, direction.x)
	
	B.speed = Utils.initial_parabola_speed(position, B.to, B.flight_time, B.g)
	ts = TM.tick_ts
	return true
	
func on_update(delta: float) -> void:
	var current_time = TM.get_time(ts)
	var current_pos = Utils.position_in_parabola(current_time, B.from, B.speed, B.g)
	
	var next_time = current_time + delta
	var next_pos = Utils.position_in_parabola(next_time, B.from, B.speed, B.g)
	
	position = current_pos
	
	var velocity = (next_pos - current_pos).normalized()
	if velocity.length_squared() > 0:
		rotation = atan2(velocity.y, velocity.x)
	
	if not B.hit_rect.has_point(B.to - position):
		return
		
	EntityDB.create_damage(target_id, B.min_damage, B.max_damage, source_id)
	EntityDB.remove_entity(self)
