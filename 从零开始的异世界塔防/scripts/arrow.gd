extends Entity

var direction: Vector2 = Vector2.RIGHT
var speed: Vector2
@onready var B: BulletComponent = $BulletComponent
@onready var to = B.to
@onready var from = B.from
@onready var flight_time = B.flight_time

func insert():
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
	
	B.predict_target_pos = PathDB.predict_target_pos(target, flight_time * CS.FPS)
	to = B.predict_target_pos
	from = position
	
	direction = (to - position).normalized()	
	rotation = deg_to_rad(-90)
	B.rotation_speed = deg_to_rad(-180) / flight_time * (1 if to.x < position.x else -1)
	
	speed = Utils.initial_parabola_speed(position, to, flight_time, B.g)
	ts = TM.tick_ts
	return true
	
func update() -> void:
	var time: float = TM.tick_ts - ts
	position = Utils.position_in_parabola(time, from, speed, B.g)
	
	rotation += B.rotation_speed * time * TM.frame_length
	
	if B.hit_rect.has_point(to - position):
		EntityDB.create_damage(target_id, B.min_damage, B.max_damage, source_id)
		EntityDB.remove_entity(self)
		return
