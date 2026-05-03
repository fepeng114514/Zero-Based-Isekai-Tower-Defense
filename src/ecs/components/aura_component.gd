extends Node
class_name AuraComponent
## 光环组件
## 
## AuraComponent 可以使实体可周期性对范围内其他实体造成影响


## 光环类型
@export var aura_type: int = 0
## 最小范围
@export var min_radius: float = 0
## 最大范围
@export var max_radius: float = 0
## 搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 最大可影响的实体数量
@export var max_influence: int = C.UNSET
## 状态效果场景名称
@export var mods: Array[String] = []
## 周期时间
@export var cycle_time: float = 1
## 最大周期
@export var max_cycle: int = C.UNSET

@export_group("Cycle Damage")
## 最小伤害
@export var damage_min: float = 0
## 最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.TRUE
## 伤害标识
@export var damage_flags: int = 0

@export_group("Same Process")
## 是否允许相同光环叠加
@export var allow_same: bool = false
## 相同光环是否仅重置持续时间
@export var reset_same: bool = true
## 相同光环是否替换相同的光环
@export var replace_same: bool = false
## 相同光环是否叠加持续时间
@export var overlay_duration_same: bool = false
## 是否移除被禁止的光环
@export var remove_banned: bool = true

## 当前周期数
var curren_cycle: int = 0
## 时间戳
var ts: float = 0


func _validate_property(property: Dictionary):
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"
		"aura_type":
			property.hint_string = "mask_enum:AuraType"
