extends System


func _initialize() -> void:
	var level_data = LevelMgr.levels_data[GlobalStore.level_idx]

	create_level_entities(level_data)
	# create_level_tower_holders(level_data)


func create_level_entities(level_data) -> void:
	for entity_data: Dictionary in level_data.entities:
		var entity = EntityDB.create_entity(entity_data.t_name)
		entity.set_template_data(entity_data)
		entity.insert_entity()


func create_level_tower_holders(level_data) -> void:
	for entity_data: Dictionary in level_data.tower_holders:
		var holder_name: String = C.NAME_TOWER_HOLDER % entity_data.style

		var entity = EntityDB.create_entity(holder_name)
		entity.set_template_data(entity_data)
		entity.insert_entity()
