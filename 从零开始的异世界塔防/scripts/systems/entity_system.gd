extends Node

@onready var templates: Dictionary = preload("res://resources/templates_resource.tres").preloaded_templates
@onready var templates_data: Dictionary = {}

@onready var last_id: int = 0

@onready var Enemies: Array = []
@onready var Soldiers: Array = []
@onready var Towers: Array = []
@onready var Modifiers: Array = []
@onready var Auras: Array = []
@onready var All_entities: Array = []
@onready var insert_queue: Array = []
@onready var remove_queue: Array = []
	
func _ready() -> void:
	load_templates_data()

func load_templates_data() -> void:
	var incompleted_templates: Dictionary = {}
	#incompleted_templates.merge(Utils.load_json_file(Constants.TEMPLATES_PATH))
	incompleted_templates.merge(Utils.load_json_file(Constants.ENEMY_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.TOWER_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.HERO_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.BOSS_TEMPLATES_PATH))

	for key: String in incompleted_templates.keys():
		templates_data[key] = incompleted_templates[key]

func _process(delta: float) -> void:
	process_insert_queue()
	process_remove_queue()
	process_entities_update(delta)

func create_entity(t_name: String, root: Node) -> Entity:
	if not templates.get(t_name):
		push_error("模板不存在: %s" % t_name)
	
	var entity: Entity = templates[t_name].instantiate()
	entity.node_root = root
	entity.id = last_id
	entity.template_name = t_name
	last_id += 1
	
	insert_queue.append(entity)
		
	return entity
	
func remove_entity(entity: Entity) -> void:
	remove_queue.append(entity)

func process_remove_queue() -> void:
	for i: int in range(remove_queue.size() - 1, -1, -1):
		var entity: Entity = remove_queue.pop_at(i)
		
		entity.free()

func process_insert_queue() -> void:
	for i: int in range(insert_queue.size() - 1, -1, -1):
		var entity: Entity = insert_queue.pop_at(i)
		
		entity.node_root.add_child(entity)
		
		if entity.has_node("EnemyComponent"):
			Enemies.append(entity)
		elif entity.has_node("SoldierComponent"):
			Soldiers.append(entity)
		elif entity.has_node("TowerComponent"):
			Towers.append(entity)
		elif entity.has_node("ModifierComponent"):
			Modifiers.append(entity)
		elif entity.has_node("AuraComponent"):
			Auras.append(entity)
			
		All_entities.append(entity)

func process_entities_update(delta: float) -> void:
	for entity in All_entities:
		if not is_instance_valid(entity) or not entity.get("update"):
			continue
			
		entity.update(delta)
		
func find_enemy_in_range(origin, radius) -> Array:
	var enemies: Array = Enemies.filter(func(e): return is_instance_valid(e) and Utils.is_in_ellipse(e.position, origin, radius))
	
	return enemies
