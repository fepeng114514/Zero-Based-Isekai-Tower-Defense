extends Node
class_name MeleeComponent

var attacks: Array = []
var attack_templates: Dictionary = {}
var order: Array = []
var block_min_range: int = 80
var block_max_range: int = 0
var blocker_id = null
var blockeds_ids: Array[int] = []
var max_blocked: int = 1
var blocked_count: int = 0
var block_cost: int = 1
var block_flags: int = 0
var block_bans: int = 0
var is_passive_obstacle: bool = false
var search_mode: String = CS.SEARCH_MODE_ENEMY_FIRST
var motion_direction: Vector2 = Vector2(0, 0)
var motion_speed: int = 100
var origin_pos: Vector2 = Vector2(0, 0)
var origin_pos_arrived: bool = true
var melee_slot: Vector2 = Vector2(0, 0)
var melee_slot_offset: Vector2 = Vector2(0, 0)
var melee_slot_arrived: bool = true
var arrived_rect: Rect2 = Rect2(-3, -3, 6, 6)

func calculate_blocked_count():
	var count: int = 0
	
	for id in blockeds_ids:
		var b = EntityDB.get_entity_by_id(id)
		
		if not b:
			continue
			
		var b_melee_c: MeleeComponent = b.get_c(CS.CN_MELEE)
			
		count += b_melee_c.block_cost
		
	blocked_count = count

func set_melee_slot(new_melee_slot: Vector2) -> void:
	melee_slot_arrived = false
	melee_slot = new_melee_slot
	
func set_origin_pos(new_origin_pos: Vector2) -> void:
	origin_pos_arrived = false
	origin_pos = new_origin_pos

func sort_attacks() -> void:
	order = attacks.duplicate()
	order.sort_custom(Utils.attacks_sort_fn)

func get_blocked(filter = null) -> Array[Entity]:
	var blocked_list: Array[Entity] = []
	
	for id in blockeds_ids:
		var e = EntityDB.get_entity_by_id(id)
		
		if not e or filter and not filter.call():
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
