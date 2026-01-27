extends Entity

var direction: Vector2 = Vector2.RIGHT
@onready var B: BulletComponent = $BulletComponent
@onready var to = B.to
	
func insert():
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(B.target):
		return false
		
	to = target.position
	direction = (to - position).normalized()	
	rotation = direction.angle()
		
	return true
	
func update() -> void:
	if is_instance_valid(target):
		to = target.position
	
	direction = (to - position).normalized()
	position += direction * B.speed * TM.frame_length
	
	rotation = direction.angle()
	
	if B.hit_rect.has_point(to - position):
		EntityDB.create_damage(target_id, B.min_damage, B.max_damage, source_id)
		EntityDB.remove_entity(self)
		return
