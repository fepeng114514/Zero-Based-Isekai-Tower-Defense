extends Node
class_name Ranged


@export var min_range: float = 0
@export var max_range: float = 0
@export var cooldown: float = 0
@export var bullet: C.ENTITY_TAG
@export var ts: float = 0
@export var search_mode: C.SEARCH = C.SEARCH.ENEMY_FIRST
@export var vis_flags: Array[C.FLAG] = []:
	set(value): vis_flag_set.set_from_array(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): vis_ban_set.set_from_array(value)
@export var whitelist_tag: Array[C.ENTITY_TAG] = []
@export var blacklist_tag: Array[C.ENTITY_TAG] = []
@export var animation: String = "ranged"
@export var delay: float = 0
@export var chance: float = 1
@export var together_melee: bool = false

var vis_flag_set := FlagSet.new()
var vis_ban_set := FlagSet.new()
