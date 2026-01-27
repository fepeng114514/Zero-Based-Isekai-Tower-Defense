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

func _ready() -> void:
	var incompleted_templates: Dictionary = {}
	#incompleted_templates.merge(Utils.load_json_file(CS.PATH_TEMPLATES))
	incompleted_templates.merge(Utils.load_json_file(CS.PATH_ENEMY_TEMPLATES))
	incompleted_templates.merge(Utils.load_json_file(CS.PATH_TOWER_TEMPLATES))
	#incompleted_templates.merge(Utils.load_json_file(CS.PATH_HERO_TEMPLATES))
	#incompleted_templates.merge(Utils.load_json_file(CS.PATH_BOSS_TEMPLATES))

	for key: String in incompleted_templates.keys():
		templates_data[key] = incompleted_templates[key]

func insert(e: Entity) -> void:
	if entities:
		var entities_len: int = entities.size()
		if e.id != entities_len:
			push_error("实体列表长度未与实体 id 对应： id %d，长度 %d" % [e.id, entities_len])
	
	if e.has_c(CS.CN_ENEMY):
		enemies.append(e)
	elif e.has_c(CS.CN_SOLDIER):
		soldiers.append(e)
	elif e.has_c(CS.CN_TOWER):
		towers.append(e)
	elif e.has_c(CS.CN_MODIFIER):
		modifiers.append(e)
	elif e.has_c(CS.CN_AURA):
		auras.append(e)
		
	entities.append(e)
	print("插入实体 %s（%d）" % [e.template_name, e.id])

func create_entity(t_name: String) -> Entity:
	var t = templates.get(t_name)

	if not t:
		push_error("模板不存在: %s" % t_name)
		return
	
	var e: Entity = t.instantiate()
	e.id = last_id
	e.template_name = t_name
	e.name = t_name
	e.visible = false
	
	create_entity_s.emit(e)

	print("创建实体： %s（%d）" % [t_name, last_id])
	last_id += 1
		
	return e

func create_damage(target_id: int, min_damage: int, max_damage: int, source_id = -1) -> Entity:
	var d_name: String = "damage"
	var d: Entity = templates[d_name].instantiate()
	d.target_id = target_id
	d.source_id = source_id
	d.value = Utils.random_int(min_damage, max_damage)
	d.template_name = d_name
	d.name = d_name

	SystemManager.damage_queue.append(d)
	print("创建伤害, 目标: %s，来源: %s，值: %s" % [target_id, source_id, d.value])
		
	return d
	
func insert_entity(e: Entity) -> void:
	for system: System in SystemManager.systems:
		var system_func = system.get("on_insert")
		
		if not system_func:
			continue
			
		if not system_func.call(e):
			return
		
	SystemManager.insert_queue.append(e)

func remove_entity(e: Entity) -> void:
	for system: System in SystemManager.systems:
		var system_func = system.get("on_remove")
		
		if not system_func:
			continue
			
		system_func.call(e)

	SystemManager.remove_queue.append(e)
	e.removed = true
	e.visible = false
	print("移除实体： %s（%d）" % [e.template_name, e.id])

func get_entity_by_id(id: int):
	return entities[id]

func find_enemy_in_range(origin, min_range, max_range) -> Array:
	var filter = func(e): return is_instance_valid(e) and Utils.is_in_ellipse(e.position, origin, max_range) and not Utils.is_in_ellipse(e.position, origin, min_range)
	var targets: Array = enemies.filter(filter)
	
	return targets

func find_enemy_first(origin, min_range, max_range):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range)
	
	if not targets:
		return null

	var filter = func(e1, e2): return e1.get_c(CS.CN_NAV_PATH).progress_ratio > e2.get_c(CS.CN_NAV_PATH).progress_ratio
	targets.sort_custom(filter)
	
	return targets[0]

func find_enemy_last(origin, min_range, max_range):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range)
	
	if not targets:
		return null

	var filter = func(e1, e2): return e1.get_c(CS.CN_NAV_PATH).progress_ratio < e2.get_c(CS.CN_NAV_PATH).progress_ratio
	targets.sort_custom(filter)
	
	return targets[0]

func find_enemy_strong(origin, min_range, max_range):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range)
	
	if not targets:
		return null

	var filter = func(e1, e2): return e1.get_c(CS.CN_HEALTH).hp > e2.get_c(CS.CN_HEALTH).hp
	targets.sort_custom(filter)
	
	return targets[0]
	
func find_enemy_weak(origin, min_range, max_range):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range)
	
	if not targets:
		return null

	var filter = func(e1, e2): return e1.get_c(CS.CN_HEALTH).hp < e2.get_c(CS.CN_HEALTH).hp
	targets.sort_custom(filter)
	
	return targets[0]
