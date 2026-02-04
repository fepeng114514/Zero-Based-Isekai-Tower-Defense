extends Node
signal create_entity_s(entity: Entity)

var templates_scenes: Dictionary = {}
var components_scripts: Dictionary = {}
var templates_data: Dictionary = {}
var components_data: Dictionary = {}
var entities_scripts: Dictionary = {}
var enemies: Array = []
var friendlys: Array = []
var towers: Array = []
var modifiers: Array = []
var auras: Array = []
var entities: Array = []
var last_id: int = 0

func clean():
	templates_scenes = {}
	components_scripts = {}
	templates_data = {}
	components_data = {}
	entities_scripts = {}
	enemies = []
	friendlys = []
	towers = []
	modifiers = []
	auras = []
	entities = []
	last_id = 0
	
	_ready()

func _ready() -> void:
	for base_path in CS.PATH_TEMPLATES:
		templates_data.merge(ConfigManager.get_config_data(base_path))
	
	components_data = ConfigManager.get_config_data(CS.PATH_COMPOTENTS)
	
	for t_name in templates_data.keys():
		var template_scene_path: String = CS.PATH_TEMPLATES_SCENES % t_name
		if ResourceLoader.exists(template_scene_path):
			templates_scenes[t_name] = load(template_scene_path)
			
		var entity_script_path: String = CS.PATH_ENTITIES_SCRIPTS % t_name
		if ResourceLoader.exists(entity_script_path):
			entities_scripts[t_name] = load(entity_script_path)
		
	for c_name in components_data.keys():
		var component_script_path: String = CS.PATH_COMPONENTS_SCRIPTS % (c_name + "_component")
		if ResourceLoader.exists(component_script_path):
			components_scripts[c_name] = load(component_script_path)

func insert(e: Entity) -> void:
	if entities:
		var entities_len: int = entities.size()
		if e.id != entities_len:
			push_error("实体列表长度未与实体 id 对应： id %d，长度 %d" % [e.id, entities_len])
	
	if e.flags & CS.FLAG_ENEMY:
		enemies.append(e)
	if e.flags & CS.FLAG_FRIENDLY:
		friendlys.append(e)
	if e.flags & CS.FLAG_TOWER:
		towers.append(e)
	if e.flags & CS.FLAG_MODIFIER:
		modifiers.append(e)
	if e.flags & CS.FLAG_AURA:
		auras.append(e)
		
	entities.append(e)
	#print("插入实体: %s（%d）" % [e.template_name, e.id])

func create_entity(t_name: String) -> Entity:
	var t = get_templates_scenes(t_name)

	var e: Entity
	if not t:
		e = Entity.new()
	else:
		e = t.instantiate()
		
	var entity_script = get_entity_script(t_name)
	
	if entity_script:
		e.set_script(entity_script)
		
	# 待实现数据的缓存
	var template_data = get_template_data(t_name)
	e.set_template_data(template_data)
		
	e.id = last_id
	e.template_name = t_name
	e.name = t_name
	e.visible = false
	
	if not SystemManager.process_systems("on_create", e):
		return e

	create_entity_s.emit(e)
	
	print("创建实体： %s（%d）" % [t_name, last_id])
	last_id += 1
		
	return e

func create_damage(target_id: int, min_damage: int, max_damage: int, source_id: int = -1, damage_factor: float = 1) -> Damage:
	var d_name: String = "damage"
	var d: Entity = Damage.new()
	
	d.target_id = target_id
	d.source_id = source_id
	d.value = Utils.random_int(min_damage, max_damage)
	d.damage_factor = damage_factor
	d.template_name = d_name

	SystemManager.damage_queue.append(d)
		
	return d
	
func insert_entity(e: Entity) -> void:
	var insert_queue: Array = SystemManager.insert_queue
	insert_queue.append(e)
	
	if not SystemManager.process_systems("on_insert", e):
		insert_queue.pop_back()

func remove_entity(e: Entity) -> void:
	if not SystemManager.process_systems("on_remove", e):
		return

	SystemManager.remove_queue.append(e)
	e.removed = true
	e.visible = false
	print("移除实体： %s（%d）" % [e.template_name, e.id])

func get_entity_by_id(id: int):
	return entities[id]
	
func get_component_script(c_name: String, deep: bool = false):
	var c_data = components_scripts.get(c_name)
	
	if c_data == null:
		push_error("未找到组件： %s" % c_name)
		return null
		
	if not c_data:
		return null

	if deep:
		return c_data.duplicate_deep()
	
	return c_data


func get_component_data(c_name: String, deep: bool = true) -> Dictionary:
	var c_data = components_data.get(c_name)
	
	if c_data == null:
		push_error("未找到组件数据： %s" % c_name)
		return {}
		
	if not c_data:
		return {}

	if deep:
		return c_data.duplicate_deep()
	
	return c_data

func get_template_data(t_name: String, deep: bool = true) -> Dictionary:
	var template_data = templates_data.get(t_name)
	
	if template_data == null:
		push_error("未找到模板数据： %s" % t_name)
		return {}
		
	if not template_data:
		return {}
		
	if deep:
		return template_data.duplicate_deep()
	
	return template_data
	
func get_templates_scenes(t_name: String, deep: bool = false):
	var template_scenes = templates_scenes.get(t_name)
	
	if template_scenes == null:
		return null
		
	if not template_scenes:
		return null
		
	if deep:
		return template_scenes.duplicate()
	
	return template_scenes
	
