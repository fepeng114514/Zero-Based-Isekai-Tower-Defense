@tool
extends Node2D
class_name Entity

## 实体节点: [br]
## 游戏中所有具有行为和属性的对象都可以被表示为实体，例如: 敌人、友军、塔、子弹、状态效果等。 [br]
## 实体类负责管理实体的基本属性和组件，并提供一些通用的接口和事件回调，供系统和组件调用。

#region 属性
## 实体 UID
@export_file("*.tscn") var uid: String = ""
## 拥有的所有组件节点引用
@export var components: Dictionary[String, Node] = {}
## 持续时间，单位为秒
@export var duration: float = C.UNSET
## 实体等级
@export var level: int = 1
## 是否追踪 source 实体
@export var track_source: bool = false
## 是否追踪 target 实体
@export var track_target: bool = false
@export var default_animation: String = "idle"

@export_group("限制相关")
## 白名单实体 UID 列表
@export_file("*.tscn") var whitelist_uid: Array[String] = []
## 黑名单实体 UID 列表
@export_file("*.tscn") var blacklist_uid: Array[String] = []
## 实体标识符列表
@export var flags: Array[C.FLAG] = []:
	set(value): 
		flags = value
		flag_bits = U.merge_flags(value)
## 禁止的实体标识符列表
@export var bans: Array[C.FLAG] = []:
	set(value): 
		bans = value
		ban_bits = U.merge_flags(value)
## 禁止的状态效果类型标识符列表
@export var mod_type_bans: Array[C.MOD] = []:
	set(value): 
		mod_type_bans = value
		mod_type_ban_bits = U.merge_flags(value)
## 禁止的光环类型标识符列表
@export var aura_type_bans: Array[C.AURA] = []:
	set(value): 
		aura_type_bans = value
		aura_type_ban_bits = U.merge_flags(value)
## 禁止的状态效果标识符列表
@export var mod_bans: Array[C.FLAG] = []:
	set(value): 
		mod_bans = value
		mod_ban_bits = U.merge_flags(value)
## 禁止的光环标识符列表
@export var aura_bans: Array[C.FLAG] = []:
	set(value): 
		aura_bans = value
		aura_ban_bits = U.merge_flags(value)

## 实体唯一 ID
var id: int = C.UNSET
## 是否是子实体
var is_subentity: bool = false
## 所有者或来源 ID
var source_id: int = C.UNSET
## 插入时间戳，单位为秒
var insert_ts: float = 0
## 时间戳，单位为秒
var ts: float = 0
## 目标实体 ID
var target_id: int = C.UNSET
## 禁止的实体标识符（位运算）
var ban_bits: int = 0
## 实体标识符（位运算）
var flag_bits: int = 0
## 禁止的状态效果标识符
var mod_ban_bits: int = 0
## 禁止的状态效果类型标识符（位运算）
var mod_type_ban_bits: int = 0
## 禁止的光环标识符（位运算）
var aura_ban_bits: int = 0
## 禁止的光环类型标识符（位运算）
var aura_type_ban_bits: int = 0
## 拥有的状态效果 ID 列表
var has_mods_ids: Array[int] = []
## 拥有的光环 ID 列表
var has_auras_ids: Array[int] = []
## 等待状态
var waiting: bool = false
## 锁定状态
var blocking: bool = false
## 是否被点击选择
var selected: bool = false
## 移除状态，表示实体正在被移除
var removed: bool = false
## 上一帧位置
var last_position := Vector2.ZERO
var state := C.STATE.IDLE
#endregion


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert() -> bool: return true

## 准移除实体时调用，返回 false 的实体将不会被移除
func _on_remove() -> bool: return true

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


func _to_string():
	return String(name)
@warning_ignore_restore("unused_parameter")
#endregion


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
		
	uid = ResourceUID.path_to_uid(scene_file_path)


## 自动更新组件字典
func _update_components() -> void:
	var new_dict: Dictionary[String, Node] = {}
	
	for node: Node in get_children():
		var node_script: GDScript = node.get_script()
		if not node_script:
			continue
		
		var node_class: String = node_script.get_global_name()
		if not node_class.find("Component"):
			continue
			
		new_dict[node_class] = node
		
	# 只在变化时更新，避免无限循环
	if new_dict != components:
		components = new_dict
		notify_property_list_changed()  # 刷新编辑器


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_components)


func insert_entity() -> void:
	S.insert_entity_s.emit(self)
	SystemMgr.insert_queue.append(self)


func remove_entity() -> void:
	removed = true
	SystemMgr.remove_queue.append(self)
	Log.debug("移除实体: %s" % self)


