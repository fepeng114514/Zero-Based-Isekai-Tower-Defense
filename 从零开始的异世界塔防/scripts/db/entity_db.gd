extends Node
signal create_entity_s(entity: Entity)

var templates: Dictionary = load(CS.PATH_TEMPLATES_RESOURCE).templates
var templates_data: Dictionary = {}
var enemies: Array = []
var soldiers: Array = []
var towers: Array = []
var modifiers: Array = []
var auras: Array = []
var entities: Array = []
var last_id: int = 0
var remove_queue: Array[Entity] = []
var insert_queue: Array[Entity] = []
var damage_queue: Array[Entity] = []

func _ready() -> void:
	var incompleted_templates: Dictionary = {}
	#incompleted_templates.merge(Utils.load_json_file(CS.PATH_TEMPLATES))
	incompleted_templates.merge(Utils.load_json_file(CS.PATH_ENEMY_TEMPLATES))
	incompleted_templates.merge(Utils.load_json_file(CS.PATH_TOWER_TEMPLATES))
	#incompleted_templates.merge(Utils.load_json_file(CS.PATH_HERO_TEMPLATES))
	#incompleted_templates.merge(Utils.load_json_file(CS.PATH_BOSS_TEMPLATES))

	for key: String in incompleted_templates.keys():
		templates_data[key] = incompleted_templates[key]

func insert_entity(e: Entity) -> void:
	if e.get_component(CS.CN_ENEMY):
		enemies.append(e)
	elif e.get_component(CS.CN_SOLDIER):
		soldiers.append(e)
	elif e.get_component(CS.CN_TOWER):
		towers.append(e)
	elif e.get_component(CS.CN_MODIFIER):
		modifiers.append(e)
	elif e.get_component(CS.CN_AURA):
		auras.append(e)
		
	entities.append(e)

func create_entity(t_name: String) -> Entity:
	if not templates.get(t_name):
		push_error("模板不存在: %s" % t_name)
	
	var entity: Entity = templates[t_name].instantiate()
	entity.id = last_id
	entity.template_name = t_name
	entity.name = t_name
	
	create_entity_s.emit(entity)

	if t_name == "damage":
		damage_queue.append(entity)
	else:
		insert_queue.append(entity)
		
	print("创建实体： %s（%d）" % [t_name, last_id])
		
	last_id += 1
	return entity
	
func create_damage(target_id: int, min_damage: int, max_damage: int, source_id = -1) -> Entity:
	var d: Entity = create_entity("damage")
	d.target_id = target_id
	d.source_id = source_id
	d.value = Utils.random_int(min_damage, max_damage)
	
	return d
	
func remove_entity(entity: Entity) -> void:
	remove_queue.append(entity)
	
func get_entity_by_id(id: int):
	return entities[id]

func find_enemy_in_range(origin, min_range, max_range) -> Array:
	var targets: Array = enemies.filter(func(e): return is_instance_valid(e) and Utils.is_in_ellipse(e.position, origin, max_range) and not Utils.is_in_ellipse(e.position, origin, min_range))
	
	return targets
#
#func find_enemy_first(origin, min_range, max_range) -> Array:
	#var targets: Array = find_enemy_in_range(origin, min_range, max_range)
	#
	#targets.sort()
	#
	#return target
