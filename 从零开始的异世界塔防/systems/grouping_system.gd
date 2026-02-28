extends System

const FLAG_TO_GROUP = {
	C.FLAG.ENEMY: C.GROUP_ENEMIES,
	C.FLAG.FRIENDLY: C.GROUP_FRIENDLYS,
	C.FLAG.TOWER: C.GROUP_TOWERS,
	C.FLAG.MODIFIER: C.GROUP_MODIFIERS,
	C.FLAG.AURA: C.GROUP_AURAS,
	C.FLAG.BULLET: C.GROUP_BULLETS
}


func _on_update(delta: float) -> void:
	var dirty_entities_ids: Array[int] = EntityDB._dirty_entities_ids
	if dirty_entities_ids.is_empty():
		return
		
	var type_groups: Dictionary[String, Array] = EntityDB.type_groups
	var component_groups: Dictionary[String, Array] = EntityDB.component_groups
		
	for group in type_groups.values():
		group.clear()
	component_groups.clear()
	
	for e: Entity in EntityDB.get_vaild_entities():
		for flags: C.FLAG in FLAG_TO_GROUP.keys():
			if e.flag_set.has_flags(flags):
				_append_entity(e, FLAG_TO_GROUP[flags])

		for c_name: String in e.components.keys():
			if not component_groups.has(c_name):
				component_groups[c_name] = []

			if not e.has_c(c_name):
				continue

			component_groups[c_name].append(e)
			
	dirty_entities_ids.clear()

func _append_entity(e: Entity, group_name: StringName) -> void:
	EntityDB.type_groups[group_name].append(e)
