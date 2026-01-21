extends PathFollow2D
#
func _ready():
	EntitySystem.create_entity("enemy_goblin", self)
	var e = EntitySystem.create_entity("enemy_goblin", self)
	e.position.y += 15
