@tool
extends Node2D
class_name RangedBase
## 远程攻击基类
##
## RangedBase 是 [RangedComponent] 的远程攻击节点的基类，提供了远程攻击的基本属性和功能。


## 最小攻击距离
@export var min_range: float = 0
## 最大攻击距离
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
## 冷却时间
@export var cooldown: float = 1
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
## 发射子弹的延迟
@export var delay: float = 0
## 攻击概率
@export var chance: float = 1
## 近战攻击时是否可以远程攻击
@export var with_melee: bool = false
## 是否禁用
@export var disabled: bool = false


@export_group("Limit")
## 攻击标识
@export var flags: Array[C.Flag] = []:
	set(value): 
		flags = value
		flag_bits = U.merge_flags(value)
## 不可攻击的实体的标识
@export var bans: Array[C.Flag] = []:
	set(value): 
		bans = value
		ban_bits = U.merge_flags(value)
## 可攻击的实体场景名称
@export var whitelist: Array[String] = []
## 不可以攻击的实体场景名称
@export var blacklist: Array[String] = []

## 二进制的攻击标识
var flag_bits: int = 0
## 二进制的不可攻击的实体的标识
var ban_bits: int = 0
## 时间戳
var ts: float = 0


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	for v: Vector2 in bullet_offsets.to_dict().values():
		if not v:
			continue
		
		draw_circle(
			v, 
			3,
			Color.GREEN, 
			true
		)

	draw_circle(
		position, 
		max_range,
		Color(0.835, 0.416, 0.851, 0.604), 
		false,
		6
	)


func _on_offset_data_changed() -> void:
	queue_redraw()	
