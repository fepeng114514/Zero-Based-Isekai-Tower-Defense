extends System
class_name LevelSystem

func _init() -> void:
	var current_level_data = LevelManager.levels_data[GlobalStore.level_idx]
	create_level_entities(current_level_data)
	# create_level_tower_holders(current_level_data)

func on_update(delta: float) -> bool:
	return true

func create_level_entities(current_level_data) -> void:
	for entity_data: Dictionary in current_level_data.entities:
		var entity = EntityDB.create_entity(entity_data.t_name)
		entity.set_template_data(entity_data)
		EntityDB.insert_entity(entity)

func create_level_tower_holders(current_level_data) -> void:
	for entity_data: Dictionary in current_level_data.tower_holders:
		var holder_name: String = CS.NAME_TOWER_HOLDER % entity_data.style

		var entity = EntityDB.create_entity(holder_name)
		entity.set_template_data(entity_data)
		EntityDB.insert_entity(entity)
