extends Node
## 实体管理器
##
## 管理所有实体与相关数据、工具函数

"""
	todo:
		1. 索敌的空间索引优化
		2. 对象池
"""


#region 属性
## 存储实体场景的字典
var _entity_scenes: Dictionary[String, PackedScene] = {}
## 被修改的场景
var _dirty_scenes: Array[String] = []
## 存储实体类型组的字典
var _type_groups: Dictionary[String, Array] = {
	"enemies": [],
	"friendlys": [],
	"unit": [],
	"towers": [],
	"modifiers": [],
	"auras": [],
}
## 存储组件组的字典
var _component_groups: Dictionary[String, Array] = {}
## 下一个创建实体的 id
var _next_id: int = 0
## 被修改的实体 id
var _dirty_entities_ids: Array[int] = []
## 实体数据缓存字典，用于读取数据，不参与游戏
var _cached_entities_data: Dictionary[String, Entity] = {}

## 所有实体数组
var entity_list: Array = []
#endregion


func load() -> void:
	_entity_scenes.clear()
	for group in _type_groups.values():
		group.clear()
	_component_groups.clear()
	entity_list.clear()
	_dirty_entities_ids.clear()
	_next_id = 0
	_cached_entities_data.clear()
	
	_scene_cache()


## 缓存所有实体场景
func _scene_cache() -> void:
	var json_data: Dictionary = U.load_json(
		"res://datas/entity_scene_paths.json"
	)
	
	for scene_name: String in json_data:
		var scene_path: String = json_data[scene_name]
		
		if not ResourceLoader.exists(scene_path):
			Log.error("未找到实体场景: %s" % scene_path)
			return
		
		Log.verbose("加载实体场景: %s" % scene_path)
		var scene: PackedScene = load(scene_path)
		
		_entity_scenes[scene_name] = scene


## 标记新增加或移除的实体
func mark_entity_dirty_id(id: int) -> void:
	if _dirty_entities_ids.has(id):
		return
		
	_dirty_entities_ids.append(id)


#region 创建实体相关
## 创建实体
func create_entity(scene_name: String) -> Entity:
	var e: Entity = get_entity_scene(scene_name).instantiate()
	if scene_name == "tower_mage_shooter":
		print()
		
	return process_create(e)
	
	
## 处理创建
func process_create(e: Entity) -> Entity:
	e.id = _next_id
	e.name = "%sI%d" % [e.name, e.id]

	Log.debug("创建实体: %s" % e)
	_next_id += 1
		
	return e


## 批量创建实体
func create_entities(
		scene_name_list: Array[String],
		config_func: Callable = Callable(),
		auto_insert: bool = true
	) -> Array[Entity]:
	
	var created_entities: Array[Entity] = []
	
	for scene_name: String in scene_name_list:
		var e: Entity = create_entity(scene_name)
		
		if config_func.is_valid():
			config_func.call(e)
		
		if auto_insert:
			e.insert_entity()
		
		created_entities.append(e)
	
	return created_entities


## 创建实体在指定位置
func create_entities_at_pos(
		scene_name_list: Array[String], 
		pos: Vector2, 
		auto_insert: bool = true
	) -> Array[Entity]:
	return create_entities(
		scene_name_list, func(e): e.set_pos(pos), auto_insert
	)


