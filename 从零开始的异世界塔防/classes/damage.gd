@tool
extends Entity
class_name Damage
## 伤害实体类


## 伤害值
var value: float = 0
## 伤害类型
var damage_type: C.DamageType = C.DamageType.NONE
## 伤害因子
var damage_factor: float = 1
