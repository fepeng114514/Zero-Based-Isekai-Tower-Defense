extends Node
class_name AuraComponent
## 光环组件
## 
## AuraComponent 可以使实体可周期性对范围内其他实体造成影响


## 光环类型
@export var aura_type: Array[C.ModType] = []:
	set(value): 
		aura_type = value
		aura_type_bits = U.merge_flags(value)
## 最小范围
@export var min_radius: float = 0
## 最大范围
@export var max_radius: float = 0
## 搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 最大可影响的实体数量
@export var max_influence: int = C.UNSET
## 状态效果 uid
@export_file("*.tscn") var mods: Array[String] = []
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
@export var damage_type: C.DamageType = C.DamageType.TRUE

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

## 二进制的光环类型
var aura_type_bits: int = 0
## 当前周期数
var curren_cycle: int = 0
## 时间戳
var ts: float = 0
