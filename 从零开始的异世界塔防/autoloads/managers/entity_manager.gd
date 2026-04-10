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
## 下一个创建实体的 id
var _next_id: int = 0
## 实体数据缓存字典，用于读取数据，不参与游戏
var _cached_entities_data: Dictionary[String, Entity] = {}

## 所有实体数组
var entity_list: Array = []
## 存储实体类型组的字典
var type_groups: Dictionary[String, Array] = {
	"enemies": [],
	"friendlys": [],
	"units": [],
	"towers": [],
	"modifiers": [],
	"auras": [],
}
## 存储组件组的字典
var component_groups: Dictionary[String, Array] = {}

## 空间索引的网格大小
const SPACE_INDEX_GRID_SIZE: float = 100
## 空间索引列数
var space_index_grid_count_x: int = 0
## 空间索引行数
var space_index_grid_count_y: int = 0
## 空间索引网格数组
var space_index_grids: Array[Dictionary] = []
#endregion


func load() -> void:
	_entity_scenes.clear()
	_cached_entities_data.clear()
	component_groups.clear()
	entity_list.clear()
	space_index_grids.clear()
	
	for group: Array in type_groups.values():
		group.clear()
	_next_id = 0
	
	var json_data: Dictionary = U.load_json(
		"res://datas/entity_scene_paths.json"
	)
	
	# 加载实体场景
	for scene_name: String in json_data:
		var scene_path: String = json_data[scene_name]
		
		if not ResourceLoader.exists(scene_path):
			Log.error("未找到实体场景: %s" % scene_path)
			return
		
		Log.verbose("加载实体场景: %s" % scene_path)
		var scene: PackedScene = load(scene_path)
		
		_entity_scenes[scene_name] = scene

	# 初始化空间索引网格
	var grid_count_x: int = ceil(GlobalMgr.world_size.x / SPACE_INDEX_GRID_SIZE)
	var grid_count_y: int = ceil(GlobalMgr.world_size.y / SPACE_INDEX_GRID_SIZE)
	
	for x: int in range(grid_count_x):
		var grid_col: Dictionary = {
			"row": [],
			"has_entities": false,
			"has_enemies": false,
			"has_friendlys": false,
			"has_units": false,
			"has_towers": false,
			"has_modifiers": false,
			"has_auras": false,
		}
		var grid_row: Array = grid_col.row

		for y: int in range(grid_count_y):
			grid_row.append({
				C.GROUP_ENTITIES: [],
				C.GROUP_ENEMIES: [],
				C.GROUP_FRIENDLYS: [],
				C.GROUP_UNIT: [],
				C.GROUP_TOWERS: [],
				C.GROUP_MODIFIERS: [],
				C.GROUP_AURAS: [],
			})

		space_index_grids.append(grid_col)
	
	space_index_grid_count_x = grid_count_x
	space_index_grid_count_y = grid_count_y


#region 创建实体相关
## 创建实体
func create_entity(scene_name: String) -> Entity:
	var e: Entity = get_entity_scene(scene_name).instantiate()
	
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
	if group_name in type_groups:
		return type_groups[group_name]
	
	if group_name in component_groups:
		return component_groups[group_name]

	return []


## 根据 id 索引实体
func get_entity_by_id(id: int) -> Entity:
	if not U.is_valid_number(id):
		return null

	var e = entity_list.get(id)

	if not U.is_valid_entity(e):
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
func get_valid_entities() -> Array:
	return entity_list.filter(
		func(e) -> bool: return U.is_valid_entity(e)
	)
	
	
