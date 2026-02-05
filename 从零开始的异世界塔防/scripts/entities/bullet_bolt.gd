extends Entity

@onready var B = get_c(CS.CN_BULLET)
var target

func _on_insert() -> bool:
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
		
	B.to = target.position
	B.direction = (B.to - position).normalized()	
	rotation = B.direction.angle()
		
	return true
	
func _on_update(delta: float) -> void:
	if is_instance_valid(target):
		B.to = target.position
	
	B.direction = (B.to - position).normalized()
	position += B.direction * B.speed * delta
	
	rotation = B.direction.angle()
	
	if not B.hit_rect.has_point(B.to - position):
		return
		
	EntityDB.create_damage(target_id, B.min_damage, B.max_damage, B.damage_type, B.source_id)
	EntityDB.remove_entity(self)
