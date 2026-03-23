extends Node
class_name ModifierComponent
## 状态效果组件
##
## ModifierComponent 可以使实体持续对其所有者造成影响


## 状态效果类型
@export var mod_type: Array[C.ModType] = []:
	set(value): 
		mod_type = value
		mod_type_bits = U.merge_flags(value)
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
## 是否允许相同状态效果叠加
@export var allow_same: bool = false
## 相同状态效果是否仅重置持续时间
@export var reset_same: bool = true
## 相同状态效果是否替换相同的状态效果
@export var replace_same: bool = false
## 相同状态效果是否叠加持续时间
@export var overlay_duration_same: bool = false
## 是否移除被禁止的状态效果
@export var remove_banned: bool = true

@export_group("Buff")
## 所有者的伤害因子
@export var add_damage_factor: float = 1
## 所有者的物理护甲因子
@export var physical_armor_factor: float = 1
## 所有者的魔法护甲因子
@export var magical_armor_factor: float = 1
## 所有者的伤害减免因子
@export var damage_resistance_factor: float = 1
## 所有者的速度因子
@export var speed_factor: float = 1
## 直接增加所有者的伤害
@export var add_damage_bonus: float = 0
## 直接增加所有者的物理护甲
@export var physical_armor_bonus: int = 0
## 直接增加所有者的魔法护甲
@export var magical_armor_bonus: int = 0
## 直接增加所有者的伤害减免
@export var damage_reduction_bonus: float = 0

@export_group("Debuff")
## 所有者的易伤因子
@export var vulnerable_factor: float = 1
## 直接增加所有者的易伤
@export var vulnerable_bonus: float = 0

## 时间戳
var ts: float = 0
## 二进制的状态效果类型
var mod_type_bits: int = 0
## 当前周期数
var curren_cycle: int = 0
