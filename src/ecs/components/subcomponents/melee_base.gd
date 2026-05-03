@tool
extends Attackbase
class_name MeleeBase
## 近战攻击节点基类
##
## MeleeBase 是 [MelleComponent] 的近战攻击节点的基类，提供了近战攻击的基本属性和功能。


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"
