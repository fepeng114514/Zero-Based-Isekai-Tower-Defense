extends System
class_name GroupingSystem
## 分组系统
##
## 实时分组将实体分组到 [EntityMgr]，以便于根据分组快速获取实体，同时将实体根据坐标插入到可接受的空间索引中以便于根据坐标快速获取实体。


var space_index_grid_size: float = EntityMgr.SPACE_INDEX_GRID_SIZE
var space_index_grids: Array[Array] = []
var world_size := Vector2i.ZERO
var component_groups: Dictionary[String, Array] = {}
var type_groups: Dictionary[String, Array] = {}

## 根据标识分到哪组的字典
const FLAG_TO_GROUP: Dictionary[C.Flag, String] = {
	C.Flag.ENEMY: C.GROUP_ENEMIES,
	C.Flag.FRIENDLY: C.GROUP_FRIENDLYS,
	C.Flag.UNIT: C.GROUP_UNIT,
	C.Flag.TOWER: C.GROUP_TOWERS,
	C.Flag.MODIFIER: C.GROUP_MODIFIERS,
	C.Flag.AURA: C.GROUP_AURAS,
}
var group_keys: Array[C.Flag] = FLAG_TO_GROUP.keys()


func _ready() -> void:
	space_index_grids = EntityMgr.space_index_grids
	world_size = GlobalMgr.world_size
	component_groups = EntityMgr.component_groups
	type_groups = EntityMgr.type_groups


func _on_update(_delta: float) -> void:
	# 清空空间索引网格
	for grid_col: Array in space_index_grids:
		for grid_row: Array in grid_col:
			grid_row.clear()

	# 清空分组
	for group_name: String in component_groups:
		component_groups[group_name].clear()

	for group_name: String in type_groups:
		type_groups[group_name].clear()

	for e: Entity in EntityMgr.get_valid_entities():
		# 根据实体的坐标将实体插入到空间索引中
		var x: int = ceil(e.position.x / space_index_grid_size)
		var y: int = ceil(e.position.y / space_index_grid_size)

		space_index_grids[x][y].append(e)

		# 根据实体的标识和组件将实体分组
		for flags: C.Flag in group_keys:
			if e.flag_bits & flags:
				var group_name: String = FLAG_TO_GROUP[flags]

				type_groups[group_name].append(e)

		for c_name: String in e.components.keys():
			if not component_groups.has(c_name):
				component_groups[c_name] = []

			component_groups[c_name].append(e)
