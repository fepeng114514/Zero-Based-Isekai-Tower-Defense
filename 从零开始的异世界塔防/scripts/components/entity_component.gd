extends Node2D
class_name Entity

var template_name: String = ""
var id: int = -1
var target_id: int = -1
var source_id: int = -1
var has_components: Dictionary = {}
var components: Dictionary = {}
var bans: int = 0
var flags: int = 0
var allowed_templates: Array = []
var excluded_templates: Array = []
var insert_ts: float = 0
var ts: float = 0
var duration: float = -1
var waitting: bool = false
var removed: bool = false
var mod_bans: int = 0
var mod_type_bans: int = 0
var aura_bans: int = 0
var aura_type_bans: int = 0
var has_mods_ids: Array[int] = []
var has_auras_ids: Array[int] = []
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)
var state: int = CS.STATE_IDLE
var level: int = 1
var track_source: bool = false
var track_target: bool = false

## 准备插入实体时调用（创建实体），返回 false 的实体不会被创建
## [br]
## 注：此时节点还未初始化
func _on_ready_insert() -> bool: return true

## 正式插入实体时调用，返回 false 的实体将会被移除
## [br]
## 注：此时节点已准备完毕
func _on_insert() -> bool: return true
	
## 准备移除实体时调用，返回 false 的实体将不会被移除
## [br]
## 注：此时进入移除队列
func _on_ready_remove() -> bool: return true

## 正式移除实体时调用
func _on_remove() -> void: pass
	
## 实体更新时调用
func _on_update(delta: float) -> void: pass
	
## 实体在路径行走时调用
func _on_path_walk(nav_path_c: NavPathComponent) -> void: pass

## 实体往集结点行走时调用
func _on_rally_walk(rally_c: RallyComponent) -> void: pass

## 实体到达路径终点时调用
func _on_arrived_end(nav_path_c: NavPathComponent) -> void: pass

## 实体到达集结点时调用
func _on_arrived_rally(rally_c: RallyComponent) -> void: pass
	
## 实体受到伤害时调用
func _on_damage(target: Entity, d: Damage) -> void: pass
	
## 实体死亡时调用
func _on_dead(target: Entity, d: Damage) -> void: pass
	
## 实体被吃时调用
func _on_eat(target: Entity, d: Damage) -> void: pass
	
## 杀死其他实体时调用
func _on_kill(target: Entity, d: Damage) -> void: pass
	
## 兵营生成士兵时调用，返回 false 不生成士兵
func _on_barrack_respawn(soldier: Entity, barrack_c: BarrackComponent) -> bool: return true

## 状态效果实体周期调用
func _on_modifier_period(target: Entity, mod_c: ModifierComponent) -> void: pass

## 光环实体周期调用
func _on_aura_period(targets: Array[Entity], aura_c: AuraComponent) -> void: pass

## 子弹命中目标时调用
func _on_bullet_hit(target: Entity, bullet_c: BulletComponent) -> void: pass

## 子弹未命中目标时调用
func _on_bullet_miss(target: Entity, bullet_c: BulletComponent) -> void: pass

## 计算子弹伤害系数时调用，返回值为伤害系数
func _on_bullet_calculate_damage_factor(target: Entity, bullet_c: BulletComponent) -> float: return 1.0

func is_enemy() -> bool:
	return flags & CS.FLAG_ENEMY

func is_friendly() -> bool:
	return flags & CS.FLAG_FRIENDLY

func is_tower() -> bool:
	return flags & CS.FLAG_TOWER

func is_modifier() -> bool:
	return flags & CS.FLAG_MODIFIER
	
func is_aura() -> bool:
	return flags & CS.FLAG_AURA

func is_bullet() -> bool:
	return flags & CS.FLAG_BULLET

func get_c(c_name: String):
	return has_components.get(c_name)

func has_c(c_name: String) -> bool:
	return has_components.has(c_name)

func set_c(c_name: String, value) -> bool:
	return has_components.set(c_name, value)
	
func add_c(c_name: String) -> Node:
	var component_node = EntityDB.get_component_script(c_name).new()
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

	var t_components = template_data.get("components")
	if not t_components:
		return

	for c_name in t_components.keys():
		var override: Dictionary = t_components[c_name]
		var c_data: Dictionary = EntityDB.get_component_data(c_name)
		
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
	
func y_wait(time: float = 0, break_fn = null):
	waitting = true
	await TM.y_wait(time, break_fn)
	waitting = false

func cleanup_has_mods():
	var new_has_mods_ids: Array[int] = []
	
	for mod_id in has_mods_ids:
		if not EntityDB.get_entity_by_id(mod_id):
			continue 
			
		new_has_mods_ids.append(mod_id)
		
	has_mods_ids = new_has_mods_ids

func get_has_mods(filter = null) -> Array[Entity]:
	var has_mods: Array[Entity] = []
	
	for mod_id in has_mods_ids:
		var mod = EntityDB.get_entity_by_id(mod_id)
		
		if not Utils.is_vaild_entity(mod) or filter and not filter.call(mod):
			continue
		
		has_mods.append(mod)
		
	return has_mods

func clear_has_mods() -> void:
	for mod: Entity in get_has_mods():
		mod.remove_entity()

	has_mods_ids.clear()

func get_has_auras(filter = null) -> Array[Entity]:
	var has_auras: Array[Entity] = []
	
	for aura_id in has_auras_ids:
		var aura = EntityDB.get_entity_by_id(aura_id)
		
		if not Utils.is_vaild_entity(aura) or filter and not filter.call(aura):
			continue
		
		has_auras.append(aura)
		
	return has_auras

func clear_has_auras() -> void:
	for aura: Entity in get_has_auras():
		aura.remove_entity()

	has_auras_ids.clear()

func insert_entity() -> void:
	SystemManager.insert_queue.append(self)

func remove_entity() -> void:
	if not SystemManager.process_systems("_on_ready_remove", self):
		return

	SystemManager.remove_queue.append(self)
	removed = true
	visible = false
	print("移除实体： %s(%d)" % [template_name, id])
