extends Node

var cooldowns: Dictionary = {}

func _process(delta: float) -> void:
	var to_remove: Array = []
	for key in cooldowns:
		var cooldown = cooldowns[key]
		cooldown.elapsed += delta
		if cooldown.elapsed < cooldown.time:
			continue
			
		to_remove.append(key)
	
	for key in to_remove:
		cooldowns.erase(key)
			
func start_cooldown(key: String, duration: float):
	cooldowns[key] = { "time": duration, "elapsed": 0.0 }
	
func is_ready(key: String) -> bool:
	return !cooldowns.has(key)
