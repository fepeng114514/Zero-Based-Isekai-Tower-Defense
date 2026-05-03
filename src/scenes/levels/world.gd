@tool
extends Node2D
## 世界类
##
## 实体通常会挂载到该节点下


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	S.insert_entity.connect(_on_create_entity)
	
	for e: Entity in get_children():
		EntityMgr.process_create(e)
			
		e.insert_entity()
		

func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 WaveSpawner 实体子场景，否则无法生成敌人。")
		
	return warn
	

func _on_create_entity(entity: Entity) -> void:
	if entity.get_parent() != null:
		return
		
	add_child(entity)
