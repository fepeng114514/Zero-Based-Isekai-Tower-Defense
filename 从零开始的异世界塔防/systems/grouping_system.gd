extends System


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
		if e.is_enemy():
			_append_entity(e, C.GROUP_ENEMIES)
		if e.is_friendly():
			_append_entity(e, C.GROUP_FRIENDLYS)
		if e.is_tower():
			_append_entity(e, C.GROUP_TOWERS)
		if e.is_modifier():
			_append_entity(e, C.GROUP_MODIFIERS)
		if e.is_aura():
			_append_entity(e, C.GROUP_AURAS)
		if e.is_bullet():
			_append_entity(e, C.GROUP_BULLETS)

		for c_name: String in e.has_components.keys():
			if not component_groups.has(c_name):
				component_groups[c_name] = []

			if not e.has_c(c_name):
				continue

			component_groups[c_name].append(e)
			
	dirty_entities_ids.clear()

func _append_entity(e: Entity, group_name: StringName) -> void:
	EntityDB.type_groups[group_name].append(e)