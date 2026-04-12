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
## 禁止拦截的标识
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
## 近战位置
var melee_pos := Vector2.ZERO
## 向量速度
var velocity := Vector2.ZERO
## 近战状态
var melee_state: C.MeleeState = C.MeleeState.IDLE
## 近战攻击列表
var list: Array[MeleeAttack] = []


func _ready() -> void:
	if motion_animation == null:
		motion_animation = AnimationData.new()
		motion_animation.up = "walk_up"
		motion_animation.down = "walk_down"
		motion_animation.left_right = "walk_left_right"
		
	for child: MeleeAttack in get_children():
		list.append(child)
	
	
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
	blocked_count = 0
	
	for id: int in blockeds_ids:
		var blocked: Entity = EntityMgr.get_entity_by_id(id)
		if not U.is_valid_entity(blocked):
			continue
			
		var b_melee_c: MeleeComponent = blocked.get_c(C.CN_MELEE)
			
		blocked_count += b_melee_c.block_cost
	

## 解除拦截关系
func unbind_melee_relations(erase_id: int) -> void:
	if is_blocker:
		for blocked_id: int in blockeds_ids:
			var blocked: Entity = EntityMgr.get_entity_by_id(blocked_id)
			var blocked_melee_c: MeleeComponent = blocked.get_c(C.CN_MELEE)
			blocked_melee_c.blockers_ids.erase(erase_id)
	else:
		for blocker_id: int in blockers_ids:
			var blocker: Entity = EntityMgr.get_entity_by_id(blocker_id)
			var blocker_melee_c: MeleeComponent = blocker.get_c(C.CN_MELEE)
			blocker_melee_c.blockeds_ids.erase(erase_id)


## 清理无效拦截关系
func cleanup_melee_relations() -> void:
	if is_blocker:
		var new_blockeds_ids: Array[int] = []
		blocked_count = 0
		
		for id: int in blockeds_ids:
			var blocked: Entity = EntityMgr.get_entity_by_id(id)
			if not U.is_valid_entity(blocked):
				continue 
				
			var b_melee_c: MeleeComponent = blocked.get_c(C.CN_MELEE)
				
			new_blockeds_ids.append(id)
			blocked_count += b_melee_c.block_cost
			
		blockeds_ids = new_blockeds_ids
	else:
		var new_blockers_ids: Array[int] = []
		
		for id: int in blockers_ids:
			var blocker: Entity = EntityMgr.get_entity_by_id(id)
			if not U.is_valid_entity(blocker):
				continue 
				
			new_blockers_ids.append(id)
			
		blockers_ids = new_blockers_ids
