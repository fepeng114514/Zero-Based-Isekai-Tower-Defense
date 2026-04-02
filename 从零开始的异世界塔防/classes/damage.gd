@tool
extends Resource
class_name Damage
## 伤害资源


## 最小伤害
@export var damage_min: float = 0
## 最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: C.DamageType = C.DamageType.NONE
## 伤害因子
@export var damage_factor: float = 1
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 同时造成的状态效果实体名称
@export var mods: Array[String] = []
