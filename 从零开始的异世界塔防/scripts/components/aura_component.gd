extends Node
class_name AuraComponent

var aura_type: int = 0
var allow_same: bool = false
var reset_same: bool = true
var replace_same: bool = false
var overlay_duration_same: bool = false
var remove_banned: bool = true
var min_radius: int = 0
var max_radius: int = 0
var search_mode: String = CS.SEARCH_MODE_ENEMY_FIRST
var mods: Array = []
var period_interval: float = 1
var ts: float = 0
var min_damage: int = 0
var max_damage: int = 0
var damage_type: int = CS.DAMAGE_TRUE
