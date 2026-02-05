extends Node
class_name BarrackComponent

var max_soldiers: int = 3
var rally_ranged: int = 200
var rally_pos: Vector2 = Vector2(0, 0)
var rally_radius: int = 30
var rally_speed: int = 50
var respawn_time: float = 10
var soldier: String = "soldier"
var soldiers_list: Array = []
var last_soldier_count: int = -1
var ts: float = 0

## 清理无效士兵
func cleanup_soldiers():
	# 快速检查是否存在无效士兵
	if not soldiers_list.any(func(s): return not is_instance_valid(s)):
		return
		
	var new_soldiers_list: Array = []
	
	for s in soldiers_list:
		if not is_instance_valid(s):
			continue 
			
		new_soldiers_list.append(s)
		
	soldiers_list = new_soldiers_list
