extends System

func _on_update(delta: float) -> void:
	var dirty_entities_id: Array[int] = EntityDB._dirty_entities_id
	if dirty_entities_id.is_empty():
		return
		
	var type_groups: Dictionary[String, Array] = EntityDB.type_groups
	var component_groups: Dictionary[String, Array] = EntityDB.component_groups
		
	for group in type_groups.values():
		group.clear()
	component_groups.clear()
	
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e):
			continue

		if e.is_enemy():
			type_groups[CS.GROUP_ENEMIES].append(e)
		if e.is_friendly():
			type_groups[CS.GROUP_FRIENDLYS].append(e)
		if e.is_tower():
			type_groups[CS.GROUP_TOWERS].append(e)
		if e.is_modifier():
			type_groups[CS.GROUP_MODIFIERS].append(e)
		if e.is_aura():
			type_groups[CS.GROUP_AURAS].append(e)

		for c_name: String in e.has_components.keys():
			if not component_groups.has(c_name):
				component_groups[c_name] = []

			if not e.has_c(c_name):
				continue

			component_groups[c_name].append(e)
			
	dirty_entities_id.clear()
