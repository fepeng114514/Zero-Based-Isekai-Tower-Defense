@tool
extends Node2D
class_name MeleeComponent
## 近战组件
##
## MeleeComponent 可以使实体拥有近战攻击与拦截的能力

## 是否不主动前往近战位置
@export var is_passive: bool = false
## 移动速度
@export var speed: float = 100
## 移动动画数据
@export var motion_animation: AnimationData = null
## 近战位置偏移
@export var melee_pos_offset := Vector2.ZERO:
	set(value):
		melee_pos_offset = value
		queue_redraw()
## 到达位置的阈值
@export var arrived_distance: float = 10

## 近战攻击列表
@export_storage var list: Array[MeleeAttack] = []

@export_group("Blocker")
## 是否是拦截者
@export var is_blocker: bool = false
## 拦截最小范围
@export var block_min_range: float = 0
## 拦截最大范围
@export var block_max_range: float = 100
## 搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 最大被拦截者数量
@export var max_blocked: int = 1

@export_group("Blocked")
## 拦截成本
@export var block_cost: int = 1

@export_group("Limit")
## 拦截标识
@export var block_flags: Array[C.Flag] = []:
	set(value): 
		block_flags = value
		block_flag_bits = U.merge_flags(value)
## 拦截禁止的标识
@export var block_bans: Array[C.Flag] = []:
	set(value): 
		block_bans = value
		block_ban_bits = U.merge_flags(value)

## 二进制的拦截标识
var block_flag_bits: int = 0
## 二进制的拦截禁止的标识
var block_ban_bits: int = 0
## 拦截者 ID 列表
var blockers_ids: Array[int] = []
## 拦截数量
##
## 拦截数量根据被拦截者的拦截成本计算
var blocked_count: int = 0
## 被拦截者 ID 列表
var blockeds_ids: Array[int] = []
## 原位置，用于实体返回原始位置
var origin_pos := Vector2.ZERO
## 是否到达原始位置
var origin_pos_arrived: bool = true
## 近战位置
var melee_pos := Vector2.ZERO
## 是否到达近战位置
var melee_pos_arrived: bool = true
## 是否需要设置原位置
var need_origin_setup: bool = true
## 向量速度
var velocity := Vector2.ZERO

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if list.is_empty():
		warnings.append("没有攻击子节点！ 请至少增加一个攻击子节点。")
	
	return warnings


## 自动更新列表
func _update_list() -> void:
	var new_list: Array[MeleeAttack] = []
	
	for child: MeleeAttack in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_list)
	

func _ready() -> void:
	if motion_animation == null:
		motion_animation = AnimationData.new({
			"up": "walk_up",
			"down": "walk_down",
			"left_right": "walk_left_right",
		})

	
func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		melee_pos_offset, 
		3,
		Color.GREEN, 
		true
	)


## 重新计算并设置被拦截者数量（考虑拦截代价）
func reset_blocked_count() -> void:
	var count: int = 0
	
	for id: int in blockeds_ids:
		var b: Entity = EntityDB.get_entity_by_id(id)
		if not b:
			continue
			
		var b_melee_c: MeleeComponent = b.get_c(C.CN_MELEE)
			
		count += b_melee_c.block_cost
		
	blocked_count = count


## 获取被拦截者
func get_blocked(filter: Callable = Callable()) -> Array[Entity]:
	var blocked_list: Array[Entity] = []
	
	for id: int in blockeds_ids:
		var e: Entity = EntityDB.get_entity_by_id(id)
		
		if not e or filter.is_valid() and not filter.call(e):
			continue
		
		blocked_list.append(e)
		
	return blocked_list
