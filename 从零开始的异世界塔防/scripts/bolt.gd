extends Entity

var direction: Vector2 = Vector2.RIGHT
var target
var t_pos: Vector2
@onready var Bullet: BulletComponent = $BulletComponent
	
func insert():
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
		
	t_pos = target.position
	direction = (t_pos - position).normalized()	
	rotation = direction.angle()
		
	return true
	
func update() -> void:
	if is_instance_valid(target):
		t_pos = target.position
	
	direction = (t_pos - position).normalized()
	position += direction * Bullet.speed * TimeManager.frame_length
	
	rotation = direction.angle()
	
	if Bullet.hit_rect.has_point(t_pos - position):
		EntityDB.create_damage(target_id, Bullet.min_damage, Bullet.max_damage, source_id)
		EntityDB.remove_entity(self)
		return
