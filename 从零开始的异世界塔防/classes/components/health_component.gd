@tool
extends Node2D
class_name HealthComponent
## 血量组件
##
## HealthComponent 可以使实体拥有血量，血量为 0 时移除实体

## 最大血量
@export var hp_max: float = 100

@export_group("Buff")
## 物理护甲
@export var physical_armor: int = 0
## 魔法护甲
@export var magical_armor: int = 0
## 毒抗性
@export var poison_armor: int = 0
## 伤害抗性
##
## 伤害抗性可以百分比减少受到的伤害
@export var damage_resistance: float = 0
## 伤害减免
##
## 伤害减免可以直接减少受到的伤害值
@export var damage_reduction: float = 0
## 反伤
##
# ## 对
# @export var spiked

@export_group("Debuff")
## 易伤
## 
## 易伤可以百分比增加受到的伤害值
@export var vulnerable: float = 0

@export_group("Death")
## 死亡赏金
@export var death_gold: float = 0
## 死亡动画数据
@export var death_animation: AnimationData = null
## 死亡音效数据
@export var death_sfx: AudioData = null

@export_group("Health Bar")
## 血条节点引用
@export var health_bar: TextureProgressBar = null

## 当前血量
var hp: float = 0:
	set(value):
		hp = value
		health_bar.value = get_hp_percent()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if not health_bar:
		warnings.append("没有指定血条子节点！ 是否忘记增加血条子节点？")
	
	return warnings


func _update_health_bar() -> void:
	var new_health_bar: TextureProgressBar = get_node_or_null("HealthBar")
	
	# 只在变化时更新，避免无限循环
	if health_bar != new_health_bar:
		health_bar = new_health_bar
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	EditorUtils.tool_on_tree_call(self, what, _update_health_bar)
	

## 获取当前血量百分比
func get_hp_percent() -> float:
	return float(hp) / float(hp_max) * 100
