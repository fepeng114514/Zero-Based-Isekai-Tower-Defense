@tool
extends Node2D
class_name BarrackComponent
## 兵营组件，负责生成士兵并管理士兵列表

## 集结范围，表示士兵的可集结范围，单位为像素
@export var rally_range: float = 300:
	set(value):
		rally_range = value
		queue_redraw()
## 集结点位置
@export var rally_pos := Vector2.ZERO:
	set(value):
		rally_pos = value
		queue_redraw()
@export var range_offset := Vector2.ZERO:
	set(value):
		range_offset = value
		queue_redraw()
## 集结点半径，表示士兵距离集结点中心的半径，单位为像素
@export var rally_radius: float = 30
## 士兵 UID，表示生成的士兵实体将使用该模板进行创建
@export_file("*.tscn") var soldier: String = ""
## 兵营生成士兵的时间间隔，单位为秒
@export var respawn_time: float = 10
## 最大士兵数量，表示兵营最多可以同时存在的士兵数量，超过该数量时将不再生成新的士兵
@export var max_soldiers: int = 3
## 生成士兵动画数据
@export var animation: AnimationData = null


## 时间戳，表示上一次生成士兵的时间，用于计算生成士兵的时间间隔
var ts: float = 0
## 士兵列表，表示当前兵营生成的士兵实体列表
var soldiers_list: Array = []
## 上一次士兵数量，表示上一次生成士兵时的士兵数量，用于检测士兵数量变化
var last_soldier_count: int = C.UNSET


func _ready() -> void:
	if animation == null:
		animation = AnimationData.new({
			"left_right": "spawn",
		})


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		range_offset, 
		3,
		Color(0.835, 0.416, 0.851, 0.604), 
		true
	)
	
	draw_circle(
		position + range_offset, 
		rally_range,
		Color(0.835, 0.416, 0.851, 0.604), 
		false,
		6
	)
	
	draw_circle(
		rally_pos,
		9,
		Color(0.486, 0.294, 1.0, 1.0), 
		true
	)


## 清理无效士兵
func cleanup_soldiers() -> void:
	var new_soldiers_list: Array = []
	
	for s in soldiers_list:
		if not U.is_vaild_entity(s):
			continue 
			
		new_soldiers_list.append(s)
		
	soldiers_list = new_soldiers_list


func new_rally(pos: Vector2) -> void:
	rally_pos = pos
	
	for i: int in range(soldiers_list.size()):
		var s: Entity = soldiers_list[i]
		var s_rally_c: RallyComponent = s.get_c(C.CN_RALLY)
		s_rally_c.new_rally(pos)
		s_rally_c.rally_formation_position(max_soldiers, i)