## 获取 source_id 为指定 id 的实体
func get_entities_by_source(source_id: int):
	return get_valid_entities().filter(
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
		entities_array: Array[Entity], sort_type: C.SortMode, origin: Vector2, reversed: bool = false
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



#region 实体的搜索模式配置
const PROPERTY_META: Dictionary[String, C.SortMode] = {
	"PROGRESS": C.SortMode.PROGRESS,
	"DISTANCE": C.SortMode.DISTANCE,
	"HEALTH": C.SortMode.HEALTH,
	"MELEE_DAMAGE": C.SortMode.MELEE_DAMAGE,
	"RANGE_DAMAGE": C.SortMode.RANGE_DAMAGE,
	"ID": C.SortMode.ID,
}

const GROUP_DICT: Dictionary[String, StringName] = {
	"ENTITY": C.GROUP_ENTITIES,
	"ENEMY": C.GROUP_ENEMIES,
	"FRIENDLY": C.GROUP_FRIENDLYS,
	"UNIT": C.GROUP_UNIT,
}


## 搜索模式配置类，包含排序模式、过滤函数和是否反转排序
class SearchModeConfig:
	var sort_mode: C.SortMode
	var group: StringName
	var reversed: bool

	func _init(p_sort: C.SortMode, p_group: StringName, p_rev: bool):
		sort_mode = p_sort
		group = p_group
		reversed = p_rev


## 构建搜索模式配置字典
static func build_search_config() -> Dictionary[C.SearchMode, SearchModeConfig]:
	var config: Dictionary[C.SearchMode, SearchModeConfig] = {}

	for group: String in GROUP_DICT:
		var group_name: StringName = GROUP_DICT[group]

		for prop: String in PROPERTY_META:
			var sort: C.SortMode = PROPERTY_META[prop]
			# MAX 模式：降序 = false
			config[C.SearchMode["%s_MAX_%s" % [group, prop]]] = SearchModeConfig.new(sort, group_name, false)
			# MIN 模式：降序 = true
			config[C.SearchMode["%s_MIN_%s" % [group, prop]]] = SearchModeConfig.new(sort, group_name, true)

	return config


var search_config: Dictionary[C.SearchMode, SearchModeConfig] = build_search_config()


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
		group: StringName = C.GROUP_ENTITIES
	) -> Array[Entity]:
	var targets: Array[Entity] = []

	var grid_min_x: int = max(0, floor((origin.x - max_range) / SPACE_INDEX_GRID_SIZE))
	var grid_max_x: int = min(space_index_grid_count_x - 1, ceil((origin.x + max_range) / SPACE_INDEX_GRID_SIZE))
	var grid_min_y: int = max(0, floor((origin.y - max_range) / SPACE_INDEX_GRID_SIZE))
	var grid_max_y: int = min(space_index_grid_count_y - 1, ceil((origin.y + max_range) / SPACE_INDEX_GRID_SIZE))

	for grid_x: int in range(grid_min_x, grid_max_x + 1):
		var grid_col: Dictionary = space_index_grids[grid_x]

		if not grid_col["has_" + group]:
			continue

		var grid_row: Array = grid_col.row

		for grid_y: int in range(grid_min_y, grid_max_y + 1):
			var grid: Array = grid_row[grid_y][group]
			for e: Entity in grid:
				if (
						not U.is_mutual_ban(e.flag_bits, bans, flags, e.ban_bits)
						and U.is_in_ring(origin, e.global_position, min_range, max_range)
						and (not filter.is_valid() or filter.call(e))
				):
					targets.append(e)

	return targets
#endregion


## 根据搜索模式选择相应索敌函数（搜索范围内单个目标）
##	
## filter 匿名函数格式为 func(e: Entity) -> bool, 返回 false 表示被过滤
func search_targets(
		search_mode: C.SearchMode, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Callable = Callable()
	) -> Array[Entity]:
	var config: SearchModeConfig = search_config.get(search_mode)
	if not config:
		Log.error("未知搜索模式: %s" % search_mode)
		return []

	var group: StringName = config.group

	if flags & C.Flag.ENEMY:
		match config.group:
			C.GROUP_ENEMIES:
				group = C.GROUP_FRIENDLYS
			C.GROUP_FRIENDLYS:
				group = C.GROUP_ENEMIES
			
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_entities_by_type(targets, config.sort_mode, origin, config.reversed)
	return targets


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

	return search_targets(
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

	return search_targets(
		search_mode, origin, length, 0, flags, bans, rectangle_filter
	)
#endregion
