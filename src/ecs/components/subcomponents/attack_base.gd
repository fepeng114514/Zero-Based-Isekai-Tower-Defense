extends Node2D
class_name Attackbase
## 攻击节点基类
##
## Attackbase 是所有攻击节点的基类，提供了攻击的基本属性和功能。


## 冷却时间
@export var cooldown: float = 1
## 是否禁用
@export var disabled: bool = false
## 攻击概率
@export var chance: float = 1
## 攻击延迟
@export var delay: float = 0
## 攻击动画数据
@export var animation: AnimationData = null
## 攻击音效数据
@export var sfx: AudioData = null
## 实体组冷却偏移
@export var group_cooldown_offset: float = 0.1
## 是否禁用实体组冷却
@export var group_cooldown_disabled: bool = false

@export_group("Damage")
## 子弹最小伤害
@export var damage_min: float = 0
## 子弹最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: int = 0
## 击中目标给予的状态效果
@export var mods: Array[String] = []

@export_subgroup("Area Damage")
## 是否启用范围伤害
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var damage_area_enable: bool = false
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 最大伤害数量
@export var damage_max_count: int = C.UNSET
## 范围伤害的搜索模式
@export var damage_search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 范围伤害是否随距离衰减
@export var damage_falloff_enabled: bool = false
## 范围伤害的圆心偏移
@export var damage_offset := Vector2.ZERO
## 是否可以伤害重复敌人
@export var can_damage_same: bool = false

@export_group("Limit")
## 攻击标识
@export var flags: int = 0
## 不可攻击的实体的标识
@export var bans: int = 0
## 可攻击的实体场景名称
@export var whitelist: Array[String] = []
## 不可以攻击的实体场景名称
@export var blacklist: Array[String] = []

## 时间戳
var ts: float = 0
## 伤害过的实体 ID 列表
var damaged_entity_ids: Array[int] = []


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"flags":
			property.hint_string = "mask_enum:Flag"
		"bans":
			property.hint_string = "mask_enum:Flag"
