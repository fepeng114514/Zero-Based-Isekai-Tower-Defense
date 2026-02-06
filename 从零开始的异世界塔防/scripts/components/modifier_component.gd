extends Node
class_name ModifierComponent

var mod_type: int = 0
var allow_same: bool = false
var reset_same: bool = true
var replace_same: bool = false
var overlay_duration_same: bool = false
var damage_factor: float = 1
var physical_armor_factor: float = 1
var magical_armor_factor: float = 1
var damage_resistance_factor: float = 1
var damage_inc: int = 0
var physical_armor_inc: int = 0
var magical_armor_inc: int = 0
var damage_resistance_inc: float = 0
var damage_reduction_inc: int = 0
var vulnerable_factor: float = 1
var vulnerable_inc: float = 0
var min_damage: int = 0
var max_damage: int = 0
var damage_interval: float = 1
var damage_type: int = CS.DAMAGE_POISON
var ts: float = 0