func get_entity_script(t_name: String, deep: bool = false):
	var entity_script = entities_scripts.get(t_name)
	
	if entity_script == null:
		return null
		
	if not entity_script:
		return null
		
	if deep:
		return entity_script.duplicate()
	
	return entity_script

func sort_targets(targets: Array, sort_type: String, origin: Vector2, reversed: bool = false):
	var sort_functions = {
		CS.SORT_TYPE_PROGRESS: func(e1, e2):
			var p1 = e1.get_c(CS.CN_NAV_PATH).progress_ratio if e1.has_c(CS.CN_NAV_PATH) else 0
			var p2 = e2.get_c(CS.CN_NAV_PATH).progress_ratio if e2.has_c(CS.CN_NAV_PATH) else 0
			return p1 > p2 if not reversed else p1 < p2,
		
		CS.SORT_TYPE_HP: func(e1, e2):
			var h1 = e1.get_c(CS.CN_HEALTH).hp if e1.has_c(CS.CN_HEALTH) else 0
			var h2 = e2.get_c(CS.CN_HEALTH).hp if e2.has_c(CS.CN_HEALTH) else 0
			return h1 > h2 if not reversed else h1 < h2,
		
		CS.SORT_TYPE_DIST: func(e1, e2):
			var d1 = e1.position.distance_squared_to(origin)
			var d2 = e2.position.distance_squared_to(origin)
			return d1 > d2 if not reversed else d1 < d2
	}
	
	if sort_type in sort_functions:
		targets.sort_custom(sort_functions[sort_type])

func find_targets_in_range(target_pool: Array, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null) -> Array:
	return target_pool.filter(func(e): return is_instance_valid(e) and not (bans & e.flags or e.bans & flags) and Utils.is_in_ellipse(e.position, origin, max_range) and not Utils.is_in_ellipse(e.position, origin, min_range) and (not filter or filter.call(e, origin)))

func find_sorted_targets(target_pool: Array, sort_type: String, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null, reversed: bool = false) -> Array:
	var targets = find_targets_in_range(target_pool, origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, sort_type, origin, reversed)
	return targets

func find_extreme_target(target_pool: Array, sort_type: String, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null, reversed: bool = false):
	var targets = find_targets_in_range(target_pool, origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, sort_type, origin, reversed)
	return targets[0] if targets else null

func find_enemies_in_range(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null) -> Array:
	return find_targets_in_range(enemies, origin, min_range, max_range, flags, bans, filter)

func find_sorted_enemies(sort_type: String, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null, reversed: bool = false) -> Array:
	return find_sorted_targets(enemies, sort_type, origin, min_range, max_range, flags, bans, filter, reversed)

func find_extreme_enemy(sort_type: String, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null, reversed: bool = false):
	return find_extreme_target(enemies, sort_type, origin, min_range, max_range, flags, bans, filter, reversed)

func find_friendlys_in_range(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null) -> Array:
	return find_targets_in_range(friendlys, origin, min_range, max_range, flags, bans, filter)

func find_sorted_friendlys(sort_type: String, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null, reversed: bool = false) -> Array:
	return find_sorted_targets(friendlys, sort_type, origin, min_range, max_range, flags, bans, filter, reversed)

func find_extreme_friendly(sort_type: String, origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null, reversed: bool = false):
	return find_extreme_target(friendlys, sort_type, origin, min_range, max_range, flags, bans, filter, reversed)

func search_target(search_mode, origin, min_range, max_range, flags, bans, filter = null):
	match search_mode:
		CS.SEARCH_MODE_ENEMY_FIRST: return find_extreme_enemy(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_LAST: return find_extreme_enemy(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_ENEMY_NEARST: return find_extreme_enemy(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_FARTHEST: return find_extreme_enemy(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_ENEMY_STRONGEST: return find_extreme_enemy(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_WEAKEST: return find_extreme_enemy(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_FRIENDLY_FIRST: return find_extreme_friendly(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_FRIENDLY_LAST: return find_extreme_friendly(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_FRIENDLY_NEARST: return find_extreme_friendly(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_FRIENDLY_FARTHEST: return find_extreme_friendly(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_FRIENDLY_STRONGEST: return find_extreme_friendly(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_FRIENDLY_WEAKEST: return find_extreme_friendly(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter, true)

func search_targets_in_range(search_mode, origin, min_range, max_range, flags, bans, filter = null):
	match search_mode:
		CS.SEARCH_MODE_ENEMY_FIRST: return find_sorted_enemies(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_LAST: return find_sorted_enemies(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_ENEMY_NEARST: return find_sorted_enemies(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_FARTHEST: return find_sorted_enemies(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_ENEMY_STRONGEST: return find_sorted_enemies(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_WEAKEST: return find_sorted_enemies(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_FRIENDLY_FIRST: return find_sorted_friendlys(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_FRIENDLY_LAST: return find_sorted_friendlys(CS.SORT_TYPE_PROGRESS, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_FRIENDLY_NEARST: return find_sorted_friendlys(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_FRIENDLY_FARTHEST: return find_sorted_friendlys(CS.SORT_TYPE_DIST, origin, min_range, max_range, flags, bans, filter, true)
		CS.SEARCH_MODE_FRIENDLY_STRONGEST: return find_sorted_friendlys(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_FRIENDLY_WEAKEST: return find_sorted_friendlys(CS.SORT_TYPE_HP, origin, min_range, max_range, flags, bans, filter, true)
