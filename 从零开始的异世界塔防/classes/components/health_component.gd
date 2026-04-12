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
## 对伤害来源的反伤
@export var spiked: float = C.UNSET
## 免疫的伤害类型
@export var immuned: Array[C.Flag] = []:
	set(value): 
		immuned = value
		immuned_bits = U.merge_flags(value)

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

## 当前血量
var hp: float = 0:
	set(value):
		hp = value
		health_bar.value = get_hp_percent()
## 二进制的免疫的伤害类型
var immuned_bits: int = 0


## 血条节点引用
@onready var health_bar: TextureProgressBar = get_node_or_null("HealthBar")
	

## 获取当前血量百分比
func get_hp_percent() -> float:
	return float(hp) / float(hp_max) * 100
