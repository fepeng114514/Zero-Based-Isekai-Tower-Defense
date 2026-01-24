extends Entity

var direction: Vector2 = Vector2.RIGHT
@onready var target: Entity = EntityDB.get_entity_by_id(target_id)
@onready var Bullet: BulletComponent = $BulletComponent
	
func update(delta: float) -> void:
	direction = (target.position - position).normalized()
	position += direction * Bullet.speed * delta
	
	rotation = direction.angle()
	
	if target.position == position:
		EntityDB.create_damage(target_id, Bullet.min_damage, Bullet.max_damage, source_id)
		EntityDB.remove_entity(self)
