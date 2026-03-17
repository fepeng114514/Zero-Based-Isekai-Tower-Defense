extends Node
class_name AuraComponent


@export var aura_type: Array[C.ModType] = []:
	set(value): 
		aura_type = value
		aura_type_bits = U.merge_flags(value)
@export var allow_same: bool = false
@export var reset_same: bool = true
@export var replace_same: bool = false
@export var overlay_duration_same: bool = false
@export var remove_banned: bool = true
@export var min_radius: float = 0
@export var max_radius: float = 0
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
@export var mods: Array[String] = []
@export var min_damage: float = 0
@export var max_damage: float = 0
@export var damage_type: C.DamageType = C.DamageType.TRUE
@export var cycle_time: float = 1
@export var max_cycle: int = C.UNSET

var aura_type_bits: int = 0
var curren_cycle: int = 0
var ts: float = 0
