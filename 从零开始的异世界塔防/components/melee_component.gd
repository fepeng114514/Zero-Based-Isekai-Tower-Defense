extends Node
class_name MeleeComponent

"""近战组件:
	负责管理实体的近战属性和行为，例如近战攻击范围、近战攻击伤害、近战攻击效果等。
"""

## 是否是拦截者，表示实体是否具有拦截能力
var is_blocker: bool = false
## 被拦截者 ID 列表，表示实体当前正在拦截的被拦截者 ID 列表
var blockeds_ids: Array[int] = []
## 是否是被动障碍，表示实体是否作为被动障碍存在（不主动拦截敌人），通常用于某些特殊的实体，例如路障等
var is_passive_obstacle: bool = false
## 拦截最小范围，单位为像素
var block_min_range: int = 80
## 拦截最大范围，单位为像素
var block_max_range: int = 0
## 搜索模式，表示实体在寻找被拦截者时的目标选择策略，默认为优先敌人
var search_mode: String = C.SEARCH_MODE_ENEMY_FIRST
## 最大可以被拦截数量，表示实体最多可以同时拦截多少个被拦截者，超过该数量后将不再拦截新的被拦截者
var max_blocked: int = 1
## 拦截数量，表示实体当前已经拦截的被拦截者数量，通常用于判断是否可以继续拦截新的被拦截者
## [br]
## 计算拦截数量时，通常会根据被拦截者的拦截成本进行计算，例如某些被拦截者可能具有较高的拦截成本，导致它们占用更多的拦截数量
var blocked_count: int = 0
## 是否是被拦截者
var is_blocked: bool = false
## 拦截成本，表示被拦截者的拦截成本
var block_cost: int = 1
## 拦截者 ID，表示实体当前被哪个拦截者拦截，通常用于被拦截者追踪自己的拦截者
var blocker_id = null
var block_flags: int = 0
var block_bans: int = 0
## 移动方向，表示实体的移动方向
var motion_direction: Vector2 = Vector2(0, 0)
## 移动速度，表示实体前往近战位置的移动速度，单位为像素/秒
var motion_speed: int = 100
## 原始位置，表示实体的原始位置，通常用于实体返回原始位置
var origin_pos: Vector2 = Vector2(0, 0)
## 是否已经到达原始位置，表示实体是否已经返回原始位置
var origin_pos_arrived: bool = true
## 近战位置，表示实体的近战位置，通常用于实体前往近战位置进行攻击
var melee_slot: Vector2 = Vector2(0, 0)
## 近战位置偏移，表示近战位置相对于实体位置的偏移，通常用于调整实体的近战位置
var melee_slot_offset: Vector2 = Vector2(0, 0)
## 是否已经到达近战位置，表示实体是否已经到达近战位置
var melee_slot_arrived: bool = true
## 到达近战位置的阈值
var arrived_dist: int = 10
## 近战攻击列表，表示实体当前拥有的近战攻击列表
var list: Array = []
## 近战攻击模板
var templates: Dictionary = {}
## 已排序的近战攻击列表
var order: Array = []


func calculate_blocked_count():
	var count: int = 0
	
	for id in blockeds_ids:
		var b = EntityDB.get_entity_by_id(id)
		
		if not U.is_vaild_entity(b):
			continue
			
		var b_melee_c: MeleeComponent = b.get_c(C.CN_MELEE)
			
		count += b_melee_c.block_cost
		
	blocked_count = count


func set_melee_slot(new_melee_slot: Vector2) -> void:
	melee_slot_arrived = false
	melee_slot = new_melee_slot
	

func set_origin_pos(new_origin_pos: Vector2) -> void:
	origin_pos_arrived = false
	origin_pos = new_origin_pos


func sort_attacks() -> void:
	order = list.duplicate()
	order.sort_custom(U.attacks_sort_fn)


func get_blocked(filter = null) -> Array[Entity]:
	var blocked_list: Array[Entity] = []
	
	for id in blockeds_ids:
		var e = EntityDB.get_entity_by_id(id)
		
		if not U.is_vaild_entity(e) or filter and not filter.call(e):
			continue
		
		blocked_list.append(e)
		
	return blocked_list


## 清理无效被拦截
func cleanup_blockeds() -> void:
	# 快速检查是否存在无效拦截
	if not blockeds_ids.any(func(id): return not EntityDB.get_entity_by_id(id)):
		return
		
	var new_blockeds_ids: Array[int] = []
	
	for id in blockeds_ids:
		if not EntityDB.get_entity_by_id(id):
			continue 
			
		new_blockeds_ids.append(id)
		
	blockeds_ids = new_blockeds_ids
	

## 清理无效拦截者
func cleanup_blocker() -> void:
	if blocker_id == null:
		return
	
	if not EntityDB.get_entity_by_id(blocker_id):
		blocker_id = null
