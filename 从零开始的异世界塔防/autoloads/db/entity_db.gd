extends Node


"""实体数据库:
	存储所有实体与相关数据
	待优化:
		1. 索敌的空间索引优化
		2. 对象池
"""

#region 属性
var entity_scenes: Dictionary[C.ENTITY_TAG, PackedScene] = {}
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
var templates_name_dict: Dictionary[C.ENTITY_TAG, String]
#endregion


func load() -> void:
	entity_scenes = {}
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
	templates_name_dict = {}
	
	_load_templates_name_dict()
	_load_entity_scenes()

## 加载实体场景
func _load_entity_scenes() -> void:
	for entity_tag: C.ENTITY_TAG in C.ENTITY_TAG.values():
		var t_name: String = get_templates_name(entity_tag)
		var scene_path: String = C.PATH_ENTITIES_SCENES % t_name
		if not ResourceLoader.exists(scene_path):
			Log.error("未找到实体场景: %s" % scene_path)
			return
			
		var scene: PackedScene = load(scene_path)
		
		entity_scenes[entity_tag] = scene
		

func _load_templates_name_dict() -> void:
	for entity_name: String in C.ENTITY_TAG.keys():
		var tag: C.ENTITY_TAG = C.ENTITY_TAG[entity_name]
		entity_name = entity_name.to_lower()
		templates_name_dict[tag] = entity_name


func get_templates_name(entity_tag: C.ENTITY_TAG) -> String:
	return templates_name_dict[entity_tag]


## 标记新增加或移除的实体
func mark_entity_dirty_id(id: int) -> void:
	if _dirty_entities_ids.has(id):
		return
		
	_dirty_entities_ids.append(id)


#region 创建实体相关
## 创建实体
func create_entity(entity_tag: C.ENTITY_TAG) -> Entity:
	var scene: PackedScene = get_entity_scenes(entity_tag)
	var e: Entity = scene.instantiate()
		
	return process_create(e)
	
	
## 处理创建
func process_create(e: Entity) -> Entity:
	e.id = last_id
	e.template_name = get_templates_name(e.tag)
	
	for node: Node in e.get_children():
		var node_class: String = node.get_script().get_global_name()
		
		if not node_class.find("Component"):
			continue
			
		e.components[node_class] = node
	
	# 调用所有系统的准备插入回调函数，遇到返回 false 的系统不插入实体
	if not SystemMgr.call_systems("_on_create", e):
		return e

	Log.debug("创建实体: %s" % e)
	last_id += 1
		
	return e


## 批量创建实体
func create_entities(
		entity_tags: Array[C.ENTITY_TAG],
		config_func: Callable = Callable(),
		auto_insert: bool = true
	) -> Array[Entity]:
	
	var created_entities: Array[Entity] = []
	
	for entity_tag: C.ENTITY_TAG in entity_tags:
		var e: Entity = create_entity(entity_tag)
		
		if config_func.is_valid():
			config_func.call(e)
		
		if auto_insert:
			e.insert_entity()
		
		created_entities.append(e)
	
	return created_entities


## 创建实体在指定位置
func create_entities_at_pos(
		entity_tags: Array[C.ENTITY_TAG], pos: Vector2, auto_insert: bool = true
	) -> Array[Entity]:
	return create_entities(
		entity_tags, func(e): e.set_pos(pos), auto_insert
	)


