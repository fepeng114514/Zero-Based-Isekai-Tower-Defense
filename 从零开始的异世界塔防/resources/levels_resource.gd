extends Resource

var levels_range: Array = [
	1
]

var levels_scenes: Dictionary = {}

func _init():
	for level_idx in levels_range:
		levels_scenes[level_idx] = load("res://scenes/levels/level_%s" % level_idx + ".tscn")
