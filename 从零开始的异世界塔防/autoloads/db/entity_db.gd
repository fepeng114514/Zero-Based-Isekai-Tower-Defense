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
	"auras": []
}
var component_groups: Dictionary[String, Array] = {}
var entities: Array = []
var last_id: int = 0
var tag_name_dict: Dictionary[C.ENTITY_TAG, String]
var _dirty_entities_ids: Array[int] = []
#endregion


func load() -> void:
	entity_scenes.clear()
	for group in type_groups.values():
		group.clear()
	component_groups.clear()
	entities.clear()
	_dirty_entities_ids.clear()
	tag_name_dict.clear()
	last_id = 0
	
	_load_tag_name_dict()
	_load_entity_scenes()

## 加载实体场景
func _load_entity_scenes() -> void:
	for entity_tag: C.ENTITY_TAG in C.ENTITY_TAG.values():
		var t_name: String = get_tag_name(entity_tag)
		var scene_path: String = C.PATH_ENTITIES_SCENES % t_name
		if not ResourceLoader.exists(scene_path):
			Log.error("未找到实体场景: %s" % scene_path)
			return
			
		var scene: PackedScene = load(scene_path)
		
		entity_scenes[entity_tag] = scene

func _load_tag_name_dict() -> void:
	for entity_name: String in C.ENTITY_TAG.keys():
		var tag: C.ENTITY_TAG = C.ENTITY_TAG[entity_name]
		entity_name = entity_name.to_lower()
		tag_name_dict[tag] = entity_name


func get_tag_name(entity_tag: C.ENTITY_TAG) -> String:
	return tag_name_dict[entity_tag]


## 标记新增加或移除的实体
func mark_entity_dirty_id(id: int) -> void:
	if _dirty_entities_ids.has(id):
		return
		
	_dirty_entities_ids.append(id)


#region 创建实体相关
## 创建实体
func create_entity(
		entity_tag: C.ENTITY_TAG, process: bool = true
) -> Entity:
	var e: Entity = get_entity_scene(entity_tag).instantiate()
		
	if not process:
		return e
		
	return process_create(e)
	
	
## 处理创建
func process_create(e: Entity) -> Entity:
	e.id = last_id
	e.tag_name = get_tag_name(e.tag)
	e.name = "%sI%d" % [e.name, e.id]

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
	d.tag_name = "damage"

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


## 获取实体场景
func get_entity_scene(entity_tag: C.ENTITY_TAG) -> PackedScene:
	if not entity_scenes.has(entity_tag):
		Log.error("未找到实体场景, tag: %d" % entity_tag)
		return null
		
	var scene: PackedScene = entity_scenes[entity_tag]
		
	return scene
	

## 设置实体场景
func set_entity_scene(
		entity_tag: C.ENTITY_TAG, new_scene: PackedScene
) -> void:
	entity_scenes[entity_tag] = new_scene


## 获取所有有效实体
func get_vaild_entities() -> Array:
	return entities.filter(
		func(e) -> bool: return U.is_vaild_entity(e)
	)
	
## 获取 source_id 为指定 id 的实体
func get_entities_by_source(source_id: int):
	return get_vaild_entities().filter(
		func(e: Entity) -> bool:
			return e.source_id == source_id
	)
#endregion


#region 索敌相关
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
	) -> Array:
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	U.sort_array(targets, sort_type, origin, reversed)
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
	U.sort_array(targets, sort_type, origin, reversed)
	return targets[0] if targets else null


## 搜索模式配置常量
const SEARCH_CONFIG: Dictionary[C.SEARCH, Array] = {
	# [sort_type, group, reversed]
	C.SEARCH.ENTITY_MAX_PROGRESS: [C.SORT.PROGRESS, "", false],
	C.SEARCH.ENTITY_MIN_PROGRESS: [C.SORT.PROGRESS, "", true],
	C.SEARCH.ENTITY_MAX_DISTANCE: [C.SORT.DISTANCE, "", false],
	C.SEARCH.ENTITY_MIN_DISTANCE: [C.SORT.DISTANCE, "", true],
	C.SEARCH.ENTITY_MAX_HEALTH: [C.SORT.HEALTH, "", false],
	C.SEARCH.ENTITY_MIN_HEALTH: [C.SORT.HEALTH, "", true],
	C.SEARCH.ENTITY_MAX_ID: [C.SORT.ID, "", false],
	C.SEARCH.ENTITY_MIN_ID: [C.SORT.ID, "", true],

	C.SEARCH.ENEMY_MAX_PROGRESS: [C.SORT.PROGRESS, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_PROGRESS: [C.SORT.PROGRESS, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_DISTANCE: [C.SORT.DISTANCE, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_DISTANCE: [C.SORT.DISTANCE, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_HEALTH: [C.SORT.HEALTH, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_HEALTH: [C.SORT.HEALTH, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_ID: [C.SORT.ID, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_ID: [C.SORT.ID, C.GROUP_ENEMIES, true],
	
	C.SEARCH.FRIENDLY_MAX_PROGRESS: [C.SORT.PROGRESS, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_PROGRESS: [C.SORT.PROGRESS, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_DISTANCE: [C.SORT.DISTANCE, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_DISTANCE: [C.SORT.DISTANCE, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_HEALTH: [C.SORT.HEALTH, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_HEALTH: [C.SORT.HEALTH, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_ID: [C.SORT.ID, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_ID: [C.SORT.ID, C.GROUP_FRIENDLYS, true],
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
