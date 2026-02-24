extends Node
class_name ModifierComponent

## 状态效果类型，使用位运算表示
var mod_type: int = 0
var allow_same: bool = false
var reset_same: bool = true
var replace_same: bool = false
var overlay_duration_same: bool = false
var remove_banned: bool = true
var add_damage_factor: float = 1
var physical_armor_factor: float = 1
var magical_armor_factor: float = 1
var damage_resistance_factor: float = 1
var add_damage_inc: float = 0
var physical_armor_inc: int = 0
var magical_armor_inc: int = 0
var damage_reduction_inc: float = 0
var vulnerable_factor: float = 1
var vulnerable_inc: float = 0
var speed_factor: float = 1
var min_damage: float = 0
var max_damage: float = 0
var damage_type: int = C.DAMAGE_TRUE
var ts: float = 0
var cycle_time: float = 1
var max_cycle: int = -1
var curren_cycle: int = 0
