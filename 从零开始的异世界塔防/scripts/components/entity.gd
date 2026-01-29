extends Node2D
class_name Entity

var id: int = -1
var template_name: String = ""
var target_id: int = -1
var source_id: int = -1
var components: Dictionary = {}
var state: String = "idle"
var bans: int = 0
var flags: int = 0
var ts: float = 0
var waiting: bool = false
var mod_bans: int = 0
var mod_type_bans: int = 0
var removed: bool = false
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)
var has_mods: Dictionary = {}

func _ready() -> void:
	var setting_data: Dictionary = Utils.get_setting_data(template_name)
	Utils.set_setting_data(self, setting_data)
	
func get_c(c_name: String):
	return components.get(c_name)

func has_c(c_name: String) -> bool:
	return components.has(c_name)
	
# 创建实体时调用，返回 false 的实体将会在调用完毕后移除
func on_insert() -> bool: return true
	
# 移除实体时调用，返回 false 的实体将不会被移除
func on_remove() -> bool: return true
	
# 实体更新时调用
func on_update(delta: float) -> void: pass
	
# 实体在路径行走时调用
func on_path_walk(nav_path_c: NavPathComponent) -> void: pass

# 实体往集结点行走时调用
func on_nav_walk(nav_point_c: NavPointComponent) -> void: pass

# 实体到达终点时调用
func on_culminate(nav_path_c: NavPathComponent) -> void: pass
	
# 实体受到攻击时调用
func on_damage(health_c: HealthComponent, d: Entity) -> void: pass
	
# 实体死亡时调用
func on_dead(health_c: HealthComponent, d: Entity) -> void: pass
	
# 实体被吃时调用
func on_eat(health_c: HealthComponent, d: Entity) -> void: pass
	
func try_ranged_attack() -> void:
	var ranged_c: RangedComponent = get_c(CS.CN_RANGED)
	
	for a: Dictionary in ranged_c.attacks:
		if not TM.is_ready_time(a.ts, a.cooldown):
			continue
			
		var target = select_search_target(a)
		if not is_instance_valid(target) or not target:
			continue
			
		var b = EntityDB.create_entity(a.bullet)
		b.target_id = target.id
		b.source_id = id
		b.position = position
		
		EntityDB.insert_entity(b)
			
		a.ts = TM.tick_ts

func select_search_target(a: Dictionary):
	if a.bans & CS.FLAG_SOLDIER:
		return search_enemy(a)
	elif a.bans & CS.FLAG_ENEMY:
		return search_soldier(a)
	else:
		return search_target(a)
			
func search_enemy(a: Dictionary):
	var target
	
	match a.search_mode:
		CS.SEARCH_MODE_FIRST: target = EntityDB.find_enemy_first(position, a.min_range, a.max_range, a.flags, a.bans)
		CS.SEARCH_MODE_LAST: target = EntityDB.find_enemy_last(position, a.min_range, a.max_range, a.flags, a.bans)
		CS.SEARCH_MODE_NEARST: target = EntityDB.find_enemy_nearst(position, a.min_range, a.max_range, a.flags, a.bans)
		CS.SEARCH_MODE_FARTHEST: target = EntityDB.find_enemy_farthest(position, a.min_range, a.max_range, a.flags, a.bans)
		CS.SEARCH_MODE_STRONGEST: target = EntityDB.find_enemy_strongest(position, a.min_range, a.max_range, a.flags, a.bans)
		CS.SEARCH_MODE_WEAKEST: target = EntityDB.find_enemy_weakest(position, a.min_range, a.max_range, a.flags, a.bans)
	
	return target

func search_soldier(a: Dictionary):
	pass
	
func search_target(a: Dictionary):
	pass
