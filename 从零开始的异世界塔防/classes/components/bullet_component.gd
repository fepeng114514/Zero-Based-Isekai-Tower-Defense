@tool
extends Node
class_name BulletComponent
## 子弹组件
##
## BulletComponent 可以使实体按照飞行轨迹飞行，命中目标后造成影响


## 子弹从发射到命中或消失的时间
@export var flight_time: float = 0
## 重力加速度
@export var flight_gravity: float = 980
## 飞行轨迹类型
@export var flight_trajectory: C.Trajectory = C.Trajectory.LINEAR
## 子弹的飞行速度，用于无法指定飞行时间的飞行轨迹
@export var flight_speed: float = 0
## 飞行动画数据
@export var flight_animation: AnimationData = null
## 是否禁用预判目标位置
@export var disabled_predict_pos: bool = false

@export_group("Damage")
## 子弹最小伤害
@export var damage_min: float = 0
## 子弹最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: C.DamageType = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: Array[C.DamageFlag] = []:
	set(value):
		damage_flags = value
		damage_flag_bits = U.merge_flags(damage_flags)
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 范围伤害的搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS

@export_group("Rotation")
## 子弹旋转速度（弧度）
@export var rotation_speed: float = 0
## 是否看向目标点，会覆盖 rotation_speed
@export var look_to: bool = true
## 子弹旋转方向
##
## 1 表示顺时针旋转，-1 表示逆时针旋转
@export var rotation_direction: int = -1

@export_group("Hit")
## 是否可以到达目标位置，表示子弹是否可以飞行到目标位置
@export var can_arrived: bool = true
## 击中目标的阈值
@export var hit_distance: float = 20
## 击中目标后是否移除子弹实体，通常用于一次性子弹
@export var hit_remove: bool = true
## 击中后造成伤害的延迟（秒）
@export var hit_delay: float = 0
## 子弹携带的状态效果
@export var mods: Array[String] = []
## 子弹击中目标时创建的实体场景名称
@export var hit_payloads: Array[String] = []
## 击中动画数据
@export var hit_animation: AnimationData = null
## 击中音效 uid
@export_file("*.ogg") var hit_sfx: String = ""

@export_group("Miss")
## 未击中目标时是否移除子弹实体
@export var miss_remove: bool = true
## 子弹未击中目标时创建的实体场景名称
@export var miss_payloads: Array[String] = []
## 未击中动画数据
@export var miss_animation: AnimationData = null
## 未击中音效 uid
@export_file("*.ogg") var miss_sfx: String = ""

## 二进制的伤害标识
var damage_flag_bits: int = 0
## 起始位置
var from := Vector2.ZERO
## 目标位置
var to := Vector2.ZERO
## 时间戳（秒）
var ts: float = 0
## 子弹向量速度
var velocity := Vector2.ZERO
## 预判目标位置
var predict_target_pos := Vector2.ZERO
