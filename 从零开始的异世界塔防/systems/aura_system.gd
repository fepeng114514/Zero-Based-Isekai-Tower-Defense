extends System


func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_AURA):
		return true

	var aura_c: AuraComponent = e.get_c(C.CN_AURA)
	var source: Entity = EntityDB.get_entity_by_id(e.source_id)

	if not U.is_vaild_entity(source):
		return false

	e.position = source.position

	# 检查黑白名单
	if not U.is_allowed_entity(e, source):
		return false

	# 检查是否被目标禁止
	if (
			e.ban_set.has_flags(source.flag_set.bits)
			or e.flag_set.has_flags(source.aura_ban_set.bits)
	):
		return false

	aura_c.ts = TimeDB.tick_ts

	var s_has_auras_ids: Array[int] = source.has_auras_ids
	var same_source_auras: Array[Entity] = []

	for aura_id: int in s_has_auras_ids:
		var other_a: Variant = EntityDB.get_entity_by_id(aura_id)
		
		if not other_a:
			continue
		
		var other_aura_c: AuraComponent = other_a.get_c(C.CN_AURA)
		
		# 检查是否被其他光环禁止
		if (
				other_a.aura_ban_set.has_flags(e.flag_set.bits) 
				or other_a.aura_type_ban_set.has_flags(aura_c.aura_type_set.bits)
		):
			return false
			
		# 检查是否被当前光环禁止
		if (
				e.aura_ban_set.has_flags(other_a.flag_set.bits)
				or e.aura_type_ban_set.has_flags(other_aura_c.aura_type_set.bits)
		):
			if aura_c.remove_banned:
				other_a.remove_entity()
				continue
			
			return false
		
		if other_a.tag == e.tag:
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
		max_level_aura.insert_ts -= TimeDB.tick_ts
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


func _on_update(delta: float) -> void:
	process_entities(C.GROUP_AURAS, func(e: Entity) -> void:
		var aura_c: AuraComponent = e.get_c(C.CN_AURA)
		var targets: Array = EntityDB.search_targets_in_range(
			aura_c.search_mode, 
			e.position, 
			aura_c.max_radius, 
			aura_c.min_radius, 
			e.flag_set.bits, 
			e.ban_set.bits
		)

		# 周期效果
		if aura_c.cycle_time == -1 or not TimeDB.is_ready_time(aura_c.ts, aura_c.cycle_time):
			return

		# 最大周期数
		if aura_c.max_cycle != -1 and aura_c.curren_cycle > aura_c.max_cycle:
			e.remove_entity()
			return

		for target: Entity in targets:
			if aura_c.min_damage > 0 or aura_c.max_damage > 0:
				EntityDB.create_damage(target.id, aura_c.min_damage, aura_c.max_damage, aura_c.damage_type, e.id)

			EntityDB.create_mods(target.id, aura_c.mods, e.id)

		e._on_aura_period(targets, aura_c)

		aura_c.curren_cycle += 1
		aura_c.ts = TimeDB.tick_ts
	)


func _on_remove(e: Entity) -> void:
	if not e.has_c(C.CN_AURA):
		return
	
	var source = EntityDB.get_entity_by_id(e.source_id)

	if not U.is_vaild_entity(source):
		return
	
	source.has_auras_ids.erase(e.id) 
