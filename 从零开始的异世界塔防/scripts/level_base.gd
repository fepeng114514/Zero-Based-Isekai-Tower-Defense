extends Node2D
class_name LevelBase

@export var level_idx: int = -1
var level_mode: int = 0
var level_data: Dictionary = {}
@onready var store = $Store

func _ready() -> void:
	level_data = Utils.load_json_file(CS.PATH_LEVELS_DATA % level_idx)
	create_level_entities()
	# create_level_tower_holders()

func _process(delta: float) -> void:
	pass

func create_level_entities() -> void:
	for e: Dictionary in level_data.entities:
		var entity = EntityDB.create_entity(e.name)
		entity.position = Utils.dict_to_vector2(e.position)

func create_level_tower_holders() -> void:
	for e: Dictionary in level_data.tower_holders:
		var holder_name: String = CS.NAME_TOWER_HOLDER % e.style

		var entity = EntityDB.create_entity(holder_name)
		entity.position = Utils.dict_to_vector2(e.position)
