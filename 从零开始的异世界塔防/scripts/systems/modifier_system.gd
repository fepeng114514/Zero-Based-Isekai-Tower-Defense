extends System

func _on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_MODIFIER):
		return true

	var target = EntityDB.get_entity_by_id(e.target_id)

	if not target:
		return false

	# 检查是否被目标禁止
	if e.bans & target.flags or e.flags & target.mod_bans:
		return false

	var t_has_mods_ids: Array[int] = target.has_mods_ids
	var same_target_mods: Array[Entity] = []
	var mod_c: ModifierComponent = e.get_c(CS.CN_MODIFIER)

	mod_c.ts = TM.tick_ts

	for mod_id: int in t_has_mods_ids:
		var other_m: Entity = EntityDB.get_entity_by_id(mod_id)
		var other_mod_c: ModifierComponent = other_m.get_c(CS.CN_MODIFIER)
		
		# 检查是否被其他效果禁止
		if other_m.mod_bans & e.flags or other_m.mod_type_bans & mod_c.mod_type:
			return false
			
		# 检查是否被当前效果禁止
		if e.mod_bans & other_m.flags or e.mod_type_bans & other_mod_c.mod_type:
			other_m.remove_entity()
			continue
		
		if other_m.template_name == e.template_name:
			same_target_mods.append(other_m)
			
	if not same_target_mods:
		t_has_mods_ids.append(e.id)
		return true
		
	# 处理相同效果
	# 按照等级降序排序
	same_target_mods.sort_custom(
		func(m1: Entity, m2: Entity): return m1.level > m2.level
	)
	var min_level_mod: Entity = same_target_mods[-1]
	var max_level_mod: Entity = same_target_mods[0]
		
	# 重置持续时间，优先重置等级最高的
	if mod_c.reset_same:
		max_level_mod.insert_ts = TM.tick_ts
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

func _on_update(delta: float) -> void:
	for e: Entity in EntityDB.get_entities_by_group(CS.CN_MODIFIER):
		var mod_c: ModifierComponent = e.get_c(CS.CN_MODIFIER)
		
		# 周期效果
		if mod_c.period_interval == -1 or not TM.is_ready_time(mod_c.ts, mod_c.period_interval):
			continue

		var target: Entity = EntityDB.get_entity_by_id(e.target_id)

		e._on_modifier_period(target, mod_c)

		mod_c.ts = TM.tick_ts

func _on_remove(e: Entity) -> void:
	if not e.has_c(CS.CN_MODIFIER):
		return
	
	var target = EntityDB.get_entity_by_id(e.target_id)

	if not target:
		return

	target.has_mods_ids.erase(e.id)
