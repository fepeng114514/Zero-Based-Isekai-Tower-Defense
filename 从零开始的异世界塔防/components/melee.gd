extends Node
class_name Melee


@export var min_damage: float = 0
@export var max_damage: float = 0
@export var cooldown: float = 0
@export var damage_type: C.DAMAGE = C.DAMAGE.PHYSICAL
@export var mods: Array[C.ENTITY_TAG] = []
@export var animation: String = "melle"
@export var delay: float = 0
@export var chance: float = 1
@export var vis_flags: Array[C.FLAG] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export var whitelist_tag: Array[C.ENTITY_TAG] = []
@export var blacklist_tag: Array[C.ENTITY_TAG] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
var ts: float = 0
