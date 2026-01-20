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
		templates[key] = register_template(key, incompleted_templates[key])

func update(delta: float):
	process_insert_queue()
	process_remove_queue()
	process_entities_update(delta)

func register_template(t_name: String, template: Dictionary):
	assert(template.has("components"), "模板 %s 没有任何组件" % t_name)
	var scene: Entity = load(Constants.SCENES_PATH % t_name).instantiate()	

	for component_type in template.components.keys():
		var component_data = template.components[component_type]
		add_component_to_scene(scene, component_type, component_data)
		
	# 打包为场景
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	
	# 清理
	scene.queue_free()
	return packed_scene
	
func add_component_to_scene(scene: Entity, component_type: String, component_data: Dictionary):
	var component_node
	if component_type == "Health":
		component_node = HealthComponent.new()
	elif component_type == "Motion":
		component_node = MotionComponent.new()
		
	# 设置组件属性
	for property in component_data.keys():
		if property is Dictionary:
			property = Utils.dict_to_vector2(property)
			
		component_node.set(property, component_data[property])

	component_node.name = component_type
	scene.add_child(component_node)
	component_node.owner = scene

func create_entity(t_name: String, root: Node):
	assert(templates[t_name], "模板不存在: %s" % t_name)
	
	var entity: Entity = templates[t_name].instantiate()
	entity.node_root = root
	entity.id = last_id
	entity.template_name = t_name
	last_id += 1
	
	insert_queue.append(entity)
		
	return entity
	
func remove_entity(e: Entity):
	remove_queue.append(e)

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
		all_entities.append(entity)

func process_entities_update(delta: float):
	for entity: Entity in all_entities:
		if entity.get("update"):
			entity.update(delta)
