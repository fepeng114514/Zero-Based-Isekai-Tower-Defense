extends Node

## 血量组件，负责实体的血量、护甲、抗性等属性，以及相关的伤害计算.
class_name HealthComponent


## 最大血量，表示实体的最大血量
@export var hp_max: float = 0
## 当前血量，表示实体当前的血量，为 0 时表示实体死亡
var hp: float = 0
## 血条节点引用
var health_bar: Node2D
## 血条缩放，表示血条的缩放比例，通常用于调整血条的大小以适应不同大小的实体
var health_bar_scale: Vector2 = Vector2.ONE
## 血条偏移，表示血条相对于实体位置的偏移，通常用于调整血条的位置以适应不同大小的实体
var health_bar_offset: Vector2 = Vector2(0, -30)
## 物理护甲值，表示实体的物理护甲值，护甲可以减少实体受到的物理伤害
@export var physical_armor: int = 0
## 魔法护甲值，表示实体的魔法护甲值，护甲可以减少实体受到的魔法伤害
@export var magical_armor: int = 0
## 毒抗性，表示实体的毒抗性，毒抗性可以减少实体受到的毒伤害
@export var poison_armor: int = 0
## 伤害抗性，表示实体的伤害抗性，伤害抗性可以百分比减少实体受到的伤害
@export var damage_resistance: float = 0
## 伤害减免，表示实体的伤害减免值，伤害减免可以直接减少实体受到的伤害值
@export var damage_reduction: float = 0
## 易伤值，表示实体的易伤值，易伤可以百分比增加实体受到的伤害值
@export var vulnerable: float = 0


func get_hp_percent() -> float:
	return float(hp) / float(hp_max)
