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
var waitting: bool = false
var removed: bool = false
var mod_bans: int = 0
var mod_type_bans: int = 0
var has_mods: Dictionary = {}
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)
var state: int = CS.STATE_IDLE
var level: int = 1

# 创建实体时调用，返回 false 的实体跳过创建
func on_create() -> bool: return true

# 插入实体时调用，返回 false 的实体将会在调用完毕后移除
func on_insert() -> bool: return true
	
# 移除实体时调用，返回 false 的实体将不会被移除
func on_remove() -> bool: return true
	
# 实体更新时调用
func on_update(delta: float) -> void: pass
	
# 实体在路径行走时调用
func on_path_walk(nav_path_c: NavPathComponent) -> void: pass

# 实体往集结点行走时调用
func on_nav_walk(rally_c: RallyComponent) -> void: pass

# 实体到达终点时调用
func on_get_end(nav_path_c: NavPathComponent) -> void: pass
	
# 实体受到攻击时调用
func on_damage(health_c: HealthComponent, d: Entity) -> void: pass
	
# 实体死亡时调用
func on_dead(health_c: HealthComponent, d: Entity) -> void: pass
	
# 实体被吃时调用
func on_eat(health_c: HealthComponent, d: Entity) -> void: pass
	
# 兵营生成士兵时调用，返回 false 不生成士兵
func on_respawn(barrack_c: BarrackComponent, soldier: Entity) -> bool: return true
	
func get_c(c_name: String):
	return has_components.get(c_name)

func has_c(c_name: String) -> bool:
	return has_components.has(c_name)

func set_c(c_name: String, value) -> bool:
	return has_components.set(c_name, value)
	
func add_c(c_name: String) -> Node:
	var component_node = DataManager.reqiured_data.required_components.get(c_name).new()
	component_node.name = c_name
	
	add_child(component_node)
	has_components[c_name] = component_node
	return component_node

func merged_c_data(c_name, c_data: Dictionary, merged: Dictionary, convert_json_data: bool = false):
	var result = c_data.duplicate_deep()
	
	if merged.has("attacks") and result.has("attack_templates"):
		var attacks: Array = result.attacks
		var merged_attacks: Array = merged.attacks
				
		for i in merged_attacks.size():
			var ma: Dictionary = merged_attacks[i]
			var template: Dictionary = result.attack_templates[ma.attack_type]
			attacks.append(template)
	
	Utils.deepmerge_dict_recursive(result, merged)
	
	if convert_json_data:
		return Utils.convert_json_data(result)

	return result

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
		var override: Dictionary = components[c_name]
		var c_data: Dictionary = EntityDB.get_component_data(c_name, true)
		
		var data = merged_c_data(c_name, c_data, override, true)
		
		var component_node: Node = add_c(c_name)

		for key: String in data:
			var property = data[key]
			
			component_node.set(key, property)

func merge_base_template(template_data: Dictionary, base: String):
	var base_data: Dictionary = EntityDB.get_template_data(base)
	
	if base_data.has("base"):
		merge_base_template(template_data, base_data.base)
		
	Utils.deepmerge_dict_recursive(template_data, base_data)
	
func y_wait(time: float, break_fn = null):
	waitting = true
	await TM.y_wait(time, break_fn)
	waitting = false
