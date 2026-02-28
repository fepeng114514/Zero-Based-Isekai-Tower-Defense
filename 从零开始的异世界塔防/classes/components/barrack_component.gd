extends Node

## 兵营组件，负责生成士兵并管理士兵列表
class_name BarrackComponent


## 集结范围，表示士兵的可集结范围，单位为像素
@export var rally_ranged: float = 200
## 集结点位置
@export var rally_pos := Vector2.ZERO
## 集结点半径，表示士兵距离集结点中心的半径，单位为像素
@export var rally_radius: float = 30
## 集结点移动速度，表示士兵移动到集结点的速度，单位为像素/秒
@export var rally_speed: float = 50
## 士兵标签，表示生成的士兵实体将使用该模板进行创建
@export var soldier: C.ENTITY_TAG
## 兵营生成士兵的时间间隔，单位为秒
@export var respawn_time: float = 10
## 时间戳，表示上一次生成士兵的时间，用于计算生成士兵的时间间隔
var ts: float = 0
## 最大士兵数量，表示兵营最多可以同时存在的士兵数量，超过该数量时将不再生成新的士兵
@export var max_soldiers: int = 3
## 士兵列表，表示当前兵营生成的士兵实体列表
var soldiers_list: Array = []
## 上一次士兵数量，表示上一次生成士兵时的士兵数量，用于检测士兵数量变化
var last_soldier_count: int = -1


## 清理无效士兵
func cleanup_soldiers() -> void:
	# 快速检查是否存在无效士兵
	if not soldiers_list.any(
			func(s) -> bool: return not U.is_vaild_entity(s)
	):
		return
		
	var new_soldiers_list: Array = []
	
	for s in soldiers_list:
		if not U.is_vaild_entity(s):
			continue 
			
		new_soldiers_list.append(s)
		
	soldiers_list = new_soldiers_list
