@tool
extends Node2D
class_name MeleeAttack


## 最小伤害
@export var min_damage: float = 25
## 最大伤害
@export var max_damage: float = 25
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
@export var chance: float = 1
@export var disabled: bool = false

@export_group("Limit")
@export var vis_flags: Array[C.Flag] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.Flag] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export_file("*.tscn") var whitelist_uid: Array[String] = []
@export_file("*.tscn") var blacklist_uid: Array[String] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
var ts: float = 0


func _ready() -> void:
	if animation == null:
		animation = AnimationData.new({
			"left_right": "melee_left_right",
		})
