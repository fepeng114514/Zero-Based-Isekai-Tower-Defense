@tool
extends Node2D
class_name RangedComponent

## 是否禁用索敌
@export var disabled_search: bool = false

		
func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 RangedBase 或其类型的子节点，否则实体无法攻击。"]
		
	return []