## 批量创建状态效果实体
func create_mods(
		target_id: int,
		scene_name_list: Array[String], 
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(
		scene_name_list, 
		func(e):
		e.target_id = target_id
		e.source_id = source_id
		, 
		auto_insert
	)


## 批量创建光环实体
func create_auras(
		scene_name_list: Array[String],
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(
		scene_name_list, 
		func(e: Entity) -> void:
		e.source_id = source_id
		,
		auto_insert
	)
#endregion


#region 索引相关
## 根据组名获取组内所有实体
func get_entities_group(group_name: String) -> Array:
	if group_name in _type_groups:
		return _type_groups[group_name]
	
	if group_name in _component_groups:
		return _component_groups[group_name]

	return []


## 根据 id 索引实体
func get_entity_by_id(id: int) -> Entity:
	if not U.is_valid_number(id):
		return null

	var e = entity_list.get(id)

	if not U.is_vaild_entity(e):
		return null

	return e


## 获取实体场景
func get_entity_scene(entity_name: String) -> PackedScene:
	if not _entity_scenes.has(entity_name):
		Log.error("未找到实体场景: %s" % entity_name)
		return null
		
	var scene: PackedScene = _entity_scenes[entity_name]
		
	return scene
	

## 设置实体场景
func set_entity_scene(
		entity_name: String, scene: PackedScene, new_scene_node: Entity
	) -> void:
	scene.pack(new_scene_node)
	EntityMgr._dirty_scenes.append(entity_name)
	_dirty_scenes.append(entity_name)


## 获取所有有效实体
func get_vaild_entities() -> Array:
	return entity_list.filter(
		func(e) -> bool: return U.is_vaild_entity(e)
	)
	
	
## 获取 source_id 为指定 id 的实体
func get_entities_by_source(source_id: int):
	return get_vaild_entities().filter(
		func(e: Entity) -> bool:
			return e.source_id == source_id
	)


## 获取实体数据，实体数据是一个实体实例，仅用于读取数据，不参与游戏逻辑
func get_entity_data(entity_name: String) -> Entity:
	if (
			not _cached_entities_data.has(entity_name) 
			or entity_name in _dirty_scenes
		):
		var e: Entity = get_entity_scene(entity_name).instantiate()
		_cached_entities_data[entity_name] = e
		_dirty_scenes.erase(entity_name)

	return _cached_entities_data[entity_name]
#endregion


#region 索敌相关
## 根据排序模式排序实体，默认最大在前，如果 reversed 为 true 则最小在前
static func sort_entities_by_type(
		entities_array: Array, sort_type: C.SortMode, origin: Vector2, reversed: bool = false
	) -> void:
	var sort_function: Callable = Callable()
	
	match sort_type:
		C.SortMode.PROGRESS:
			sort_function = func(e1: Entity, e2: Entity) -> bool:
				var p1: float = INF if reversed else -INF
				var p2: float = INF if reversed else -INF

				var e1_nav_c: NavPathComponent = e1.get_c(C.CN_NAV_PATH)
				if e1_nav_c:
					p1 = e1_nav_c.nav_progress

				var e2_nav_c: NavPathComponent = e2.get_c(C.CN_NAV_PATH)
				if e2_nav_c:
					p2 = e2_nav_c.nav_progress

				return p1 > p2 if not reversed else p1 < p2
		C.SortMode.HEALTH:
			sort_function = func(e1: Entity, e2: Entity) -> bool:
				var h1: float = INF if reversed else -INF
				var h2: float = INF if reversed else -INF

				var e1_health_c: HealthComponent = e1.get_c(C.CN_HEALTH)
				if e1_health_c:
					h1 = e1_health_c.hp
				var e2_health_c: HealthComponent = e2.get_c(C.CN_HEALTH)
				if e2_health_c:
					h2 = e2_health_c.hp

				return h1 > h2 if not reversed else h1 < h2
		C.SortMode.DISTANCE:
			sort_function = func(e1: Entity, e2: Entity) -> bool:
				var d1: float = e1.global_position.distance_squared_to(origin)
				var d2: float = e2.global_position.distance_squared_to(origin)

				return d1 > d2 if not reversed else d1 < d2
		C.SortMode.MELEE_DAMAGE:
			sort_function = func(e1: Entity, e2: Entity) -> bool:
				var d1: float = INF if reversed else -INF
				var d2: float = INF if reversed else -INF
				
				var e1_melee_c: MeleeComponent = e1.get_c(C.CN_MELEE)
				if e1_melee_c:
					d1 = e1_melee_c.list[0].damage_max
				var e2_melee_c: MeleeComponent = e2.get_c(C.CN_MELEE)
				if e2_melee_c:
					d2 = e2_melee_c.list[0].damage_max

				return d1 > d2 if not reversed else d1 < d2
		C.SortMode.RANGE_DAMAGE:
			sort_function = func(e1: Entity, e2: Entity) -> bool:
				var d1: float = INF if reversed else -INF
				var d2: float = INF if reversed else -INF

				var e1_ranged_c: RangedComponent = e1.get_c(C.CN_RANGED)
				if e1_ranged_c:
					d1 = EntityMgr.get_entity_data(
						e1_ranged_c.list[0].bullet
					).get_c(C.CN_BULLET).damage_max
				var e2_ranged_c: RangedComponent = e2.get_c(C.CN_RANGED)
				if e2_ranged_c:
					d2 = EntityMgr.get_entity_data(
						e2_ranged_c.list[0].bullet
					).get_c(C.CN_BULLET).damage_max

				return d1 > d2 if not reversed else d1 < d2
		C.SortMode.ID:
			sort_function = func(e1: Entity, e2: Entity) -> bool:
				var i1: int = e1.id
				var i2: int = e2.id
				
				return i1 > i2 if not reversed else i1 < i2
	
	entities_array.sort_custom(sort_function)


## 搜索范围内目标
##
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func find_targets_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = ""
	) -> Array:
	
	var group_entities: Array = get_entities_group(group) if group else entity_list
	
	return group_entities.filter(
		func(e) -> bool: return (
			U.is_vaild_entity(e)
			and not (bans & e.flag_bits or e.ban_bits & flags)
			and (
				not U.is_valid_number(max_range) 
				or U.is_in_radius(e.global_position, origin, max_range)
			)
			and not U.is_in_radius(e.global_position, origin, min_range)
			and (not filter.is_valid() or filter.call(e))
		)
	)


## 搜索并排序范围内目标
##
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func find_sorted_targets(
		sort_type: C.SortMode,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = "",
		reversed: bool = false
	) -> Array:
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_entities_by_type(targets, sort_type, origin, reversed)
	return targets


## 搜索范围内相应值最大的目标
##
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func find_extreme_target(
		sort_type: C.SortMode,
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
	sort_entities_by_type(targets, sort_type, origin, reversed)
	return targets[0] if targets else null


## 搜索模式配置常量
const SEARCH_CONFIG: Dictionary[C.SearchMode, Array] = {
	# [sort_type, group, reversed]
	C.SearchMode.ENTITY_MAX_PROGRESS: [C.SortMode.PROGRESS, "", false],
	C.SearchMode.ENTITY_MIN_PROGRESS: [C.SortMode.PROGRESS, "", true],
	C.SearchMode.ENTITY_MAX_DISTANCE: [C.SortMode.DISTANCE, "", false],
	C.SearchMode.ENTITY_MIN_DISTANCE: [C.SortMode.DISTANCE, "", true],
	C.SearchMode.ENTITY_MAX_HEALTH: [C.SortMode.HEALTH, "", false],
	C.SearchMode.ENTITY_MIN_HEALTH: [C.SortMode.HEALTH, "", true],
	C.SearchMode.ENTITY_MAX_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, "", false],
	C.SearchMode.ENTITY_MIN_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, "", true],
	C.SearchMode.ENTITY_MAX_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, "", false],
	C.SearchMode.ENTITY_MIN_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, "", true],
	C.SearchMode.ENTITY_MAX_ID: [C.SortMode.ID, "", false],
	C.SearchMode.ENTITY_MIN_ID: [C.SortMode.ID, "", true],

	C.SearchMode.ENEMY_MAX_PROGRESS: [C.SortMode.PROGRESS, C.GROUP_ENEMIES, false],
	C.SearchMode.ENEMY_MIN_PROGRESS: [C.SortMode.PROGRESS, C.GROUP_ENEMIES, true],
	C.SearchMode.ENEMY_MAX_DISTANCE: [C.SortMode.DISTANCE, C.GROUP_ENEMIES, false],
	C.SearchMode.ENEMY_MIN_DISTANCE: [C.SortMode.DISTANCE, C.GROUP_ENEMIES, true],
	C.SearchMode.ENEMY_MAX_HEALTH: [C.SortMode.HEALTH, C.GROUP_ENEMIES, false],
	C.SearchMode.ENEMY_MIN_HEALTH: [C.SortMode.HEALTH, C.GROUP_ENEMIES, true],
	C.SearchMode.ENEMY_MAX_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, C.GROUP_ENEMIES, false],
	C.SearchMode.ENEMY_MIN_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, C.GROUP_ENEMIES, true],
	C.SearchMode.ENEMY_MAX_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, C.GROUP_ENEMIES, false],
	C.SearchMode.ENEMY_MIN_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, C.GROUP_ENEMIES, true],
	C.SearchMode.ENEMY_MAX_ID: [C.SortMode.ID, C.GROUP_ENEMIES, false],
	C.SearchMode.ENEMY_MIN_ID: [C.SortMode.ID, C.GROUP_ENEMIES, true],
	
	C.SearchMode.FRIENDLY_MAX_PROGRESS: [C.SortMode.PROGRESS, C.GROUP_FRIENDLYS, false],
	C.SearchMode.FRIENDLY_MIN_PROGRESS: [C.SortMode.PROGRESS, C.GROUP_FRIENDLYS, true],
	C.SearchMode.FRIENDLY_MAX_DISTANCE: [C.SortMode.DISTANCE, C.GROUP_FRIENDLYS, false],
	C.SearchMode.FRIENDLY_MIN_DISTANCE: [C.SortMode.DISTANCE, C.GROUP_FRIENDLYS, true],
	C.SearchMode.FRIENDLY_MAX_HEALTH: [C.SortMode.HEALTH, C.GROUP_FRIENDLYS, false],
	C.SearchMode.FRIENDLY_MIN_HEALTH: [C.SortMode.HEALTH, C.GROUP_FRIENDLYS, true],
	C.SearchMode.FRIENDLY_MAX_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, C.GROUP_FRIENDLYS, false],
	C.SearchMode.FRIENDLY_MIN_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, C.GROUP_FRIENDLYS, true],
	C.SearchMode.FRIENDLY_MAX_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, C.GROUP_FRIENDLYS, false],
	C.SearchMode.FRIENDLY_MIN_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, C.GROUP_FRIENDLYS, true],
	C.SearchMode.FRIENDLY_MAX_ID: [C.SortMode.ID, C.GROUP_FRIENDLYS, false],
	C.SearchMode.FRIENDLY_MIN_ID: [C.SortMode.ID, C.GROUP_FRIENDLYS, true],

	C.SearchMode.UNIT_MAX_PROGRESS: [C.SortMode.PROGRESS, C.GROUP_UNIT, false],
	C.SearchMode.UNIT_MIN_PROGRESS: [C.SortMode.PROGRESS, C.GROUP_UNIT, true],
	C.SearchMode.UNIT_MAX_DISTANCE: [C.SortMode.DISTANCE, C.GROUP_UNIT, false],
	C.SearchMode.UNIT_MIN_DISTANCE: [C.SortMode.DISTANCE, C.GROUP_UNIT, true],
	C.SearchMode.UNIT_MAX_HEALTH: [C.SortMode.HEALTH, C.GROUP_UNIT, false],
	C.SearchMode.UNIT_MIN_HEALTH: [C.SortMode.HEALTH, C.GROUP_UNIT, true],
	C.SearchMode.UNIT_MAX_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, C.GROUP_UNIT, false],
	C.SearchMode.UNIT_MIN_MELEE_DAMAGE: [C.SortMode.MELEE_DAMAGE, C.GROUP_UNIT, true],
	C.SearchMode.UNIT_MAX_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, C.GROUP_UNIT, false],
	C.SearchMode.UNIT_MIN_RANGE_DAMAGE: [C.SortMode.RANGE_DAMAGE, C.GROUP_UNIT, true],
	C.SearchMode.UNIT_MAX_ID: [C.SortMode.ID, C.GROUP_UNIT, false],
	C.SearchMode.UNIT_MIN_ID: [C.SortMode.ID, C.GROUP_UNIT, true],
}


