extends Node2D
class_name TowerComponent

## 攻击最小范围
@export var min_range: float = 0
## 攻击最大范围
@export var max_range: float = 0
## 索敌模式
@export var search_mode: C.SEARCH = C.SEARCH.ENTITY_FIRST
## 每个子实体进行远程攻击轮换的间隔
@export var attack_loop_time: float = 0

@export_group("限制相关")
@export var vis_flags: Array[C.FLAG] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export var whitelist_tag: Array[C.ENTITY_TAG] = []
@export var blacklist_tag: Array[C.ENTITY_TAG] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
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
