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
	set(value): vis_flag_set.set_from_array(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): vis_ban_set.set_from_array(value)
@export var whitelist_tag: Array[C.ENTITY_TAG] = []
@export var blacklist_tag: Array[C.ENTITY_TAG] = []

var vis_flag_set := FlagSet.new()
var vis_ban_set := FlagSet.new()
var ts: float = 0
