extends Node
class_name AuraComponent

var aura_type: int = 0
var allow_same: bool = false
var reset_same: bool = true
var replace_same: bool = false
var overlay_duration_same: bool = false
var remove_banned: bool = true
var min_radius: float = 0
var max_radius: float = 0
var search_mode: String = C.SEARCH_ENEMY_FIRST
var mods: Array = []
var min_damage: float = 0
var max_damage: float = 0
var damage_type: int = C.DAMAGE_TRUE
var cycle_time: float = 1
var max_cycle: int = -1
var curren_cycle: int = 0
var ts: float = 0
