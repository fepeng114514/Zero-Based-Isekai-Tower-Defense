extends Node
signal remove_entity_signal
signal insert_entity_signal

var last_id: int

var templates: Dictionary
var enemies: Array
var soldiers: Array
var towers: Array
var modifiers: Array
var auras: Array
var all_entities: Array
var insert_queue: Array
var remove_queue: Array

func init():
	last_id = 0

	templates = {}
	enemies = []
	soldiers = []
	towers = []
	modifiers = []
	auras = []
	all_entities = []
	insert_queue = []
	remove_queue = []
	
	load_templates()

func load_templates():
	var incompleted_templates: Dictionary = {}
	#incompleted_templates.merge(Utils.load_json_file(Constants.BASIC_TEMPLATES_PATH))
	incompleted_templates.merge(Utils.load_json_file(Constants.ENEMY_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.TOWER_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.HERO_TEMPLATES_PATH))
	#incompleted_templates.merge(Utils.load_json_file(Constants.BOSS_TEMPLATES_PATH))

	for key in incompleted_templates.keys():
		var inc_template: Dictionary = incompleted_templates[key]
		
		templates[key] = register_template(key, inc_template)

func inheritance_template(inc_template: Dictionary):
	var based_template_name: String = inc_template.get(inc_template.base)
	
	if not based_template_name:
		return
		
	assert(templates.get(based_template_name), "未找到续承的父模板 %s" % based_template_name)

	inc_template.merge(inc_template[based_template_name])

func update(delta: float):
	process_insert_queue()
	process_remove_queue()
	process_entities_update(delta)

func register_template(t_name: String, template: Dictionary) -> PackedScene:
	assert(t_name not in templates, "模板 %s 已存在" % t_name)
	
	var scene: Entity = load(Constants.SCENES_PATH % t_name).instantiate()
	var components_container: Component = Component.new()
	components_container.name = "Components"

	for component_type in template.components.keys():
		var component_data: Dictionary = template.components[component_type]

		if component_type == "Custom":
			for property in component_data.keys():
				var property_value = component_data[property]
				
				if property_value is Dictionary:
					property_value = Utils.dict_to_vector2(property_value)
					
				components_container.custom[property] = property_value
				
			continue
		
		var component_node: Node = get_component_node(component_type, component_data)
		component_node.name = component_type
		components_container.add_child(component_node)
		component_node.owner = scene
		print(component_node.owner)
	scene.add_child(components_container)
	components_container.owner = scene
	
	# 打包为场景
	var packed_scene: PackedScene = PackedScene.new()
	packed_scene.pack(scene)

	return packed_scene
	
func get_component_node(component_type: String, component_data: Dictionary) -> Node:
	var node
	if component_type == "Health":
		node = HealthComponent.new()
	elif component_type == "Motion":
		node = MotionComponent.new()
		
	# 设置组件属性
	for property in component_data.keys():
		var property_value = component_data[property]

		if property_value is Dictionary:
			property_value = Utils.dict_to_vector2(property_value)
			
		node.set(property, property_value)

	return node

func create_entity(t_name: String, root: Node) -> Entity:
	assert(templates[t_name], "模板不存在: %s" % t_name)
	
	var entity: Entity = templates[t_name].instantiate()
	entity.node_root = root
	entity.id = last_id
	entity.template_name = t_name
	last_id += 1
	
	insert_queue.append(entity)
		
	return entity
	
func remove_entity(entity: Entity):
	remove_queue.append(entity)

func process_remove_queue():
	for i in range(remove_queue.size() - 1, -1, -1):
		var entity = remove_queue.pop_at(i)
		
		emit_signal("remove_entity", entity.id)
		entity.free()

func process_insert_queue():
	for i in range(insert_queue.size() - 1, -1, -1):
		var entity = insert_queue.pop_at(i)
		
		emit_signal("insert_entity", entity.id)
		entity.node_root.add_child(entity)
		
		if entity.has_node("Enemy"):
			enemies.append(entity)
		elif entity.has_node("Soldier"):
			soldiers.append(entity)
		elif entity.has_node("Tower"):
			towers.append(entity)
		elif entity.has_node("Modifier"):
			modifiers.append(entity)
		elif entity.has_node("Aura"):
			auras.append(entity)
			
		all_entities.append(entity)

func process_entities_update(delta: float):
	for entity in all_entities:
		if not is_instance_valid(entity) or not entity.get("update"):
			continue
			
		entity.update(delta)
