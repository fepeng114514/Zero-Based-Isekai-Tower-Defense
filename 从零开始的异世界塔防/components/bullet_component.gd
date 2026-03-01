extends Node
class_name BulletComponent
## 子弹组件，负责管理子弹的属性和行为，例如伤害、飞行速度、飞行轨迹、命中效果等。

## 最小伤害，表示子弹造成的最小伤害值
@export var min_damage: float = 0
## 最大伤害，表示子弹造成的最大伤害值
@export var max_damage: float = 0
## 伤害类型，表示子弹造成的伤害类型，使用位运算表示
@export var damage_type: C.DAMAGE = C.DAMAGE.PHYSICAL
## 最小伤害半径，表示子弹造成伤害的范围，单位为像素，通常用于范围伤害的子弹
@export var min_damage_radius: float = 0
## 最大伤害半径，表示子弹造成最大伤害的范围，单位为像素，通常用于范围伤害的子弹
@export var max_damage_radius: float = 0
## 范围伤害的搜索模式，表示子弹在造成范围伤害时的目标选择策略，默认为优先敌人
@export var search_mode: C.SEARCH = C.SEARCH.ENEMY_FIRST
## 子弹携带的状态效果标签列表，表示子弹命中目标时将附加的状态效果标签列表
@export var mods: Array[C.ENTITY_TAG] = []
## 子弹携带的实体标签列表
@export var payloads: Array[C.ENTITY_TAG] = []
## 子弹数值速度，表示子弹的飞行速度，单位为像素/秒
@export var speed: float = 0
## 子弹旋转速度，表示子弹的旋转速度，单位为弧度/秒
@export var rotation_speed: float = 0
## 子弹旋转方向，表示子弹旋转的方向，1 表示顺时针旋转，-1 表示逆时针旋转
@export var rotation_direction: int = -1
## 飞行时间，表示子弹从发射到命中或消失的时间，单位为秒，通常用于计算子弹的飞行轨迹和命中效果
@export var flight_time: float = 0
## 重力加速度，表示子弹受到的重力加速度，单位为像素/秒^2，通常用于抛物线飞行轨迹的子弹
@export var g: float = 980
## 飞行轨迹类型，表示子弹的飞行轨迹类型，例如线性、抛物线等，使用常量表示
@export var flight_trajectory: C.TRAJECTORY = C.TRAJECTORY.LINEAR
## 是否可以到达目标位置，表示子弹是否可以飞行到目标位置
@export var can_arrived: bool = true
## 是否禁用预判目标位置，表示子弹是否禁用预判目标位置，通常用于某些特殊的子弹，例如瞬发子弹等
@export var predict_pos_disabled: bool = false
@export var hit_dist: float = 25
## 击中目标后是否移除子弹实体，通常用于一次性子弹
@export var hit_remove: bool = true
## 未击中目标时是否移除子弹实体
@export var miss_remove: bool = true

## 起始位置，表示子弹的起始位置，单位为像素
var from := Vector2.ZERO
## 目标位置，表示子弹的目标位置，单位为像素
var to := Vector2.ZERO
## 时间戳，用于记录子弹的飞行时间，单位为秒
var ts: float = 0
## 方向向量，表示子弹的飞行方向
var direction := Vector2.RIGHT
## 子弹向量速度，表示子弹的飞行方向和速度，单位为像素/秒，通常用于非线性飞行轨迹的子弹
var velocity := Vector2.ZERO
## 预判目标位置，表示子弹根据目标的移动速度和方向预判的目标位置，单位为像素
var predict_target_pos := Vector2.ZERO
