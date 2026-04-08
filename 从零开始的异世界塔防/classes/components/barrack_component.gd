@tool
extends Node2D
class_name BarrackComponent
## 兵营组件
##
## BarrackComponent 可以使实体生成士兵并管理士兵列表


## 最小集结范围
@export var rally_min_range: float = 0:
	set(value):
		rally_min_range = value
		queue_redraw()
## 最大集结范围
@export var rally_max_range: float = 300:
	set(value):
		rally_max_range = value
		queue_redraw()
## 集结点位置
@export var rally_pos := Vector2.ZERO:
	set(value):
		rally_pos = value
		queue_redraw()
## 集结点半径
@export var rally_radius: float = 30
## 士兵场景名称
@export var soldier: String = ""
## 兵营生成士兵的时间间隔（秒）
@export var respawn_time: float = 10
## 最大士兵数量
@export var max_soldiers: int = 3
## 生成士兵动画数据
@export var spawn_animation: AnimationData = null
## 范围显示偏移
@export var show_range_offset := Vector2.ZERO:
	set(value):
		show_range_offset = value
		queue_redraw()

## 时间戳（秒）
var ts: float = 0
## 士兵列表
var soldiers_list: Array = []
## 上一次士兵数量
var last_soldier_count: int = C.UNSET


func _ready() -> void:
	if spawn_animation == null:
		spawn_animation = AnimationData.new()
		spawn_animation.left_right = "spawn"


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		show_range_offset, 
		3,
		Color(0.835, 0.416, 0.851, 0.604), 
		true
	)
	
	draw_circle(
		position + show_range_offset, 
		rally_min_range,
		Color(0.835, 0.416, 0.851, 0.604), 
		false,
		6
	)
	draw_circle(
		position + show_range_offset, 
		rally_max_range,
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
		if not U.is_valid_entity(s):
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
