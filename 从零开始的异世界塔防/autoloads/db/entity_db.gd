extends Node
signal create_entity_s(entity: Entity)

"""实体数据库:
	存储所有实体与相关数据
	待优化:
		1. 索敌的空间索引优化
		2. 对象池
"""

#region 属性
var templates_scenes: Dictionary[String, PackedScene] = {}
var components_scripts: Dictionary[String, GDScript] = {}
var entities_scripts: Dictionary[String, GDScript] = {}
var templates_data: Dictionary[String, Dictionary] = {}
var components_data: Dictionary = {}
var type_groups: Dictionary[String, Array] = {
	"enemies": [],
	"friendlys": [],
	"towers": [],
	"modifiers": [],
	"auras": [],
	"bullets": [],
}
var component_groups: Dictionary[String, Array] = {}
var entities: Array = []
var _dirty_entities_ids: Array[int] = []
var last_id: int = 0
var cached_templates: Dictionary = {}
#endregion


func load() -> void:
	templates_scenes = {}
	components_scripts = {}
	templates_data = {}
	components_data = {}
	entities_scripts = {}
	type_groups = {
		"enemies": [],
		"friendlys": [],
		"towers": [],
		"modifiers": [],
		"auras": [],
		"bullets": [],
	}
	component_groups = {}
	entities = []
	_dirty_entities_ids = []
	last_id = 0
	
	_load_templates_data()
	_load_components_data()
	

## 加载实体模板数据
func _load_templates_data() -> void:
	var templates_group: Dictionary = ConfigMgr.get_config_data(C.PATH_TEMPLATES_DATA)
	for group: Dictionary in templates_group.values():
		templates_data.merge(group)
	
	for t_name: String in templates_data.keys():
		var template_scene_path: String = C.PATH_ENTITIES_SCENES % t_name
		if ResourceLoader.exists(template_scene_path):
			templates_scenes[t_name] = load(template_scene_path)
			
		var entity_script_path: String = C.PATH_ENTITIES_SCRIPTS % t_name
		if ResourceLoader.exists(entity_script_path):
			entities_scripts[t_name] = load(entity_script_path)
		

## 加载组件数据
func _load_components_data() -> void:
	components_data = ConfigMgr.get_config_data(C.PATH_COMPONENTS_DATA)
	
	for c_name: String in components_data.keys():
		var component_script_path: String = (
			C.PATH_COMPONENTS % (c_name + "_component")
		)
		if ResourceLoader.exists(component_script_path):
			components_scripts[c_name] = load(component_script_path)


## 标记新增加或移除的实体
func mark_entity_dirty_id(id: int) -> void:
	if _dirty_entities_ids.has(id):
		return
		
	_dirty_entities_ids.append(id)


#region 创建实体相关
## 创建实体
func create_entity(t_name: String) -> Entity:
	var t: PackedScene = get_templates_scenes(t_name)

	var e: Entity
	if not t:
		e = Entity.new()
	else:
		e = t.instantiate()
		
	var entity_script = get_entity_script(t_name)
	if entity_script:
		e.set_script(entity_script)
		
	# 待实现数据的缓存，这里会多次解析 json 模板数据
	var template_data = get_template_data(t_name)
	e.set_template_data(template_data)
		
	e.id = last_id
	e.template_name = t_name
	e.name = t_name
	e.visible = false
	
	# 调用所有系统的准备插入回调函数，遇到返回 false 的系统不插入实体
	if not SystemMgr.call_systems("_on_ready_insert", e):
		return e

	create_entity_s.emit(e)
	Log.debug("创建实体: %s(%d)", [t_name, last_id])
	last_id += 1
		
	return e


## 批量创建实体
func create_entities(t_names: Array, auto_insert: bool = true) -> Array[Entity]:
	var created_entities: Array[Entity] = []

	for t_name: String in t_names:
		var e: Entity = create_entity(t_name)

		if auto_insert:
			e.insert_entity()

		created_entities.append(e)

	return created_entities
	

## 创建实体在指定位置
func create_entities_at_pos(t_names: Array, pos: Vector2, auto_insert: bool = true) -> Array[Entity]:
	var created_entities: Array[Entity] = []

	for t_name: String in t_names:
		var e: Entity = create_entity(t_name)
		e.set_pos(pos)

		if auto_insert:
			e.insert_entity()

		created_entities.append(e)

	return created_entities


## 创建伤害实体
func create_damage(
		target_id: int,
		min_damage: float,
		max_damage: float,
		damage_type: int = C.DAMAGE_PHYSICAL,
		source_id: int = -1,
		damage_factor: float = 1
	) -> Damage:
	var d_name: String = "damage"
	var d := Damage.new()
	
	d.target_id = target_id
	d.source_id = source_id
	d.damage_type = damage_type
	d.value = randi_range(min_damage, max_damage)
	d.damage_factor = damage_factor
	d.template_name = d_name

	SystemMgr.damage_queue.append(d)
		
	return d


