extends System
class_name ModifierSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_MODIFIER):
		return true

	var target = EntityDB.get_entity_by_id(e.target_id)

	if not is_instance_valid(target):
		return false

	# 检查是否被禁止
	if e.bans & target.flags or target.mod_bans & e.flags:
		return false

	var t_has_mods: Dictionary = target.has_mods
	var same_target_mods: Array = []
	var m_component = e.get_c(CS.CN_MODIFIER)

	for mod_idx in t_has_mods:
		var other_m: Entity = t_has_mods[mod_idx]
		same_target_mods.append(other_m)

		# 检查是否被其他效果禁止
		if other_m.mod_bans & e.flags or other_m.mod_type_bans & m_component.mod_type:
			return false

		# 处理相同效果
		if other_m.template_name == e.template_name:
			# 重置时间戳
			if m_component.reset_same:
				other_m.ts = TM.tick_ts
				return false
			# 替换
			elif m_component.replace_same:
				EntityDB.remove_entity(other_m)
			# 叠加
			elif not m_component.allow_same:
				return false

	t_has_mods[e.id] = e
	return true

func on_remove(e: Entity) -> bool:
	if not e.has_c(CS.CN_MODIFIER):
		return true
	
	var target = EntityDB.get_entity_by_id(e.target_id)

	if not is_instance_valid(target):
		return true

	target.has_mods.erase(e.id)
	
	return true
