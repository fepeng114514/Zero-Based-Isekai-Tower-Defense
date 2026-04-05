extends Resource
class_name DamageData
## 伤害数据资源


## 伤害值，会覆盖伤害的随机计算
@export var value: float = C.UNSET
## 最小伤害
@export var damage_min: float = 0
## 最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: C.DamageType = C.DamageType.PHYSICAL
## 伤害因子
@export var damage_factor: float = 1
## 伤害标识
@export var damage_flags: Array[C.DamageFlag] = []:
	set(value):
		damage_flags = value
		damage_flag_bits = U.merge_flags(damage_flags)
	
## 二进制的伤害标识
var damage_flag_bits: int = 0
