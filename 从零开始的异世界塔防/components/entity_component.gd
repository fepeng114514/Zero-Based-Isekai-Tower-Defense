extends Node2D
class_name Entity

"""实体类:
	游戏中所有具有行为和属性的对象都可以被表示为实体，例如:
	敌人、友军、塔、子弹、状态效果等。实体类负责管理实体的基本属性和组件，
	并提供一些通用的接口和事件回调，供系统和组件调用。
"""

## 模板名称
var template_name: String = ""
## 实体唯一 ID
var id: int = -1
## 拥有的所有组件对象
var has_components: Dictionary = {}
## 初始组件数据，不包含任何后续修改的数据，用于序列化
var components: Dictionary = {}
## 所有者或来源 ID，通常为生成实体的实体 ID
var source_id: int = -1
## 实体标识符，使用位运算表示
var flags: int = C.FLAG_NONE
## 目标实体 ID，通常用于子弹、状态效果等需要指定目标的实体
var target_id: int = -1
## 禁止的实体标识符，使用位运算表示，表示该实体不能与哪些标识的实体进行交互
var bans: int = C.FLAG_NONE
## 白名单实体模板名称列表，表示该实体只能与这些模板名称的实体进行交互，通常用于状态效果
var whitelist_template: Array = []
## 黑名单实体模板名称列表，表示该实体不能与这些模板名称的实体进行交互，通常用于状态效果
var blacklist_template: Array = []
## 插入时间戳，单位为秒
var insert_ts: float = 0
## 时间戳，单位为秒，通常用于持续时间、子弹飞行时间等
var ts: float = 0
## 持续时间，单位为秒，通常用于状态效果持续时间等
var duration: float = -1
## 禁止的状态效果标识符，使用位运算表示，表示该实体不能与哪些状态效果进行交互，通常用于状态效果互斥
var mod_bans: int = C.FLAG_NONE
## 禁止的状态效果类型标识符，使用位运算表示，表示该实体不能与哪些类型的状态效果进行交互，通常用于状态效果互斥
var mod_type_bans: int = C.MOD_TYPE_NONE
## 已拥有的状态效果 ID 列表，表示该实体当前拥有的状态效果实体 ID 列表，通常用于状态效果管理
var has_mods_ids: Array[int] = []
## 禁止的光环标识符，使用位运算表示，表示该实体不能与哪些光环进行交互，通常用于光环互斥
var aura_bans: int = C.FLAG_NONE
## 禁止的光环类型标识符，使用位运算表示，表示该实体不能与哪些类型的光环进行交互，通常用于光环互斥
var aura_type_bans: int = C.AURA_TYPE_NONE
## 插入实体时创建的光环模板名称列表
var auras_list: Array = []
## 已拥有的光环 ID 列表，表示该实体当前拥有的光环实体 ID 列表，通常用于光环管理
var has_auras_ids: Array[int] = []
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)
## 实体状态，通常用于区分实体的不同阶段或行为模式
var state: int = C.STATE_IDLE
## 协程等待状态
var y_waiting: bool = false
## 等待状态
var waiting: bool = false
## 等待计时
var wait_clock: float = 0
## 等待完毕执行的函数队列，需要形参: Entity
var wait_action_queue: Array = []
## 移除状态，表示实体正在被移除
var removed: bool = false
## 实体等级，通常用于区分实体的强度或阶段
var level: int = 1
## 追踪来源实体，通常用于光环等需要持续追踪的实体
var track_source: bool = false
## 追踪目标实体，通常用于状态效果等需要持续追踪的实体
var track_target: bool = false
## 上一帧位置
var last_position: Vector2 = Vector2(0, 0)

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
func _on_pathway_walk(nav_path_c: NavPathComponent) -> void: pass


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
func _on_aura_period(targets: Array, aura_c: AuraComponent) -> void: pass


## 子弹命中目标时调用
func _on_bullet_hit(target: Entity, bullet_c: BulletComponent) -> void: pass


## 子弹未命中目标时调用
func _on_bullet_miss(target: Entity, bullet_c: BulletComponent) -> void: pass


## 计算子弹伤害系数时调用，返回值为伤害系数
func _on_bullet_calculate_damage_factor(target: Entity, bullet_c: BulletComponent) -> float: return 1.0


func is_enemy() -> bool:
	return flags & C.FLAG_ENEMY


func is_friendly() -> bool:
	return flags & C.FLAG_FRIENDLY


func is_tower() -> bool:
	return flags & C.FLAG_TOWER


func is_modifier() -> bool:
	return flags & C.FLAG_MODIFIER
	

func is_aura() -> bool:
	return flags & C.FLAG_AURA


func is_bullet() -> bool:
	return flags & C.FLAG_BULLET


func get_c(c_name: String):
	if not has_c(c_name):
		printerr("未找到组件: %s" % c_name)
		return null
	
	return has_components[c_name]


func has_c(c_name: String) -> bool:
	return has_components.has(c_name)


func set_c(c_name: String, value) -> bool:
	return has_components.set(c_name, value)
	

