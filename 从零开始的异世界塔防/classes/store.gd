extends Node
class_name Store
@onready var entities_node = $Entities


func _ready() -> void:
	S.create_entity_s.connect(_on_create_entity)
	
	for e: Entity in entities_node.get_children():
		EntityDB.process_create(e)
			
		e.insert_entity()


func _on_create_entity(entity: Entity) -> void:
	entities_node.add_child(entity)
