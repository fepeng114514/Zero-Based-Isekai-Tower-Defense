extends System
class_name GroupingSystem
## 分组系统
##
## 实时分组将实体分组到 [EntityMgr]，以便于根据分组快速获取实体，同时将实体根据坐标插入到可接受的空间索引中以便于根据坐标快速获取实体。


## 根据标识分到哪组的字典
const FLAG_TO_GROUP: Dictionary[C.Flag, StringName] = {
	C.Flag.ENEMY: C.GROUP_ENEMIES,
	C.Flag.FRIENDLY: C.GROUP_FRIENDLYS,
	C.Flag.UNIT: C.GROUP_UNIT,
	C.Flag.TOWER: C.GROUP_TOWERS,
	C.Flag.MODIFIER: C.GROUP_MODIFIERS,
	C.Flag.AURA: C.GROUP_AURAS,
}


## 根据标识分到哪组的字典键
const FLAG_TO_GROUP_KEYS: Array[C.Flag] = [
	C.Flag.ENEMY,
	C.Flag.FRIENDLY,
	C.Flag.UNIT,
	C.Flag.TOWER,
	C.Flag.MODIFIER,
	C.Flag.AURA,
]


var _space_index_grid_size: float = EntityMgr.SPACE_INDEX_GRID_SIZE
var _space_index_grids: Array[Dictionary] = []
var _world_size := Vector2i.ZERO
var _component_groups: Dictionary[String, Array] = {}
var _type_groups: Dictionary[String, Array] = {}
## 空间索引列数
var _space_index_grid_count_x: int = EntityMgr.space_index_grid_count_x
## 空间索引行数
var _space_index_grid_count_y: int = EntityMgr.space_index_grid_count_y

func _ready() -> void:
	_space_index_grids = EntityMgr.space_index_grids
	_world_size = GlobalMgr.world_size
	_component_groups = EntityMgr.component_groups
	_type_groups = EntityMgr.type_groups
	_space_index_grid_count_x = EntityMgr.space_index_grid_count_x
	_space_index_grid_count_y = EntityMgr.space_index_grid_count_y


func _on_update(_delta: float) -> void:
	# 清空空间索引网格
	for grid_col: Dictionary in _space_index_grids:
		for key: String in grid_col:
			if key.begins_with("has_"):
				grid_col[key] = false

		for grid_row: Dictionary in grid_col.row:
			for type_group: Array in grid_row.values():
				type_group.clear()

	# 清空分组
	for group_name: String in _component_groups:
		_component_groups[group_name].clear()

	for group_name: String in _type_groups:
		_type_groups[group_name].clear()

	for e: Entity in EntityMgr.get_valid_entities():
		var e_global_position: Vector2 = e.global_position
		
		# 根据实体的坐标将实体插入到空间索引中
		var x: int = floori(e_global_position.x / _space_index_grid_size)
		var y: int = floori(e_global_position.y / _space_index_grid_size)

		if x >= _space_index_grid_count_x:
			continue
			
		if y >= _space_index_grid_count_y:
			continue

		var grid_col: Dictionary = _space_index_grids[x]
		var grid_row: Dictionary = grid_col.row[y]
		grid_row.entities.append(e)
		grid_col.has_entities = true

		# 根据实体的标识和组件将实体分组
		if e.flags:
			for flags: C.Flag in FLAG_TO_GROUP_KEYS:
				if e.flags & flags:
					var group_name: StringName = FLAG_TO_GROUP[flags]

					_type_groups[group_name].append(e)
					grid_row[group_name].append(e)
					grid_col["has_" + group_name] = true

		for c_name: String in e.components:
			if not _component_groups.has(c_name):
				_component_groups[c_name] = []

			_component_groups[c_name].append(e)
