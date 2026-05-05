@tool
extends Node
class_name BulletComponent
## 子弹组件
##
## BulletComponent 可以使实体按照飞行轨迹飞行，命中目标后造成影响


## 飞行轨迹类型
@export var flight_trajectory: C.Trajectory = C.Trajectory.LINEAR:
	set(value):
		flight_trajectory = value
		notify_property_list_changed()
## 子弹从发射到命中或消失的时间
@export var flight_total_time: float = 0
## 子弹的飞行速度
@export var flight_speed: float = 0
## 重力加速度
@export var flight_gravity: float = 980
## 飞行动画数据
@export var flight_animation: AnimationData = null
## 是否禁用预判目标位置
@export var disabled_predict_pos: bool = false

@export_group("Rotation")
## 子弹旋转速度（弧度）
@export var rotation_speed: float = 0
## 是否看向目标点，会覆盖 rotation_speed
@export var look_to: bool = true

@export_group("Hit")
## 是否可以到达目标位置
@export var can_arrived: bool = true
## 击中目标的阈值
@export var hit_distance: float = 20
## 击中目标后是否移除子弹实体
@export var hit_remove: bool = true
## 击中后造成伤害的延迟（秒）
@export var hit_delay: float = 0
## 子弹击中目标时创建的实体场景名称
@export var hit_payloads := PackedStringArray()
## 击中动画
@export var hit_animation: AnimationData = null
## 击中音效
@export var hit_sfx: AudioData = null

@export_group("Miss")
## 未击中目标时是否移除子弹实体
@export var miss_remove: bool = true
## 子弹未击中目标时创建的实体场景名称
@export var miss_payloads := PackedStringArray()
## 未击中动画数据
@export var miss_animation: AnimationData = null
## 未击中音效数据
@export var miss_sfx: AudioData = null

## 子弹最小伤害
var damage_min: float = 0
## 子弹最大伤害
var damage_max: float = 0
## 伤害类型
var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
var damage_flags: int = 0
## 子弹携带的状态效果
var mods := PackedStringArray()
## 是否启用范围伤害
var damage_area_enable: bool = false
## 最小伤害半径
var damage_min_radius: float = 0
## 最大伤害半径
var damage_max_radius: float = 0
## 最大伤害数量
var damage_max_count: int = C.UNSET
## 范围伤害的圆心偏移
var damage_offset := Vector2.ZERO
## 是否可以伤害重复敌人
var can_damage_same: bool = false
## 范围伤害的搜索模式
var damage_search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 范围伤害是否随距离衰减
var damage_falloff_enabled: bool = false
## 起始位置
var from := Vector2.ZERO
## 目标位置
var to := Vector2.ZERO
## 时间戳（秒）
var ts: float = 0
## 子弹向量速度
var velocity := Vector2.ZERO
## 子弹旋转方向
##
## 1 表示顺时针旋转，-1 表示逆时针旋转
var rotation_direction: int = -1
## 预判目标位置
var predict_target_pos := Vector2.ZERO
## 伤害过的实体 ID 列表
var damaged_entity_ids := PackedInt32Array()


func _validate_property(property: Dictionary):
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"flight_total_time":
			if flight_trajectory in [C.Trajectory.TRACKING, C.Trajectory.INSTANT]:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"flight_speed":
			if flight_trajectory != C.Trajectory.TRACKING:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"flight_gravity":
			if flight_trajectory != C.Trajectory.PARABOLA:
				property.usage = PROPERTY_USAGE_NO_EDITOR
