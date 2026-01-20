class_name HealthComponent
extends Node

@export var hp_max: int = 0
@export var hp: int = 0
@export var health_bar_hidden: bool = false
@export var dead: bool = false
	
func get_hp_percent() -> float:
	return float(self.hp) / float(self.hp_max)
