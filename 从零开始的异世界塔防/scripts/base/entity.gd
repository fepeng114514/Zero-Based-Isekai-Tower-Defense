extends Node2D
class_name Entity

var template_name: String = ""
var id: int = -1
var target_id: int = -1
var source_id: int = -1
var has_components: Dictionary = {}
var bans: int = 0
var flags: int = 0
var ts: float = 0
var waiting: bool = false
var removed: bool = false
var mod_bans: int = 0
var mod_type_bans: int = 0
var has_mods: Dictionary = {}
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)

func _ready() -> void:
	try_sort_attacks()

# 创建实体时调用，返回 false 的实体将会在调用完毕后移除
func on_insert() -> bool: return true
	
# 移除实体时调用，返回 false 的实体将不会被移除
func on_remove() -> bool: return true
	
# 实体更新时调用
func on_update(delta: float) -> void: pass
	
# 实体在路径行走时调用
func on_path_walk(nav_path_c) -> void: pass

# 实体往集结点行走时调用
func on_nav_walk(nav_point_c) -> void: pass

# 实体到达终点时调用
func on_culminate(nav_path_c) -> void: pass
	
# 实体受到攻击时调用
func on_damage(health_c, d: Entity) -> void: pass
	
# 实体死亡时调用
func on_dead(health_c, d: Entity) -> void: pass
	
# 实体被吃时调用
func on_eat(health_c, d: Entity) -> void: pass
	
func get_c(c_name: String):
	return has_components.get(c_name)

func has_c(c_name: String) -> bool:
	return has_components.has(c_name)

func set_template_data(template_data: Dictionary) -> void:
	if template_data.has("base"):
		merge_base_template(template_data, template_data.base)

	var keys: Array = template_data.keys()
	
	for key: String in keys:
		var property = template_data[key]
		property = Utils.convert_json_data(property)
		
		set(key, property)

	var components = template_data.get("components")
	
	if not components:
		return

	for c_name in components.keys():
		var c_data: Dictionary = EntityDB.get_component_data(c_name)
		var component: Dictionary = components[c_name]
		
		if component.has("attacks") and c_data.has("template"):
			var attacks: Array = component.attacks
			
			for i in attacks.size():
				attacks[i] = Utils.merge_dict_recursive_new(c_data.template, attacks[i], true)

		Utils.merge_dict_recursive(c_data, component)

		has_components[c_name] = Utils.convert_json_data(c_data)

func merge_base_template(template_data: Dictionary, base: String):
	var base_data: Dictionary = EntityDB.get_template_data(base)
	
	if base_data.has("base"):
		merge_base_template(template_data, base_data.base)
		
	Utils.merge_dict_recursive(template_data, base_data)

func try_sort_attacks():
	if has_c(CS.CN_MELEE):
		sort_melee_attacks()
	
	if has_c(CS.CN_RANGED):
		sort_ranged_attacks()
	
func attacks_sort_fn(a1, a2):
	var a1_chance: float = a1.chance
	var a2_chance: float = a2.chance
	var a1_cooldown: float = a1.cooldown
	var a2_cooldown: float = a2.cooldown
	
	return (a1_chance != a2_chance and a1_chance < a2_chance) or (a1_cooldown != a2_cooldown and a1_cooldown > a2_cooldown)
	
func sort_melee_attacks():
	var melee_c = get_c(CS.CN_MELEE)
	
	melee_c.order = melee_c.attacks.duplicate()
	melee_c.order.sort_custom(attacks_sort_fn)
	
func sort_ranged_attacks():
	var ranged_c = get_c(CS.CN_RANGED)
	
	ranged_c.order = ranged_c.attacks.duplicate()
	ranged_c.order.sort_custom(attacks_sort_fn)
	
func try_ranged_attack() -> void:
	var ranged_c = get_c(CS.CN_RANGED)
	
	if not ranged_c:
		return
	
	for a: Dictionary in ranged_c.order:
		if not TM.is_ready_time(a.ts, a.cooldown):
			continue
			
		var target = EntityDB.search_target(a.search_mode, position, a.min_range, a.max_range, a.flags, a.bans)
		if not is_instance_valid(target) or not target:
			continue
			
		var b = EntityDB.create_entity(a.bullet)
		b.target_id = target.id
		b.source_id = id
		b.position = position
		
		EntityDB.insert_entity(b)
			
		a.ts = TM.tick_ts

# func try_melee_attack():
# 	var melee_c = get_c(CS.CN_MELEE)
	
# 	if not melee_c:
# 		return
		
# 	var targets1 = EntityDB.find_enemy_sort_with_block_level(position, melee_c.block_min_range, melee_c.block_max_range, melee_c.block_flags, melee_c.block_bans)	
# 	var targets2 = EntityDB.find_enemy_sort_with_block_level(position, melee_c.block_min_range, melee_c.block_max_range, melee_c.block_flags, melee_c.block_bans)	
# 	for a: Dictionary in melee_c.order:
# 		pass
