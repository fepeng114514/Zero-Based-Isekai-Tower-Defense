@tool
extends Node2D
class_name HealthComponent
## 血量组件，负责实体的血量、护甲、抗性等属性，以及相关的伤害计算.

## 血条节点引用
@export var health_bar: Node2D = null
## 最大血量，表示实体的最大血量
@export var hp_max: float = 0
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

## 当前血量，表示实体当前的血量，为 0 时表示实体死亡
var hp: float = 0


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if not health_bar:
		warnings.append("没有指定血条子节点！ 是否忘记增加血条子节点？")
	
	return warnings


func _update_health_bar() -> void:
	var new_health_bar: Node2D = get_node_or_null("HealthBar")
	
	# 只在变化时更新，避免无限循环
	if health_bar != new_health_bar:
		health_bar = new_health_bar
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_health_bar)
	
	
func get_hp_percent() -> float:
	return float(hp) / float(hp_max)
