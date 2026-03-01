extends System


func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_MODIFIER):
		return true

	var target: Entity = EntityDB.get_entity_by_id(e.target_id)

	if not target:
		return false
		
	e.position = target.position
		
	# 检查黑白名单
	if not U.is_allowed_entity(e, target):
		return false

	# 检查是否被目标禁止
	if (
			e.ban_bits & target.flag_bits
			or e.flag_bits & target.mod_ban_bits
	):
		return false
		
	var t_has_mods_ids: Array[int] = target.has_mods_ids
	var same_target_mods: Array[Entity] = []
	var mod_c: ModifierComponent = e.get_c(C.CN_MODIFIER)

	mod_c.ts = TimeDB.tick_ts

	for mod_id: int in t_has_mods_ids:
		var other_m: Entity = EntityDB.get_entity_by_id(mod_id)
		
		if not other_m:
			continue
		
		var other_mod_c: ModifierComponent = other_m.get_c(C.CN_MODIFIER)
		
		# 检查是否被其他效果禁止
		if (
				other_m.mod_ban_bits & e.flag_bits
				or other_m.mod_type_ban_bits & mod_c.mod_type_bits
		):
			return false
			
		# 检查是否被当前效果禁止
		if (
				e.mod_ban_bits & other_m.flag_bits
				or e.mod_type_ban_bits & other_mod_c.mod_type_bits
		):
			if mod_c.remove_banned:
				other_m.remove_entity()
				continue
			
			return false
		
		if other_m.tag == e.tag:
			same_target_mods.append(other_m)
			
	if not same_target_mods:
		t_has_mods_ids.append(e.id)
		return true
		
	# 处理相同效果
	# 按照等级降序排序
	same_target_mods.sort_custom(
		func(m1: Entity, m2: Entity) -> bool: return m1.level > m2.level
	)
	var min_level_mod: Entity = same_target_mods[-1]
	var max_level_mod: Entity = same_target_mods[0]
		
	# 重置持续时间，优先重置等级最高的
	if mod_c.reset_same:
		max_level_mod.insert_ts -= TimeDB.tick_ts
		return false
	# 替换，优先替换等级最低的
	if mod_c.replace_same:
		min_level_mod.remove_entity()
		t_has_mods_ids.append(e.id)
		return true
	# 叠加持续时间，优先与最高等级叠加
	if mod_c.overlay_duration_same:
		max_level_mod.insert_ts -= e.duration
		return false
	# 叠加
	if not mod_c.allow_same:
		return false

	t_has_mods_ids.append(e.id)
	return true


func _on_update(_delta: float) -> void:
	for e: Entity in EntityDB.get_entities_group(C.GROUP_MODIFIERS):
		var mod_c: ModifierComponent = e.get_c(C.CN_MODIFIER)
		
		# 周期效果
		if (
			not U.is_valid_number(mod_c.cycle_time) 
			or not TimeDB.is_ready_time(mod_c.ts, mod_c.cycle_time)
		):
			return

		# 最大周期数
		if U.is_valid_number(mod_c.max_cycle) and mod_c.curren_cycle > mod_c.max_cycle:
			e.remove_entity()
			return

		var target: Entity = EntityDB.get_entity_by_id(e.target_id)
		
		if mod_c.min_damage > 0 or mod_c.max_damage > 0:
			EntityDB.create_damage(e.target_id, mod_c.min_damage, mod_c.max_damage, mod_c.damage_type, e.id)

		e._on_modifier_period(target, mod_c)

		mod_c.curren_cycle += 1
		mod_c.ts = TimeDB.tick_ts
	

func _on_remove(e: Entity) -> void:
	if not e.has_c(C.CN_MODIFIER):
		return
	
	var target: Entity = EntityDB.get_entity_by_id(e.target_id)

	if not target:
		return

	target.has_mods_ids.erase(e.id)
