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
@export var rally_center_position := Vector2.ZERO:
	set(value):
		rally_center_position = value
		queue_redraw()
## 集结点半径
@export var rally_radius: float = 30
## 士兵场景名称
@export var soldier: String = ""
## 生成士兵间隔（秒）
@export var respawn_time: float = 10
## 士兵生成偏移
@export var respawn_offset := Vector2.ZERO:
	set(value):
		respawn_offset = value
		queue_redraw()
## 最大士兵数量
@export var max_soldiers: int = 3
## 生成士兵播放的动画
@export var animation: AnimationData = null
## 生成士兵延迟
@export var delay: float = 0
## 生成士兵播放的音效
@export var sfx: AudioData = null

## 时间戳（秒）
var ts: float = 0
## 上一次士兵数量
var last_soldier_count: int = C.UNSET
var soldier_group: EntityGroup = null


func _ready() -> void:
	soldier_group = EntityGroup.new()
	add_child(soldier_group)


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(
			position, 
			rally_min_range,
			Color(0.448, 0.506, 0.927, 0.604), 
			false,
			6
		)
		draw_circle(
			position, 
			rally_max_range,
			Color(0.448, 0.506, 0.927, 0.604), 
			false,
			6
		)
		
		draw_circle(
			rally_center_position,
			9,
			Color(0.486, 0.294, 1.0, 1.0), 
			true
		)
		draw_circle(
			respawn_offset,
			3,
			Color.GREEN, 
			true
		)


func new_rally_center_position(
		center_position: Vector2, 
		is_force: bool = false
	) -> void:
	rally_center_position = center_position
	
	for i: int in soldier_group.get_child_count():
		var s: Entity = soldier_group.get_child(i)
		var s_rally_c: RallyComponent = s.get_node_or_null(C.CN_RALLY)
		var formation_position: Vector2 = to_formation_position(rally_center_position, max_soldiers, i)
		s_rally_c.new_rally_position(formation_position, is_force, rally_center_position)
		
		var melee_c: MeleeComponent = s.get_node_or_null(C.CN_MELEE)
		if melee_c:
			melee_c.origin_pos = formation_position
	

## 将位置转换为阵型位置
func to_formation_position(pos: Vector2, count: int, idx: int) -> Vector2:
	if count == 1:
		return pos
		
	var a: float = 2 * PI / count
	var angle: float = (idx - 1) * a - C.HALF_PI
	
	return U.point_on_circle(
		pos, rally_radius, angle
	)
