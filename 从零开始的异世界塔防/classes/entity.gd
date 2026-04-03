@tool
extends Node2D
class_name Entity
## 实体节点
##
## 游戏中所有具有行为和属性的对象都可以被表示为实体，例如: 敌人、友军、塔、子弹、状态效果等。 
## 实体类存储实体的基本属性和组件，提供通用的接口和事件回调，供系统和组件调用。

#region 属性
## 拥有的所有组件节点引用
@export var components: Dictionary[String, Node] = {}
## 持续时间
@export var duration: float = C.UNSET
## 实体等级
@export var level: int = 1
## 是否追踪 source 实体
@export var track_source: bool = false
## 是否追踪 target 实体
@export var track_target: bool = false
## 空闲动画数据
@export var idle_animation: AnimationData = null
## 击中位置偏移
@export var hit_offset := Vector2.ZERO:
	set(value):
		hit_offset = value
		queue_redraw()

@export_group("Limit")
## 白名单实体场景名称
@export var whitelist: Array[String] = []
## 黑名单实体场景名称
@export var blacklist: Array[String] = []
## 实体标识
@export var flags: Array[C.Flag] = []:
	set(value): 
		flags = value
		flag_bits = U.merge_flags(value)
## 禁止的实体的标识
@export var bans: Array[C.Flag] = []:
	set(value): 
		bans = value
		ban_bits = U.merge_flags(value)
## 禁止的状态效果类型标识
@export var mod_type_bans: Array[C.ModType] = []:
	set(value): 
		mod_type_bans = value
		mod_type_ban_bits = U.merge_flags(value)
## 禁止的光环类型标识
@export var aura_type_bans: Array[C.ModType] = []:
	set(value):
		aura_type_bans = value
		aura_type_ban_bits = U.merge_flags(value)
## 禁止的状态效果标识
@export var mod_bans: Array[C.Flag] = []:
	set(value): 
		mod_bans = value
		mod_ban_bits = U.merge_flags(value)
## 禁止的光环标识
@export var aura_bans: Array[C.Flag] = []:
	set(value): 
		aura_bans = value
		aura_ban_bits = U.merge_flags(value)

## 实体场景名称
var scene_name: String = ""
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
## 二进制的禁止的实体标识符
var ban_bits: int = 0
## 二进制的实体标识符
var flag_bits: int = 0
## 二进制的禁止的状态效果标识
var mod_ban_bits: int = 0
## 二进制的禁止的状态效果类型标识
var mod_type_ban_bits: int = 0
## 二进制的禁止的光环标识
var aura_ban_bits: int = 0
## 二进制的禁止的光环类型标识
var aura_type_ban_bits: int = 0
## 拥有的状态效果 ID 列表
var has_mods_ids: Array[int] = []
## 拥有的光环 ID 列表
var has_auras_ids: Array[int] = []
## 锁定状态
var blocking: bool = false
## 是否被点击选择
var selected: bool = false
## 移除状态，表示实体正在被移除
var removed: bool = false
## 上一帧位置
var last_position := Vector2.ZERO
## 状态
var state := C.State.IDLE
## 看向的点
var look_at_point := Vector2.INF
## 等待状态
var _waiting: bool = false
#endregion


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert() -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
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
func _on_damage(target: Entity, damage: Damage) -> void: pass
	

## 实体死亡时调用
func _on_death(target: Entity, damage: Damage) -> void: pass
	

## 实体被吃时调用
func _on_eat(target: Entity, damage: Damage) -> void: pass
	

## 杀死其他实体时调用
func _on_kill(target: Entity, damage: Damage) -> void: pass
	

## 兵营生成士兵时调用，返回 false 不生成士兵
func _on_barrack_respawn(soldier: Entity, barrack_c: BarrackComponent) -> bool: return true


## 状态效果实体周期调用
func _on_modifier_period(target: Entity, mod_c: ModifierComponent) -> void: pass


## 光环实体周期调用
func _on_aura_period(targets: Array, aura_c: AuraComponent) -> void: pass


## 子弹命中目标时调用
func _on_bullet_hit(target: Entity, bullet_c: BulletComponent) -> void: pass


## 子弹未命中目标时调用
func _on_bullet_miss(bullet_c: BulletComponent) -> void: pass


## 计算子弹伤害系数时调用，返回值为伤害系数
func _on_bullet_calculate_damage_factor(target: Entity, bullet_c: BulletComponent) -> float: return 1.0


## 实体被选择时调用
func _on_select() -> void: pass


func _to_string():
	return String(name)
@warning_ignore_restore("unused_parameter")
#endregion


func _ready() -> void:
	if idle_animation == null:
		idle_animation = AnimationData.new({
			"left_right": "idle_left_right",
		})
		
	scene_name = scene_file_path.get_file().get_basename()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		hit_offset, 
		3,
		Color(0.306, 0.914, 0.867, 1.0), 
		true
	)
	

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
	EditorUtils.tool_on_tree_call(self, what, _update_components)


