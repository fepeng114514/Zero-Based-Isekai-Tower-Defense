extends Node
class_name MeleeComponent

var attacks: Array = []
var attack_templates: Dictionary = {}
var order: Array = []
var block_min_range: int = 80
var block_max_range: int = 0
var blocker_id = null
var blockeds_ids: Array = []
var max_blocked: int = 1
var block_inc: int = 1
var block_flags: int = 0
var block_bans: int = 0
var search_mode: String = CS.SEARCH_MODE_ENEMY_FIRST
var motion_direction: Vector2 = Vector2(0, 0)
var motion_speed: int = 100
var origin_pos: Vector2 = Vector2(0, 0)
var origin_pos_arrived: bool = true
var melee_slot: Vector2 = Vector2(0, 0)
var melee_slot_offset: Vector2 = Vector2(0, 0)
var melee_slot_arrived: bool = true
var arrived_rect: Rect2 = Rect2(-3, -3, 6, 6)

func set_melee_slot(new_melee_slot: Vector2) -> void:
	melee_slot_arrived = false
	melee_slot = new_melee_slot
	
func set_origin_pos(new_origin_pos: Vector2) -> void:
	origin_pos_arrived = false
	origin_pos = new_origin_pos

func sort_attacks() -> void:
	order = attacks.duplicate()
	order.sort_custom(Utils.attacks_sort_fn)

## 清理无效被拦截
func cleanup_blockeds() -> void:
	# 快速检查是否存在无效拦截
	if blockeds_ids.any(func(id): return not is_instance_valid(EntityDB.get_entity_by_id(id))):
		return
		
	var new_blockeds_ids: Array = []
	
	for id in blockeds_ids:
		if not is_instance_valid(EntityDB.get_entity_by_id(id)):
			continue 
			
		new_blockeds_ids.append(id)
		
	blockeds_ids = new_blockeds_ids
	
## 清理无效拦截者
func cleanup_blocker() -> void:
	if blocker_id == null:
		return
	
	if not is_instance_valid(EntityDB.get_entity_by_id(blocker_id)):
		blocker_id = null