func add_c(c_name: String) -> Node:
	var component_script: GDScript = EntityDB.get_component_script(c_name)
	var component_node: Node = component_script.new()
	component_node.name = c_name
	
	add_child(component_node)
	has_components[c_name] = component_node
	return component_node


func merged_c_data(
		c_data: Dictionary, merged: Dictionary, convert_json_data: bool = false
	) -> Dictionary:
	var result = c_data.duplicate_deep()
	
	# 处理合并列表
	if merged.has("list") and result.has("templates"):
		var list: Array = result.list
		var merged_list: Array = merged.list
				
		for i: int in merged_list.size():
			var item: Dictionary = merged_list[i]
			var template: Dictionary = result.templates[item.type]
			list.append(template)
	
	U.deepmerge_dict_recursive(result, merged)
	
	if convert_json_data:
		return U.convert_json_data(result)

	return result


func set_template_data(template_data: Dictionary) -> void:
	if template_data.has("base"):
		merge_base_template(template_data, template_data.base)
	
	for key: String in template_data.keys():
		var property = template_data[key]
		property = U.convert_json_data(property)
		
		set(key, property)

	var t_components = template_data.get("components")
	if not t_components:
		return

	for c_name in t_components.keys():
		var override: Dictionary = t_components[c_name]
		var c_data: Dictionary = EntityDB.get_component_data(c_name)
		
		var data = merged_c_data(c_data, override, true)
		
		var component_node: Node = add_c(c_name)

		for key: String in data:
			var property = data[key]
			
			component_node.set(key, property)


func merge_base_template(template_data: Dictionary, base: String):
	var base_data: Dictionary = EntityDB.get_template_data(base)
	
	if base_data.has("base"):
		merge_base_template(template_data, base_data.base)
		
	U.deepmerge_dict_recursive(template_data, base_data)
	

## 协程等待
func y_wait(time: float = 0, break_fn = null):
	y_waiting = true
	await TimeDB.y_wait(time, break_fn)
	y_waiting = false


## 开始等待，与协程等待不同的是:
## [br]
## 1. 不会从上次暂停的位置继续
## [br]
## 2. 可被外部调用
## [br]
## 等待 0 秒表示等待一帧
func wait(time: float = 0, reset: bool = true) -> void:
	if not reset and waiting:
		return

	waiting = true
	if time == 0:
		wait_clock = 0.01
		return

	wait_clock = time


## 将函数增加到等待完成后执行的函数队列，需要形参: Entity
func insert_wait_action_queue(action_func: Callable) -> void:
	wait_action_queue.append(action_func)


## 检查实体是否在等待
func is_waiting() -> bool:
	return y_waiting or waiting


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
		
		if not U.is_vaild_entity(mod) or filter and not filter.call(mod):
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
		
		if not U.is_vaild_entity(aura) or filter and not filter.call(aura):
			continue
		
		has_auras.append(aura)
		
	return has_auras


func clear_has_auras() -> void:
	for aura: Entity in get_has_auras():
		aura.remove_entity()

	has_auras_ids.clear()


func insert_entity() -> void:
	SystemMgr.insert_queue.append(self)


func remove_entity() -> void:
	if not SystemMgr.call_systems("_on_ready_remove", self):
		return

	SystemMgr.remove_queue.append(self)
	removed = true
	visible = false
	print_debug("移除实体: %s(%d)" % [template_name, id])


## 设定实体位置，根据拥有的组件智能赋值
func set_pos(pos: Vector2) -> void:
	position = pos
	
	if has_c(C.CN_RALLY):
		var rally_c: RallyComponent = get_c(C.CN_RALLY)
		
		rally_c.new_rally(pos)
	
	if has_c(C.CN_NAV_PATH):
		set_nav_path_at_pos(pos)


func set_nav_path_at_pos(pos):
	var source = EntityDB.get_entity_by_id(source_id)
	var node: PathwayNode

	if U.is_vaild_entity(source) and source.has_c(C.CN_NAV_PATH):
		var s_nav_path_c: NavPathComponent = source.get_c(C.CN_NAV_PATH)
		node = PathDB.get_nearst_node(pos, [s_nav_path_c.pi], [s_nav_path_c.spi])
	else:
		node = PathDB.get_nearst_node(pos)

	var nav_path_c: NavPathComponent = get_c(C.CN_NAV_PATH)
	nav_path_c.set_nav_path(node.pi, node.spi, node.ni)
	

func get_animated_sprite(sprite_idx: int = 0) -> AnimatedSprite2D:
	var sprite_c: SpriteComponent = get_c(C.CN_SPRITE)
	var sprite = sprite_c.node_list[sprite_idx]
	
	if not sprite is AnimatedSprite2D:
		printerr
		return null
	
	return sprite
	

func play_animation(anim_name: String, sprite_idx: int = 0) -> void:
	var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
	
	sprite.play(anim_name)
	

func wait_animation(
		anim_name: String, sprite_idx: int = 0, times: int = 1, break_fn = null
	) -> void:
	var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
	var loop_count: int = 0
	
	y_waiting = true
	while loop_count < times and (not break_fn or break_fn.call()):
		loop_count += 1
		await sprite.animation_looped
		
	y_waiting = false
