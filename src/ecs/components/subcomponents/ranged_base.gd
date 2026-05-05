@tool
extends Attackbase
class_name RangedBase
## 远程攻击基类
##
## RangedBase 是 [RangedComponent] 的远程攻击节点的基类，提供了远程攻击的基本属性和功能。


## 最小攻击距离
@export var min_range: float = 0:
	set(value):
		min_range = value
		queue_redraw()
## 最大攻击距离
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
## 目标搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 子弹场景名称
@export var bullet: String = ""
## 子弹发射数量
@export var bullet_count: int = 1
## 子弹初始位置偏移
@export var bullet_offsets: OffsetData = null
## 子弹发射的角度范围，单位为度
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0
## 子弹发射模式
@export var bullet_spawn_mode: C.BulletSpawnMode = C.BulletSpawnMode.EQUAL_INTERVAL
## 近战攻击时是否可以远程攻击
@export var with_melee: bool = false


func _ready() -> void:
	bullet_offsets.changed.connect(_on_offset_data_changed)


func _validate_property(property: Dictionary):
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"


func _draw() -> void:
	if Engine.is_editor_hint():
		for offset_value: Vector2 in bullet_offsets.to_dict().values():
			if not offset_value:
				continue
			
			draw_circle(
				offset_value, 
				3,
				Color.GREEN, 
				true
			)

		draw_circle(
			position, 
			max_range,
			Color(0.401, 0.865, 0.386, 0.604), 
			false,
			6
		)
		draw_circle(
			position, 
			min_range,
			Color(0.401, 0.865, 0.386, 0.604), 
			false,
			6
		)


func _on_offset_data_changed() -> void:
	queue_redraw()	