#region 组件相关方法
func get_c(c_name: String) -> Node:
	return components.get(c_name)


func has_c(c_name: String) -> bool:
	return components.has(c_name)


func set_c(c_name: String, value) -> bool:
	return components.set(c_name, value)
	

func add_c(component: GDScript) -> Node:
	var component_node: Node = component.new()
	
	add_child(component_node)
	var node_class: String = component.get_global_name()
			
	components[node_class] = component_node
	return component_node

#endregion


## 清理无效状态效果
func cleanup_has_mods() -> void:
	var new_has_mods_ids: Array[int] = []
	
	for mod_id in has_mods_ids:
		if not EntityDB.get_entity_by_id(mod_id):
			continue 
			
		new_has_mods_ids.append(mod_id)
		
	has_mods_ids = new_has_mods_ids


func get_has_mods(filter: Callable = Callable()) -> Array[Entity]:
	var has_mods: Array[Entity] = []
	
	for mod_id in has_mods_ids:
		var mod: Entity = EntityDB.get_entity_by_id(mod_id)
		
		if not mod or filter.is_valid() and not filter.call(mod):
			continue
		
		has_mods.append(mod)
		
	return has_mods


func clear_has_mods() -> void:
	for mod: Entity in get_has_mods():
		mod.remove_entity()

	has_mods_ids.clear()


func get_has_auras(filter: Callable = Callable()) -> Array[Entity]:
	var has_auras: Array[Entity] = []
	
	for aura_id in has_auras_ids:
		var aura: Entity = EntityDB.get_entity_by_id(aura_id)
		
		if not aura or filter.is_valid() and not filter.call(aura):
			continue
		
		has_auras.append(aura)
		
	return has_auras


func clear_has_auras() -> void:
	for aura: Entity in get_has_auras():
		aura.remove_entity()

	has_auras_ids.clear()


## 设定实体位置，根据拥有的组件智能赋值
func set_pos(pos: Vector2) -> void:
	global_position = pos
	
	if has_c(C.CN_RALLY):
		var rally_c: RallyComponent = get_c(C.CN_RALLY)
		
		rally_c.new_rally(pos)
	
	if has_c(C.CN_NAV_PATH):
		set_nav_path_at_pos(pos)


func set_nav_path_at_pos(pos: Vector2) -> void:
	var source: Entity = EntityDB.get_entity_by_id(source_id)
	var node: PathwayNode

	if source and source.has_c(C.CN_NAV_PATH):
		var s_nav_path_c: NavPathComponent = source.get_c(C.CN_NAV_PATH)
		node = PathDB.get_nearst_node(pos, [s_nav_path_c.pi], [s_nav_path_c.spi])
	else:
		node = PathDB.get_nearst_node(pos)

	var nav_path_c: NavPathComponent = get_c(C.CN_NAV_PATH)
	nav_path_c.set_nav_path(node.pi, node.spi, node.ni)
	

#region 动画相关方法
## 获取指定索引的动画精灵
func get_animated_sprite(sprite_idx: int = 0) -> Node2D:
	var sprite_c: SpriteComponent = get_c(C.CN_SPRITE)
	if not sprite_c:
		Log.error("get_animated_sprite: 未找到 SpriteComponent 组件: %s" % self)
		return null
	
	var sprite: Variant = sprite_c.list[sprite_idx]
	
	if sprite is not AnimatedSprite2D:
		return null
	
	return sprite
	
	
## 播放动画
func play_animation(anim_name: String, sprite_idx: int = 0) -> void:
	var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
	if not sprite:
		return
		
	if sprite.animation == anim_name:
		return
		
	Log.verbose("播放动画: %s, %s" % [self, anim_name])
	sprite.play(anim_name)
	

## 等待动画播放完成
func wait_animation(
		sprite_idx: int = 0, times: int = 1, break_fn: Callable = Callable()
	) -> void:
	var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
	var loop_count: int = 0
	
	waiting = true
	while loop_count < times and (not break_fn.is_valid() or break_fn.call()):
		loop_count += 1
		await sprite.animation_looped
	waiting = false
#endregion


## 协程等待，break_fn 返回 true 表示中断等待
func y_wait(time: float = U.fts(1), break_fn: Callable = Callable()) -> void:
	waiting = true
	Log.verbose("实体等待: %s, %.2f" % [self, time])
	await TimeDB.y_wait(time, break_fn)
	Log.verbose("实体等待完毕: %s, %.2f" % [self, time])
	waiting = false


func is_waiting() -> bool:
	return waiting or blocking
