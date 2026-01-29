extends Node
signal create_entity_s(entity: Entity)

var templates: Dictionary = TemplatesRes.new().templates
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
	#print("插入实体: %s（%d）" % [e.template_name, e.id])

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

func create_damage(target_id: int, min_damage: int, max_damage: int, source_id = -1, damage_factor = 1) -> Entity:
	var d_name: String = "damage"
	var d: Entity = templates[d_name].instantiate()
	d.target_id = target_id
	d.source_id = source_id
	d.value = Utils.random_int(min_damage, max_damage)
	d.damage_factor = damage_factor
	d.template_name = d_name
	d.name = d_name

	SystemManager.damage_queue.append(d)
		
	return d
	
func insert_entity(e: Entity) -> void:
	for system: System in SystemManager.systems:
		var system_func = system.get("on_insert")

		if not system_func.call(e):
			return
		
	SystemManager.insert_queue.append(e)

func remove_entity(e: Entity) -> void:
	for system: System in SystemManager.systems:
		var system_func = system.get("on_remove")
		system_func.call(e)

	SystemManager.remove_queue.append(e)
	e.removed = true
	e.visible = false
	print("移除实体： %s（%d）" % [e.template_name, e.id])

func get_entity_by_id(id: int):
	return entities[id]

func sort_targets(targets: Array, sort_type: String, origin: Vector2, reversed: bool = false):
	if reversed:
		match sort_type:
			CS.SORT_TYPE_PROGRESS: targets.sort_custom(func(e1, e2): return e1.has_c(CS.CN_NAV_PATH) and e1.get_c(CS.CN_NAV_PATH).progress_ratio < e2.get_c(CS.CN_NAV_PATH).progress_ratio)
			CS.SORT_TYPE_HP: targets.sort_custom(func(e1, e2): return e1.has_c(CS.CN_HEALTH) and e1.get_c(CS.CN_HEALTH).hp < e2.get_c(CS.CN_HEALTH).hp)
			CS.SORT_TYPE_DIST: targets.sort_custom(func(e1, e2): return e1.position.distance_squared_to(origin) < e2.position.distance_squared_to(origin))
			CS.SORT_TYPE_BLOCK_LEVEL: targets.sort_custom(func(e1, e2): return e1.has_c(CS.CN_MELEE) and e1.get_c(CS.CN_MELEE).block_level < e2.get_c(CS.CN_MELEE).block_level)
	else:
		match sort_type:
			CS.SORT_TYPE_PROGRESS: targets.sort_custom(func(e1, e2): return e1.has_c(CS.CN_NAV_PATH) and e1.get_c(CS.CN_NAV_PATH).progress_ratio > e2.get_c(CS.CN_NAV_PATH).progress_ratio)
			CS.SORT_TYPE_HP: targets.sort_custom(func(e1, e2): return e1.has_c(CS.CN_HEALTH) and e1.get_c(CS.CN_HEALTH).hp > e2.get_c(CS.CN_HEALTH).hp)
			CS.SORT_TYPE_DIST: targets.sort_custom(func(e1, e2): return e1.position.distance_squared_to(origin) > e2.position.distance_squared_to(origin))
			CS.SORT_TYPE_BLOCK_LEVEL: targets.sort_custom(func(e1, e2): return e1.has_c(CS.CN_MELEE) and e1.get_c(CS.CN_MELEE).block_level > e2.get_c(CS.CN_MELEE).block_level)

func find_enemy_in_range(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null) -> Array:
	return enemies.filter(func(e): return is_instance_valid(e) and not (bans & e.flags or e.bans & flags) and (Utils.is_in_ellipse(e.position, origin, max_range) and not Utils.is_in_ellipse(e.position, origin, min_range)) and (not filter or filter.call(e, origin)))

func find_enemy_sort_with_progress(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_PROGRESS, origin)
	return targets
	
func find_enemy_sort_with_dist(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_DIST, origin)
	
	return targets
	
func find_enemy_sort_with_hp(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_HP, origin)
	
	return targets
	
func find_enemy_sort_with_block_level(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_BLOCK_LEVEL, origin)
	
	return targets

