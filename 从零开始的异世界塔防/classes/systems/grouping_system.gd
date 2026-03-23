extends System
class_name GroupingSystem
## 分组系统
##
## 实时分组将实体分组到 [EntityDB]


## 根据标识分到哪组配置枚举
const FLAG_TO_GROUP = {
	C.Flag.ENEMY: C.GROUP_ENEMIES,
	C.Flag.FRIENDLY: C.GROUP_FRIENDLYS,
	C.Flag.UNIT: C.GROUP_UNIT,
	C.Flag.TOWER: C.GROUP_TOWERS,
	C.Flag.MODIFIER: C.GROUP_MODIFIERS,
	C.Flag.AURA: C.GROUP_AURAS,
}


func _on_update(_delta: float) -> void:
	var dirty_entities_ids: Array[int] = EntityDB._dirty_entities_ids
	if dirty_entities_ids.is_empty():
		return
		
	var type_groups: Dictionary[String, Array] = EntityDB._type_groups
	var component_groups: Dictionary[String, Array] = EntityDB._component_groups
		
	for group in type_groups.values():
		group.clear()
	component_groups.clear()
	
	for e: Entity in EntityDB.get_vaild_entities():
		for flags: C.Flag in FLAG_TO_GROUP.keys():
			if e.flag_bits & flags:
				_append_entity(e, FLAG_TO_GROUP[flags])

		for c_name: String in e.components.keys():
			if not component_groups.has(c_name):
				component_groups[c_name] = []

			if not e.has_c(c_name):
				continue

			component_groups[c_name].append(e)
			
	dirty_entities_ids.clear()

func _append_entity(e: Entity, group_name: StringName) -> void:
	EntityDB._type_groups[group_name].append(e)