## 批量创建状态效果实体
func create_mods(
		target_id: int,
		source_id: int = -1,
		mods: Array = [],
		auto_insert: bool = true
	) -> Array[Entity]:

	var created_mods: Array[Entity] = []

	for t_name: String in mods:
		var mod = create_entity(t_name)
		mod.target_id = target_id
		mod.source_id = source_id

		if auto_insert:
			mod.insert_entity()

		created_mods.append(mod)

	return created_mods


## 批量创建光环实体
func create_auras(
		source_id: int = -1,
		auras: Array = [],
		auto_insert: bool = true
	) -> Array[Entity]:

	var created_auras: Array[Entity] = []

	for t_name: String in auras:
		var aura = create_entity(t_name)
		aura.source_id = source_id

		if auto_insert:
			aura.insert_entity()

		created_auras.append(aura)

	return created_auras
#endregion


#region 索引相关
## 根据组名获取组内所有实体
func get_entities_group(group_name: String) -> Array:
	if group_name in type_groups:
		return type_groups[group_name]
	
	if group_name in component_groups:
		return component_groups[group_name]

	return []


## 根据 id 索引实体
func get_entity_by_id(id: int) -> Variant:
	if id == -1:
		return null

	var e = entities.get(id)

	if not is_instance_valid(e):
		return null

	return e
	

## 获取组件脚本
func get_component_script(c_name: String, deep: bool = false) -> GDScript:
	var c_scripts: GDScript = components_scripts.get(c_name)
	
	if c_scripts == null:
		Log.error("未找到组件: %s", c_name)
		return null
		
	if not c_scripts:
		return null

	if deep:
		return c_scripts.duplicate_deep()
	
	return c_scripts


## 获取组件数据
func get_component_data(c_name: String, deep: bool = true) -> Dictionary:
	var c_data: Dictionary = components_data.get(c_name)
	
	if c_data == null:
		Log.error("未找到组件数据: %s", c_name)
		return {}
		
	if not c_data:
		return {}

	if deep:
		return c_data.duplicate_deep()
	
	return c_data


## 获取模板数据
func get_template_data(t_name: String, deep: bool = true) -> Dictionary:
	var template_data = templates_data.get(t_name)
	
	if template_data == null:
		Log.error("未找到模板数据: %s", t_name)
		return {}
		
	if not template_data:
		return {}
		
	if deep:
		return template_data.duplicate_deep()
	
	return template_data
	

## 获取实体模板场景
func get_templates_scenes(t_name: String, deep: bool = false) -> PackedScene:
	var template_scenes = templates_scenes.get(t_name)
	
	if template_scenes == null:
		return null
		
	if not template_scenes:
		return null
		
	if deep:
		return template_scenes.duplicate()
	
	return template_scenes
	

## 获取实体脚本
func get_entity_script(t_name: String, deep: bool = false) -> Variant:
	var entity_script = entities_scripts.get(t_name)
	
	if not entity_script:
		return null
		
	if deep:
		return entity_script.duplicate()
	
	return entity_script


## 获取所有有效实体
func get_vaild_entities() -> Array:
	return entities.filter(func(e): return U.is_vaild_entity(e))
#endregion


#region 索敌相关
## 根据排序模式排序目标
func sort_targets(
		targets: Array, sort_type: String, origin: Vector2, reversed: bool = false
	) -> void:
	var sort_functions = {
		C.SORT_PROGRESS: func(e1: Entity, e2: Entity):
			var p1: float = (
				e1.get_c(C.CN_NAV_PATH).nav_progress
				if e1.has_c(C.CN_NAV_PATH) else 0
			)
		
			var p2: float = (
				e2.get_c(C.CN_NAV_PATH).nav_progress
				if e2.has_c(C.CN_NAV_PATH) else 0
			)
			
			return p1 > p2 if not reversed else p1 < p2,
		
		C.SORT_HEALTH: func(e1: Entity, e2: Entity):
			var h1: float = e1.get_c(C.CN_HEALTH).hp if e1.has_c(C.CN_HEALTH) else 0
			var h2: float = e2.get_c(C.CN_HEALTH).hp if e2.has_c(C.CN_HEALTH) else 0
			return h1 > h2 if not reversed else h1 < h2,
		
		C.SORT_DISTANCE: func(e1: Entity, e2: Entity):
			var d1: float = e1.position.distance_squared_to(origin)
			var d2: float = e2.position.distance_squared_to(origin)
			return d1 > d2 if not reversed else d1 < d2,
			
		C.SORT_ENTITY_ID: func(e1: Entity, e2: Entity):
			var i1: int = e1.id
			var i2: int = e2.id
			return i1 > i2 if not reversed else i1 < i2,
	}
	
	if sort_type in sort_functions:
		targets.sort_custom(sort_functions[sort_type])


