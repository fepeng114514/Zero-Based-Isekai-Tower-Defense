extends Node
class_name World
## 世界类
##
## 实体通常会挂载到该节点下


func _ready() -> void:
	S.insert_entity.connect(_on_create_entity)
	
	for e: Entity in get_children():
		EntityDB.process_create(e)
			
		e.insert_entity()


func _on_create_entity(entity: Entity) -> void:
	if entity.get_parent() != null:
		return
		
	add_child(entity)