## 将实体增加到插入队列
func insert_entity() -> void:
	S.insert_entity.emit(self)
	SystemMgr.insert_queue.append(self)


## 将实体增加到移除队列
func remove_entity() -> void:
	visible = false
	removed = true
	SystemMgr.remove_queue.append(self)
	Log.debug("移除实体: %s" % self)


#region 组件相关方法
## 获取组件
func get_c(c_name: StringName) -> Node:
	return components.get(c_name)


## 判断是否拥有指定组件
func has_c(c_name: StringName) -> bool:
	return components.has(c_name)


## 增加组件
func add_c(component: GDScript) -> Node:
	var component_node: Node = component.new()
	
	add_child(component_node)
	var node_class: String = component.get_global_name()
			
	components[node_class] = component_node
	return component_node
#endregion


#region 状态效果相关方法
## 清理无效状态效果
func cleanup_has_mods() -> void:
	var new_has_mods_ids: Array[int] = []
	
	for mod_id in has_mods_ids:
		if not EntityMgr.get_entity_by_id(mod_id):
			continue 
			
		new_has_mods_ids.append(mod_id)
		
	has_mods_ids = new_has_mods_ids


## 获取拥有的所有状态效果实体
func get_has_mods(filter: Callable = Callable()) -> Array[Entity]:
	var has_mods: Array[Entity] = []
	
	for mod_id: int in has_mods_ids:
		var mod: Entity = EntityMgr.get_entity_by_id(mod_id)
		
		if not mod or filter.is_valid() and not filter.call(mod):
			continue
		
		has_mods.append(mod)
		
	return has_mods


## 清空拥有的状态效果
func clear_has_mods() -> void:
	for mod: Entity in get_has_mods():
		mod.remove_entity()

	has_mods_ids.clear()
	
	
## 将伤害应用状态效果的 buff
func apply_mods_damage_factor(damage: float) -> float:
	var total_damage_factor: float = 1
	var total_damage_bonus: float = 0
	
	for mod: Entity in get_has_mods():
		var mod_c: ModifierComponent = mod.get_c(C.CN_MODIFIER)
		total_damage_factor *= mod_c.add_damage_factor
		total_damage_bonus += mod_c.add_damage_bonus
		
	return damage * total_damage_factor + total_damage_bonus
#endregion


#region 光环相关方法
## 获取拥有的光环实体
func get_has_auras(filter: Callable = Callable()) -> Array[Entity]:
	var has_auras: Array[Entity] = []
	
	for aura_id in has_auras_ids:
		var aura: Entity = EntityMgr.get_entity_by_id(aura_id)
		
		if not aura or filter.is_valid() and not filter.call(aura):
			continue
		
		has_auras.append(aura)
		
	return has_auras


## 清空拥有的光环
func clear_has_auras() -> void:
	for aura: Entity in get_has_auras():
		aura.remove_entity()

	has_auras_ids.clear()
#endregion


## 设定实体位置，根据拥有的组件智能赋值
func set_pos(pos: Vector2) -> void:
	global_position = pos
	
	if has_c(C.CN_RALLY):
		var rally_c: RallyComponent = get_c(C.CN_RALLY)
		
		rally_c.new_rally(pos)
	
	if has_c(C.CN_NAV_PATH):
		set_nav_path_at_pos(pos)


## 设置导航路径到当前位置下最近的导航路径
func set_nav_path_at_pos(pos: Vector2) -> void:
	var source: Entity = EntityMgr.get_entity_by_id(source_id)
	var node: PathwayNode

	if source and source.has_c(C.CN_NAV_PATH):
		var s_nav_path_c: NavPathComponent = source.get_c(C.CN_NAV_PATH)
		node = PathMgr.get_nearst_node(pos, [s_nav_path_c.pi], [s_nav_path_c.spi])
	else:
		node = PathMgr.get_nearst_node(pos)

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
	

## 使一个精灵播放动画
func play_animation(
		anim_name: String, 
		sprite_idx: int = 0, 
		filp_h: bool = false,
		force_play: bool = false
	) -> void:
	var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
	if not sprite:
		return
		
	if (
			not force_play 
			and sprite.animation == anim_name 
			and sprite.flip_h == filp_h
		):
		return
		
	if not sprite.sprite_frames.has_animation(anim_name):
		Log.error("%s 未找到动画: %s" % [self, anim_name])
		return
		
	Log.verbose("%s 播放动画: %s, 水平镜像: %s" % [self, anim_name, filp_h])
	sprite.play(anim_name)
	sprite.flip_h = filp_h
	
	
## 使一个组中的所有精灵播放对应的动画
func play_animation_group(
		anim_name: String, 
		group_idx: int = 0, 
		filp_h: bool = false,
		force_play: bool = false
	) -> void:
	var sprite_c: SpriteComponent = get_c(C.CN_SPRITE)
		
	for sprite_idx: int in sprite_c.groups[group_idx].sprite_idx_list:
		play_animation(anim_name, sprite_idx, filp_h, force_play)


