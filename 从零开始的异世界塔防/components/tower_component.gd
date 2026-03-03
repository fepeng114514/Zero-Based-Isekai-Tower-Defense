extends Node2D
class_name TowerComponent


## 每个子实体进行远程攻击轮换的间隔
@export var attack_loop_time: float = 0
var list: Array[Entity] = []
var attack_entity_idx: int = 0
var ts: float = 0


## 清理 list 中已经不存在的实体
func cleanup_list() -> void:
	var new_list: Array[Entity] = []
	
	for sub_e in list:
		if not U.is_vaild_entity(sub_e):
			continue 
			
		new_list.append(sub_e)
		
	list = new_list
