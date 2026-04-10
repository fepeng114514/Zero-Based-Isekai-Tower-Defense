@tool
extends MeleeBase
class_name MeleeRangeAttack


@export_group("Damage")
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 最大伤害数量
@export var damage_max_count: int = C.UNSET
