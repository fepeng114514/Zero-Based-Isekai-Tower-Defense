extends Node
class_name Store
@onready var entities_node = $Entities


func _ready() -> void:
	S.insert_entity_s.connect(_on_create_entity)
	
	for e: Entity in entities_node.get_children():
		EntityDB.process_create(e)
			
		e.insert_entity()


func _on_create_entity(entity: Entity) -> void:
	if entity.get_parent() != null:
		return
		
	entities_node.add_child(entity)
