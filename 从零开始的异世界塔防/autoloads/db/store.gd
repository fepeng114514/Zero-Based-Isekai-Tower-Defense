extends Node

var level_idx: int = 1
var force_wave: int = 0
var current_wave: int = 0
var waves_finished: bool = false
var cash: float = 0:
	set(value):
		S.set_cash.emit(value)
		cash = value
var life: int = 20:
	set(value):
		S.set_life.emit(value)
		life = value