func find_enemy_first(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_sort_with_progress(origin, min_range, max_range, flags, bans, filter)

	return targets[0] if targets else null

func find_enemy_last(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_sort_with_progress(origin, min_range, max_range, flags, bans, filter)

	return targets[-1] if targets else null

func find_enemy_nearst(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_sort_with_dist(origin, min_range, max_range, flags, bans, filter)

	return targets[0] if targets else null

func find_enemy_farthest(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_sort_with_dist(origin, min_range, max_range, flags, bans, filter)[-1]

	return targets[-1] if targets else null

func find_enemy_strongest(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_sort_with_hp(origin, min_range, max_range, flags, bans, filter)[0]
	
	return targets[0] if targets else null
	
func find_enemy_weakest(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_enemy_sort_with_dist(origin, min_range, max_range, flags, bans, filter)[-1]

	return targets[-1] if targets else null

func find_soldier_in_range(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null) -> Array:
	return soldiers.filter(func(e): return is_instance_valid(e) and not (bans & e.flags or e.bans & flags) and (Utils.is_in_ellipse(e.position, origin, max_range) and not Utils.is_in_ellipse(e.position, origin, min_range)) and (not filter or filter.call(e, origin)))

func find_soldier_sort_with_progress(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_PROGRESS, origin)
	
	return targets
	
func find_soldier_sort_with_dist(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_DIST, origin)
	
	return targets
	
func find_soldier_sort_with_hp(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_HP, origin)
	
	return targets

func find_soldier_sort_with_block_level(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_in_range(origin, min_range, max_range, flags, bans, filter)
	sort_targets(targets, CS.SORT_TYPE_BLOCK_LEVEL, origin)
	
	return targets

func find_soldier_first(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_sort_with_progress(origin, min_range, max_range, flags, bans, filter)

	return targets[0] if targets else null

func find_soldier_last(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_sort_with_progress(origin, min_range, max_range, flags, bans, filter)

	return targets[-1] if targets else null

func find_soldier_nearst(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_sort_with_dist(origin, min_range, max_range, flags, bans, filter)

	return targets[0] if targets else null

func find_soldier_farthest(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_sort_with_dist(origin, min_range, max_range, flags, bans, filter)

	return targets[-1] if targets else null

func find_soldier_strongest(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_sort_with_hp(origin, min_range, max_range, flags, bans, filter)
	
	return targets[0] if targets else null
	
func find_soldier_weakest(origin: Vector2, min_range: int, max_range: int, flags: int, bans: int, filter = null):
	var targets: Array = find_soldier_sort_with_dist(origin, min_range, max_range, flags, bans, filter)

	return targets[-1] if targets else null

func search_target(search_mode, position, min_range, max_range, flags, bans, filter = null):
	var target
	
	match search_mode:
		CS.SEARCH_MODE_ENEMY_FIRST: target = find_enemy_first(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_LAST: target = find_enemy_last(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_NEARST: target = find_enemy_nearst(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_FARTHEST: target = find_enemy_farthest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_STRONGEST: target = find_enemy_strongest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_WEAKEST: target = find_enemy_weakest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_FIRST: target = find_soldier_first(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_LAST: target = find_soldier_last(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_NEARST: target = find_soldier_nearst(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_FARTHEST: target = find_soldier_farthest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_STRONGEST: target = find_soldier_strongest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_WEAKEST: target = find_soldier_weakest(position, min_range, max_range, flags, bans, filter)
	
	return target

func search_targets_in_range(search_mode, position, min_range, max_range, flags, bans, filter = null):
	var target
	
	match search_mode:
		CS.SEARCH_MODE_ENEMY_FIRST: target = find_enemy_first(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_LAST: target = find_enemy_last(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_NEARST: target = find_enemy_nearst(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_FARTHEST: target = find_enemy_farthest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_STRONGEST: target = find_enemy_strongest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_ENEMY_WEAKEST: target = find_enemy_weakest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_FIRST: target = find_soldier_first(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_LAST: target = find_soldier_last(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_NEARST: target = find_soldier_nearst(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_FARTHEST: target = find_soldier_farthest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_STRONGEST: target = find_soldier_strongest(position, min_range, max_range, flags, bans, filter)
		CS.SEARCH_MODE_SOLDIER_WEAKEST: target = find_soldier_weakest(position, min_range, max_range, flags, bans, filter)
	
	return target
