extends Entity

var direction: Vector2 = Vector2.RIGHT
var target
var t_pos: Vector2
@onready var Bullet: BulletComponent = $BulletComponent
	
func insert():
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
		
	return true
	
func update(delta: float) -> void:
	if is_instance_valid(target):
		t_pos = target.position
	
	direction = (t_pos - position).normalized()
	position += direction * Bullet.speed * delta
	
	rotation = direction.angle()
	
	if abs(t_pos - position) < Vector2(1, 1):
		EntityDB.create_damage(target_id, Bullet.min_damage, Bullet.max_damage, source_id)
		EntityDB.remove_entity(self)
		return
