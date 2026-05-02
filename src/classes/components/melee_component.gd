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
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_blocker: bool = false:
	set(value):
		is_blocker = value
		update_configuration_warnings()
## 拦截最小范围
@export var block_min_range: float = 0
## 拦截最大范围
@export var block_max_range: float = 100
## 搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 最大被拦截者数量
@export var max_blocked: int = 1

@export_group("Blocked")
## 是否是被拦截者
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var is_blocked: bool = false:
	set(value):
		is_blocked = value
		update_configuration_warnings()
## 拦截成本
@export var block_cost: int = 1

@export_group("Limit")
## 拦截标识
@export var block_flags: int = 0
## 禁止拦截的标识
@export var block_bans: int = 0

## 拦截者 ID 列表
var blocker_ids: Array[int] = []
## 拦截数量
##
## 拦截数量根据被拦截者的拦截成本计算
var blocked_count: int = 0
## 被拦截者 ID 列表
var blocked_ids: Array[int] = []
## 是额外拦截者
var is_extra_blocker: bool = false
## 原位置，用于实体返回原始位置
var origin_pos := Vector2.ZERO
## 近战位置
var melee_pos := Vector2.ZERO
## 向量速度
var velocity := Vector2.ZERO
## 近战状态
var melee_state: C.MeleeState = C.MeleeState.ORIGIN_POS_ARRIVED


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		melee_pos_offset, 
		3,
		Color.GREEN, 
		true
	)
	
	
func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 MeleeBase 节点或其类型的节点，否则实体无法攻击。")
	
	if not is_blocked and not is_blocker:
		warn.append("请至少勾选一个 is_blocked 或 is_blocker 属性，否则无法识别被拦截者与拦截者。")
		
	return warn
	

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"block_flags":
			property.hint_string = "mask_enum:Flag"
		"block_bans":
			property.hint_string = "mask_enum:Flag"

	
## 绑定拦截关系
func bind_melee_relations(target: Entity, e: Entity) -> void: 
	var t_melee_c: MeleeComponent = target.get_node_or_null(C.CN_MELEE)
	
	t_melee_c.blocker_ids.append(e.id)
	blocked_ids.append(target.id)
	blocked_count += t_melee_c.block_cost
	

## 解除拦截关系
func unbind_melee_relations(erase_id: int) -> void:
	if is_blocker:
		for blocked_id: int in blocked_ids:
			var blocked: Entity = EntityMgr.get_entity_by_id(blocked_id)
			var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
			blocked_melee_c.blocker_ids.erase(erase_id)
			
		blocked_ids.clear()
		is_extra_blocker = false
	elif is_blocked:
		for blocker_id: int in blocker_ids:
			var blocker: Entity = EntityMgr.get_entity_by_id(blocker_id)
			var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(C.CN_MELEE)
			blocker_melee_c.blocked_ids.erase(erase_id)
		
		blocker_ids.clear()

## 清理无效拦截关系
func cleanup_melee_relations(e: Entity) -> void:
	if is_blocker:
		var center: Vector2 = e.global_position
		var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
		if rally_c:
			var rally_center_position: Vector2 = rally_c.rally_center_position
			
			if rally_center_position != Vector2.ZERO:
				center = rally_center_position

		var new_blockeds_ids: Array[int] = []
		blocked_count = 0
		
		for id: int in blocked_ids:
			var blocked: Entity = EntityMgr.get_entity_by_id(id)
			if not U.is_valid_entity(blocked) :
				continue 
				
			if not U.is_in_ring(
					center, blocked.global_position, block_min_range, block_max_range
				):
				continue
				
			var b_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
			
			new_blockeds_ids.append(id)
			blocked_count += b_melee_c.block_cost
			
		blocked_ids = new_blockeds_ids
	elif is_blocked:
		var new_blockers_ids: Array[int] = []
		
		for id: int in blocker_ids:
			var blocker: Entity = EntityMgr.get_entity_by_id(id)
			if not U.is_valid_entity(blocker):
				continue 
				
			new_blockers_ids.append(id)
			
		blocker_ids = new_blockers_ids