func find_targets_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		pool: Array = entities
	) -> Array:
	return pool.filter(
		func(e): return (
			is_instance_valid(e)
			and not (bans & e.flags or e.bans & flags)
			and U.is_in_radius(e.position, origin, max_range)
			and not U.is_in_radius(e.position, origin, min_range)
			and (not filter or filter.call(e, origin))
		)
	)


func find_sorted_targets(
		sort_type: String,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		pool: Array = entities,
		reversed: bool = false
	) -> Array:
	var targets = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, pool
	)
	sort_targets(targets, sort_type, origin, reversed)
	return targets


func find_extreme_target(
		sort_type: String,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		pool: Array = entities,
		reversed: bool = false
	):
	var targets = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, pool
	)
	sort_targets(targets, sort_type, origin, reversed)
	return targets[0] if targets else null


func find_enemies_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null
	) -> Array:
	return find_targets_in_range(
		origin, 
		max_range, 
		min_range, 
		flags, 
		bans, 
		filter,
		get_entities_group(C.GROUP_ENEMIES)
	)


func find_sorted_enemies(
		sort_type: String,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		reversed: bool = false
	) -> Array:
	return find_sorted_targets(
		sort_type, 
		origin, 
		max_range, 
		min_range, 
		flags, 
		bans, 
		filter, 
		get_entities_group(C.GROUP_ENEMIES), 
		reversed
	)


func find_extreme_enemy(
		sort_type: String,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		reversed: bool = false
	):
	return find_extreme_target(
		sort_type, 
		origin, 
		max_range, 
		min_range, 
		flags, 
		bans, 
		filter, 
		get_entities_group(C.GROUP_ENEMIES), 
		reversed
	)


func find_friendlys_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null
	) -> Array:
	return find_targets_in_range(
		origin, 
		max_range, 
		min_range, 
		flags, 
		bans, 
		get_entities_group(C.GROUP_FRIENDLYS), 
		filter
	)


func find_sorted_friendlys(
		sort_type: String,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		reversed: bool = false
	) -> Array:
	return find_sorted_targets(
		sort_type, 
		origin, 
		max_range, 
		min_range, 
		flags, 
		bans, 
		filter, 
		get_entities_group(C.GROUP_FRIENDLYS), 
		reversed
	)


func find_extreme_friendly(
		sort_type: String,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Variant = null,
		reversed: bool = false
	):
	return find_extreme_target(
		sort_type, 
		origin, 
		max_range, 
		min_range, 
		flags, 
		bans, 
		filter, 
		get_entities_group(C.GROUP_FRIENDLYS), 
		reversed
	)


## 根据搜索模式选择相应索敌函数（搜索范围内单个目标）
func search_target(
		search_mode: String, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Variant = null
	):
	match search_mode:
		C.SEARCH_ENEMY_FIRST:
			return find_extreme_enemy(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_ENEMY_LAST:
			return find_extreme_enemy(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_ENEMY_NEARST:
			return find_extreme_enemy(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_ENEMY_FARTHEST:
			return find_extreme_enemy(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter, true)
		C.SEARCH_ENEMY_STRONGEST:
			return find_extreme_enemy(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_ENEMY_WEAKEST:
			return find_extreme_enemy(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_FRIENDLY_FIRST:
			return find_extreme_friendly(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_FRIENDLY_LAST:
			return find_extreme_friendly(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_FRIENDLY_NEARST:
			return find_extreme_friendly(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_FRIENDLY_FARTHEST:
			return find_extreme_friendly(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_FRIENDLY_STRONGEST:
			return find_extreme_friendly(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_FRIENDLY_WEAKEST:
			return find_extreme_friendly(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter, true
			)
			
	return null


## 根据搜索模式选择相应索敌函数（搜索范围内所有目标）
func search_targets_in_range(
		search_mode: String, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Variant = null
	) -> Array:
	match search_mode:
		C.SEARCH_ENEMY_FIRST:
			return find_sorted_enemies(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_ENEMY_LAST:
			return find_sorted_enemies(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_ENEMY_NEARST:
			return find_sorted_enemies(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_ENEMY_FARTHEST:
			return find_sorted_enemies(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_ENEMY_STRONGEST:
			return find_sorted_enemies(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_ENEMY_WEAKEST:
			return find_sorted_enemies(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_FRIENDLY_FIRST:
			return find_sorted_friendlys(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_FRIENDLY_LAST:
			return find_sorted_friendlys(
				C.SORT_PROGRESS, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_FRIENDLY_NEARST:
			return find_sorted_friendlys(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_FRIENDLY_FARTHEST:
			return find_sorted_friendlys(
				C.SORT_DISTANCE, origin, max_range, min_range, flags, bans, filter, true
			)
		C.SEARCH_FRIENDLY_STRONGEST:
			return find_sorted_friendlys(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter
			)
		C.SEARCH_FRIENDLY_WEAKEST:
			return find_sorted_friendlys(
				C.SORT_HEALTH, origin, max_range, min_range, flags, bans, filter, true
			)
			
	return []
#endregion
