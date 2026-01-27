extends Entity

var direction: Vector2 = Vector2.RIGHT
var target
var last_pos: Vector2
@onready var Bullet: BulletComponent = $BulletComponent
	
func insert():
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
		
	last_pos = target.position
	direction = (last_pos - position).normalized()	
	rotation = direction.angle()
		
	return true
	
func update() -> void:
	if is_instance_valid(target):
		last_pos = target.position
	
	direction = (last_pos - position).normalized()
	position += direction * Bullet.speed * TM.frame_length
	
	rotation = direction.angle()
	
	if Bullet.hit_rect.has_point(last_pos - position):
		EntityDB.create_damage(target_id, Bullet.min_damage, Bullet.max_damage, source_id)
		EntityDB.remove_entity(self)
		return