## 根据搜索模式选择相应索敌函数（搜索范围内单个目标）
##	
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func search_target(
		search_mode: C.SearchMode, 
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


## 根据搜索模式选择相应索敌函数（搜索范围内所有目标）
## 
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func search_targets_in_range(
		search_mode: C.SearchMode, 
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


## 根据搜索模式在扇形范围内搜索目标
##
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func search_targets_in_sector(
		search_mode: C.SearchMode,
		origin: Vector2,
		look_at: Vector2,
		radius: float,
		angle_range: float,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable()
	) -> Array:
	var sector_filter: Callable = func(e: Entity) -> bool:
		return U.is_in_sector(
			origin, 
			e.global_position, 
			radius, 
			angle_range, 
			origin.angle_to(look_at)
		) and (not filter.is_valid() or filter.call(e))

	return search_targets_in_range(
		search_mode, origin, radius, 0, flags, bans, sector_filter
	)


## 根据搜索模式在矩形范围内搜索目标
##
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func search_targets_in_rectangle(
		search_mode: C.SearchMode,
		origin: Vector2,
		look_at: Vector2,
		width: float,
		length: float,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable()
	) -> Array:
	var rectangle_filter: Callable = func(e: Entity) -> bool:
		return U.is_in_line(
			origin, 
			e.global_position, 
			width,
			length,
			origin.angle_to(look_at)
		) and (not filter.is_valid() or filter.call(e))

	return search_targets_in_range(
		search_mode, origin, length, 0, flags, bans, rectangle_filter
	)
#endregion