## 根据是否为组调用相应 play_animation_by_look 或 play_animation_group_by_look 函数
func mixed_play_animation_by_look(
		animation: AnimationData, 
		source_animation_key: String = "",
		force_play: bool = false
	) -> Array:
	if animation.is_group:
		return play_animation_group_by_look(
			animation, source_animation_key, force_play)
	else:
		return play_animation_by_look(
			animation, source_animation_key, C.UNSET, force_play
		)


## 根据实体与看向目标点的角度播放对应的动画
func play_animation_by_look(
		animation: AnimationData, 
		source_animation_key: String = "",
		sprite_idx: int = C.UNSET,
		force_play: bool = false
	) -> Array:
	var anim_name: String = ""

	var result: Array = animation.get_animation_name_for_point(
		self, look_at_point
	)
	anim_name = result[0]
	var filp_h: bool = result[2]

	var play_idx: int = sprite_idx if U.is_valid_number(sprite_idx) else animation.play_idx

	play_animation(anim_name, play_idx, filp_h, force_play)

	var sprite_c: SpriteComponent = get_c(C.CN_SPRITE)
	if sprite_c.sync_source:
		_source_play_animation_by_look(
			source_animation_key,
			force_play
		)
	return result
	
	
func _source_play_animation_by_look(
		source_animation_key: String = "",
		force_play: bool = false
	) -> void:
	var source: Entity = EntityMgr.get_entity_by_id(source_id)
	if not source or source.is_waiting():
		return
	
	source.look_at_point = look_at_point
	var sprite_c: SpriteComponent = source.get_c(C.CN_SPRITE)
	var animation: AnimationData = sprite_c.sync_animations.get(
		source_animation_key
	)
	if not animation:
		return
		
	source.mixed_play_animation_by_look(
		animation, source_animation_key, force_play
	)

	source.mixed_wait_animation(animation)
	
	
## 根据实体与看向目标点的角度使一个组中的所有精灵播放对应的动画
func play_animation_group_by_look(
		animation: AnimationData, 
		source_animation_key: String = "",
		force_play: bool = false
	) -> Array:
	var sprite_c: SpriteComponent = get_c(C.CN_SPRITE)
	var result: Array = []
		
	for sprite_idx: int in sprite_c.groups[animation.play_idx].sprite_idx_list:
		result = play_animation_by_look(
			animation, source_animation_key, sprite_idx, force_play
		)
		
	_source_play_animation_by_look(
		source_animation_key, force_play
	)
	return result


## 播放待机导航
func play_idle_animation(force_play: bool = false) -> Array:
	return mixed_play_animation_by_look(
		idle_animation, "idle", force_play
	)


## 根据是否为组调用 wait_animation 或 wait_animation_group 函数
func mixed_wait_animation(
		animation: AnimationData
	) -> void:
	var play_idx: int = animation.play_idx
	var times: int = animation.times

	if animation.is_group:
		await wait_animation_group(play_idx, times)
	else:
		await wait_animation(play_idx, times)


## 等待动画播放完成
func wait_animation(sprite_idx: int = 0, times: int = 1) -> void:
	var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
	
	_waiting = true
	
	for i: int in range(times):
		await _wait_for_animation_loop(sprite)
	
	_waiting = false


## 等待动画组播放完成
func wait_animation_group(group_idx: int = 0, times: int = 1) -> void:
	var sprite_c: SpriteComponent = get_c(C.CN_SPRITE)
	
	_waiting = true
	
	for i: int in range(times):
		for sprite_idx: int in sprite_c.groups[group_idx].sprite_idx_list:
			var sprite: AnimatedSprite2D = get_animated_sprite(sprite_idx)
			await _wait_for_animation_loop(sprite)
	
	_waiting = false


func _wait_for_animation_loop(sprite: AnimatedSprite2D) -> void:
	var current_frame: int = sprite.frame
	var total_frames: int = sprite.sprite_frames.get_frame_count(sprite.animation)
	var frames_remaining: int = total_frames - current_frame
	
	# 是最后一帧，不等待
	if current_frame == total_frames:
		return
	
	# 等待剩余帧数
	for i: int in range(frames_remaining):
		await sprite.frame_changed
#endregion


## 协程等待
##
## break_fn 返回 true 表示中断等待
func y_wait(time: float = U.fts(1), break_fn: Callable = Callable()) -> void:
	_waiting = true
	Log.verbose("实体等待: %s, %.2fs" % [self, time])
	await TimeMgr.y_wait(time, break_fn)
	Log.verbose("实体等待完毕: %s, %.2fs" % [self, time])
	_waiting = false


func is_waiting() -> bool:
	return _waiting or blocking