## 批量创建状态效果实体
func create_mods(
		target_id: int,
		mods_tags: Array[C.ENTITY_TAG],
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(mods_tags, func(e):
		e.target_id = target_id
		e.source_id = source_id
	, auto_insert)


## 批量创建光环实体
func create_auras(
		auras_tags: Array[C.ENTITY_TAG],
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(auras_tags, func(e: Entity) -> void:
		e.source_id = source_id
	, auto_insert)

## 创建伤害实体
func create_damage(
		target_id: int,
		min_damage: float,
		max_damage: float,
		damage_type: C.DAMAGE = C.DAMAGE.PHYSICAL,
		source_id: int = C.UNSET,
		damage_factor: float = 1
	) -> Damage:
	var d := Damage.new()
	
	d.target_id = target_id
	d.source_id = source_id
	d.damage_type = damage_type
	d.value = randf_range(min_damage, max_damage)
	d.damage_factor = damage_factor
	d.template_name = "damage"

	SystemMgr.damage_queue.append(d)
		
	return d
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
func get_entity_by_id(id: int) -> Entity:
	if not U.is_valid_number(id):
		return null

	var e = entities.get(id)

	if not U.is_vaild_entity(e):
		return null

	return e


## 获取实体模板场景
func get_entity_scenes(entity_tag: C.ENTITY_TAG, deep: bool = true) -> PackedScene:
	if not entity_scenes.has(entity_tag):
		Log.error("未找到实体场景, tag: %d" % entity_tag)
		return null
		
	var scenes: PackedScene = entity_scenes[entity_tag]
		
	if deep:
		return scenes.duplicate()
	
	return scenes
	

## 获取所有有效实体
func get_vaild_entities() -> Array:
	return entities.filter(
		func(e) -> bool: return U.is_vaild_entity(e)
	)
#endregion


#region 索敌相关
## 根据排序模式排序目标
func sort_targets(
		targets: Array, sort_type: C.SORT, origin: Vector2, reversed: bool = false
	) -> void:
	var sort_functions = {
		C.SORT.PROGRESS: func(e1: Entity, e2: Entity) -> bool:
			var p1: float = (
				e1.get_c(C.CN_NAV_PATH).nav_progress
				if e1.has_c(C.CN_NAV_PATH) else 0
			)
			var p2: float = (
				e2.get_c(C.CN_NAV_PATH).nav_progress
				if e2.has_c(C.CN_NAV_PATH) else 0
			)
			return p1 > p2 if not reversed else p1 < p2,
		
		C.SORT.HEALTH: func(e1: Entity, e2: Entity) -> bool:
			var h1: float = e1.get_c(C.CN_HEALTH).hp if e1.has_c(C.CN_HEALTH) else 0
			var h2: float = e2.get_c(C.CN_HEALTH).hp if e2.has_c(C.CN_HEALTH) else 0
			return h1 > h2 if not reversed else h1 < h2,
		
		C.SORT.DISTANCE: func(e1: Entity, e2: Entity) -> bool:
			var d1: float = e1.position.distance_squared_to(origin)
			var d2: float = e2.position.distance_squared_to(origin)
			return d1 > d2 if not reversed else d1 < d2,
			
		C.SORT.ID: func(e1: Entity, e2: Entity) -> bool:
			var i1: int = e1.id
			var i2: int = e2.id
			return i1 > i2 if not reversed else i1 < i2,
	}
	
	if sort_type in sort_functions:
		targets.sort_custom(sort_functions[sort_type])


## 搜索范围内目标, 
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func find_targets_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = ""
	) -> Array:
	
	var pool: Array = get_entities_group(group) if group else entities
	
	return pool.filter(
		func(e) -> bool: return (
			is_instance_valid(e)
			and not (bans & e.flag_set.bits or e.ban_set.bits & flags)
			and U.is_in_radius(e.position, origin, max_range)
			and not U.is_in_radius(e.position, origin, min_range)
			and (not filter.is_valid() or filter.call(e))
		)
	)


## 搜索并排序范围内目标, 
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func find_sorted_targets(
		sort_type: C.SORT,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = "",
		reversed: bool = false
	) -> Array[Entity]:
	var targets: Array[Entity] = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_targets(targets, sort_type, origin, reversed)
	return targets


## 搜索范围内相应值最大的目标, 
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func find_extreme_target(
		sort_type: C.SORT,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = "",
		reversed: bool = false
	) -> Entity:
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_targets(targets, sort_type, origin, reversed)
	return targets[0] if targets else null


## 搜索模式配置常量
const SEARCH_CONFIG: Dictionary[C.SEARCH, Array] = {
	# [sort_type, group, reversed]
	C.SEARCH.ENTITY_FIRST: [C.SORT.PROGRESS, "", false],
	C.SEARCH.ENTITY_LAST: [C.SORT.PROGRESS, "", true],
	C.SEARCH.ENTITY_NEARST: [C.SORT.DISTANCE, "", false],
	C.SEARCH.ENTITY_FARTHEST: [C.SORT.DISTANCE, "", true],
	C.SEARCH.ENTITY_STRONGEST: [C.SORT.HEALTH, "", false],
	C.SEARCH.ENTITY_WEAKEST: [C.SORT.HEALTH, "", true],
	C.SEARCH.ENTITY_MAX_ID: [C.SORT.ID, "", true],
	C.SEARCH.ENTITY_MIN_ID: [C.SORT.ID, "", false],

	C.SEARCH.ENEMY_FIRST: [C.SORT.PROGRESS, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_LAST: [C.SORT.PROGRESS, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_NEARST: [C.SORT.DISTANCE, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_FARTHEST: [C.SORT.DISTANCE, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_STRONGEST: [C.SORT.HEALTH, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_WEAKEST: [C.SORT.HEALTH, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_ID: [C.SORT.ID, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MIN_ID: [C.SORT.ID, C.GROUP_ENEMIES, false],
	
	C.SEARCH.FRIENDLY_FIRST: [C.SORT.PROGRESS, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_LAST: [C.SORT.PROGRESS, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_NEARST: [C.SORT.DISTANCE, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_FARTHEST: [C.SORT.DISTANCE, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_STRONGEST: [C.SORT.HEALTH, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_WEAKEST: [C.SORT.HEALTH, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_ID: [C.SORT.ID, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MIN_ID: [C.SORT.ID, C.GROUP_FRIENDLYS, false],
}


## 根据搜索模式选择相应索敌函数（搜索范围内单个目标）,
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func search_target(
		search_mode: int, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Callable = Callable()
	) -> Entity:
	if search_mode not in SEARCH_CONFIG:
		Log.error("未知搜索模式: %s" % search_mode)
		return null
		
	var config: Array = SEARCH_CONFIG[search_mode]
	return find_extreme_target(
		config[0], origin, max_range, min_range, 
		flags, bans, filter, config[1], config[2]
	)


## 根据搜索模式选择相应索敌函数（搜索范围内所有目标）,
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func search_targets_in_range(
		search_mode: int, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Callable = Callable()
	) -> Array:
	if search_mode not in SEARCH_CONFIG:
		Log.error("未知搜索模式: %s" % search_mode)
		return []
		
	var config: Array = SEARCH_CONFIG[search_mode]
	return find_sorted_targets(
		config[0], origin, max_range, min_range, 
		flags, bans, filter, config[1], config[2]
	)
#endregion
