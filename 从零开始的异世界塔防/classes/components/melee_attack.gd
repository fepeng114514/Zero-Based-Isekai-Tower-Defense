@tool
extends Node2D
class_name MeleeAttack
## 近战攻击节点


## 最小伤害
@export var damage_min: float = 25
## 最大伤害
@export var damage_max: float = 25
## 伤害类型
@export var damage_type: C.DamageType = C.DamageType.PHYSICAL
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

@export_group("Limit")
## 可见标识
@export var vis_flags: Array[C.Flag] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
## 不可见标识
##
## 该攻击不可以攻击的目标的标识
@export var vis_bans: Array[C.Flag] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
## 可见白名单
##
## 该攻击可攻击的实体的 uid
@export_file("*.tscn") var whitelist_uid: Array[String] = []
## 可见黑名单
##
## 该攻击不可以攻击的实体的 uid
@export_file("*.tscn") var blacklist_uid: Array[String] = []

## 二进制的可见标识
var vis_flag_bits: int = 0
## 二进制的不可见标识
var vis_ban_bits: int = 0
## 时间戳
var ts: float = 0


func _ready() -> void:
	if animation == null:
		animation = AnimationData.new({
			"left_right": "melee_left_right",
		})
