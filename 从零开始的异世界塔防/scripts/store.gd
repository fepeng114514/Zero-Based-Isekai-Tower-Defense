extends Node
class_name Store
@onready var Entities = $Entities


func _ready() -> void:
	EntityDB.create_entity_s.connect(_on_create_entity)


func _on_create_entity(entity: Entity):
	Entities.add_child(entity)
