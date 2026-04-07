@tool
extends Node2D
class_name MeleeAttack
## 近战攻击节点
##
## 用于 [MeleeComponent]


## 冷却时间
@export var cooldown: float = 1
## 击中目标给予的状态效果
@export var mods: Array[String] = []
## 攻击动画数据
@export var animation: AnimationData = null
## 攻击音效数据
@export var sfx: AudioData = null
## 开始攻击到击中目标的延迟，单位为秒
@export var delay: float = 0
## 攻击概率
@export var chance: float = 1
## 是否禁用
@export var disabled: bool = false

@export_group("Damage")
## 最小伤害
@export var damage_min: float = 25
## 最大伤害
@export var damage_max: float = 25
## 伤害类型
@export var damage_type: C.DamageType = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: Array[C.DamageFlag] = []:
	set(value):
		damage_flags = value
		damage_flag_bits = U.merge_flags(damage_flags)

@export_group("Limit")
## 攻击标识
@export var flags: Array[C.Flag] = []:
	set(value): 
		flags = value
		flag_bits = U.merge_flags(value)
## 不可攻击的实体的标识
@export var bans: Array[C.Flag] = []:
	set(value): 
		bans = value
		ban_bits = U.merge_flags(value)
## 可以攻击的实体场景名称
@export var whitelist: Array[String] = []
## 不可攻击的实体场景名称
@export var blacklist: Array[String] = []

## 二进制的攻击标识
var flag_bits: int = 0
## 二进制的不可攻击的实体的标识
var ban_bits: int = 0
## 二进制的伤害标识
var damage_flag_bits: int = 0
## 时间戳
var ts: float = 0


func _ready() -> void:
	if animation == null:
		animation = AnimationData.new()
		animation.left_right = "melee_left_right"
