extends System
class_name AuraSystem
## 光环系统
##
## 处理拥有 [AuraComponent] 光环组件的实体


func _on_insert(e: Entity) -> bool:
	var aura_c: AuraComponent = e.get_c(C.CN_AURA)
	if not aura_c:
		return true
		
	var source: Entity = EntityMgr.get_entity_by_id(e.source_id)

	if not source:
		return false

	e.global_position = source.global_position

	# 检查黑白名单
	if not U.is_allowed_entity(e, source):
		return false

	# 检查是否被目标禁止
	if (
			e.ban_bits & source.flag_bits
			or e.flag_bits & source.aura_ban_bits
	):
		return false

	aura_c.ts = TimeMgr.tick_ts

	var s_has_auras_ids: Array[int] = source.has_auras_ids
	var same_source_auras: Array[Entity] = []

	for aura_id: int in s_has_auras_ids:
		var other_a: Entity = EntityMgr.get_entity_by_id(aura_id)
		
		if not other_a:
			continue
		
		var other_aura_c: AuraComponent = other_a.get_c(C.CN_AURA)
		
		# 检查是否被其他光环禁止
		if (
				other_a.aura_ban_bits & e.flag_bits
				or other_a.aura_type_ban_bits & aura_c.aura_type_bits
		):
			return false
			
		# 检查是否被当前光环禁止
		if (
				e.aura_ban_bits & other_a.flag_bits
				or e.aura_type_ban_bits & other_aura_c.aura_type_bits
		):
			if aura_c.remove_banned:
				other_a.remove_entity()
				continue
			
			return false
		
		if other_a.scene_name == e.scene_name:
			same_source_auras.append(other_a)
			
	if not same_source_auras:
		source.has_auras_ids.append(e.id)
		return true
		
	# 处理相同光环
	# 按照等级降序排序
	same_source_auras.sort_custom(
		func(a1: Entity, a2: Entity) -> bool: return a1.level > a2.level
	)
	var min_level_aura: Entity = same_source_auras[-1]
	var max_level_aura: Entity = same_source_auras[0]
		
	# 重置持续时间，优先重置等级最高的
	if aura_c.reset_same:
		max_level_aura.insert_ts -= TimeMgr.tick_ts
		return false
	# 替换，优先替换等级最低的
	if aura_c.replace_same:
		min_level_aura.remove_entity()
		source.has_auras_ids.append(e.id)
		return true
	# 叠加持续时间，优先与最高等级叠加
	if aura_c.overlay_duration_same:
		max_level_aura.insert_ts -= e.duration
		return false
	# 叠加
	if not aura_c.allow_same:
		return false

	s_has_auras_ids.append(e.id)

	return true


func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_entities_group(C.GROUP_AURAS):
		var aura_c: AuraComponent = e.get_c(C.CN_AURA)
		var targets: Array = EntityMgr.search_targets_in_range(
			aura_c.search_mode, 
			e.global_position, 
			aura_c.max_radius, 
			aura_c.min_radius, 
			e.flag_bits, 
			e.ban_bits
		)
		if U.is_valid_number(aura_c.max_influence):
			targets.resize(aura_c.max_influence)

		# 周期效果
		if (
			not U.is_valid_number(aura_c.cycle_time) 
			or not TimeMgr.is_ready_time(aura_c.ts, aura_c.cycle_time)
		):
			return

		# 最大周期数
		if U.is_valid_number(aura_c.max_cycle) and aura_c.curren_cycle > aura_c.max_cycle:
			e.remove_entity()
			return

		for target: Entity in targets:
			if aura_c.damage_min > 0 or aura_c.damage_max > 0:
				var d := Damage.new()
				d.target_id = target.id
				d.source_id = e.id
				d.value = d.get_random_value(aura_c.damage_min, aura_c.damage_max)
				d.damage_type = aura_c.damage_type
				d.damage_flags = aura_c.damage_flag_bits
				d.insert_damage()


			EntityMgr.create_mods(target.id, aura_c.mods, e.id)

		e._on_aura_period(targets, aura_c)

		aura_c.curren_cycle += 1
		aura_c.ts = TimeMgr.tick_ts


func _on_remove(e: Entity) -> bool:
	if not e.has_c(C.CN_AURA):
		return true
	
	var source: Entity = EntityMgr.get_entity_by_id(e.source_id)

	if not source:
		return true
	
	source.has_auras_ids.erase(e.id) 
	return true
