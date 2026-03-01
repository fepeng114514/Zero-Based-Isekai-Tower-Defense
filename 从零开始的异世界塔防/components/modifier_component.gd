extends Node
class_name ModifierComponent

var mod_type_set := FlagSet.new()
@export var mod_type: Array[C.MOD] = []:
	set(value): mod_type_set.set_from_array(value)
@export var allow_same: bool = false
@export var reset_same: bool = true
@export var replace_same: bool = false
@export var overlay_duration_same: bool = false
@export var remove_banned: bool = true
@export var add_damage_factor: float = 1
@export var physical_armor_factor: float = 1
@export var magical_armor_factor: float = 1
@export var damage_resistance_factor: float = 1
@export var add_damage_inc: float = 0
@export var physical_armor_inc: int = 0
@export var magical_armor_inc: int = 0
@export var damage_reduction_inc: float = 0
@export var vulnerable_factor: float = 1
@export var vulnerable_inc: float = 0
@export var speed_factor: float = 1
@export var min_damage: float = 0
@export var max_damage: float = 0
@export var damage_type: C.DAMAGE = C.DAMAGE.TRUE
var ts: float = 0
@export var cycle_time: float = 1
@export var max_cycle: int = C.UNSET
var curren_cycle: int = 0
