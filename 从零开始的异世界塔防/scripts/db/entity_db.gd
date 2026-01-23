extends Node

var templates: Dictionary = load("res://resources/templates_resource.tres").preloaded_templates
var templates_data: Dictionary = {}
var enemies: Array = []
var soldiers: Array = []
var towers: Array = []
var modifiers: Array = []
var auras: Array = []
var entities: Array = []
var last_id: int = 0
var remove_queue: Array = []
var insert_queue: Array = []

func _init() -> void:
	var incompleted_templates: Dictionary = {}
	#incompleted_templates.merge(Utils.load_json_file(Constants.TEMPLATES_PATH))
	incompleted_templates.merge(Utils.load_json_file(Constants.ENEMY_TEMPLATES_PATH))
	incompleted_templates.merge(Utils.load_json_file(Constants.TOWER_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.HERO_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.BOSS_TEMPLATES_PATH))

	for key: String in incompleted_templates.keys():
		templates_data[key] = incompleted_templates[key]

func insert_entity(entity: Entity) -> void:
	if entity.has_node("EnemyComponent"):
		enemies.append(entity)
	elif entity.has_node("SoldierComponent"):
		soldiers.append(entity)
	elif entity.has_node("TowerComponent"):
		towers.append(entity)
	elif entity.has_node("ModifierComponent"):
		modifiers.append(entity)
	elif entity.has_node("AuraComponent"):
		auras.append(entity)
		
	entities.append(entity)

func create_entity(t_name: String) -> Entity:
	if not templates.get(t_name):
		push_error("模板不存在: %s" % t_name)
	
	var entity: Entity = templates[t_name].instantiate()
	entity.id = last_id
	entity.template_name = t_name
	last_id += 1
	
	insert_queue.append(entity)
		
	return entity
	
func remove_entity(entity: Entity) -> void:
	remove_queue.append(entity)

func find_enemy_in_range(origin, radius) -> Array:
	var targets: Array = enemies.filter(func(e): return is_instance_valid(e) and Utils.is_in_ellipse(e.position, origin, radius))
	
	return targets
