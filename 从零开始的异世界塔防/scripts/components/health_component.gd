extends Node
class_name HealthComponent

var hp_max: int = 0
var hp: int = 0
var health_bar_scale: Vector2 = Vector2(1, 1)
var health_bar_offset: Vector2 = Vector2(0, -30)
var physical_armor: int = 0
var magical_armor: int = 0
var poison_armor: int = 0
var damage_resistance: float = 0
var damage_reduction: int = 0
var vulnerable: float = 0

func get_hp_percent() -> float:
	return float(hp) / float(hp_max)
