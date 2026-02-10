extends System

func _initialize() -> void:
	var level_data = LevelManager.levels_data[GlobalStore.level_idx]

	if level_data.has("max_subpath"):
		PathDB.max_subpath = level_data.max_subpath
	if level_data.has("subpath_spacing"):
		PathDB.subpath_spacing = level_data.subpath_spacing
	if level_data.has("node_count"):
		PathDB.node_count = level_data.node_count
	create_level_entities(level_data)
	# create_level_tower_holders(level_data)

func create_level_entities(level_data) -> void:
	for entity_data: Dictionary in level_data.entities:
		var entity = E.create_entity(entity_data.t_name)
		entity.set_template_data(entity_data)
		entity.insert_entity()

func create_level_tower_holders(level_data) -> void:
	for entity_data: Dictionary in level_data.tower_holders:
		var holder_name: String = CS.NAME_TOWER_HOLDER % entity_data.style

		var entity = E.create_entity(holder_name)
		entity.set_template_data(entity_data)
		entity.insert_entity()
