@tool
extends Node2D
class_name MeleeAttack


@export var min_damage: float = 25
@export var max_damage: float = 25
@export var cooldown: float = 1
@export var damage_type: C.DAMAGE = C.DAMAGE.PHYSICAL
@export var mods: Array[String] = []
@export var animation: String = "melee"
@export var delay: float = 0
@export var chance: float = 1
@export var disabled: bool = false

@export_group("限制相关")
@export var vis_flags: Array[C.FLAG] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export_file("*.tscn") var whitelist_uid: Array[String] = []
@export_file("*.tscn") var blacklist_uid: Array[String] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
var ts: float = 0
