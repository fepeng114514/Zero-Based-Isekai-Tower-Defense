extends Entity

@onready var B: BulletComponent = $BulletComponent
var target

func on_insert() -> bool:
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(B.target):
		return false
		
	B.to = target.position
	B.direction = (B.to - position).normalized()	
	rotation = B.direction.angle()
		
	return true
	
func on_update(delta: float) -> void:
	if is_instance_valid(target):
		B.to = target.position
	
	B.direction = (B.to - position).normalized()
	position += B.direction * B.speed * delta
	
	rotation = B.direction.angle()
	
	if B.hit_rect.has_point(B.to - position):
		EntityDB.create_damage(target_id, B.min_damage, B.max_damage, source_id)
		EntityDB.remove_entity(self)
		return
