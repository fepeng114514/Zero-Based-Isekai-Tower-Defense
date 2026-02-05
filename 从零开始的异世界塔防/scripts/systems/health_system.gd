extends System
class_name HealthSystem

func on_create(e: Entity) -> bool:
	if not e.has_c(CS.CN_HEALTH):
		return true

	var health_c: HealthComponent = e.get_c(CS.CN_HEALTH)
		
	var health_bar = preload(CS.PATH_SCENES + "/health_bar.tscn").instantiate()
	health_bar.scale = health_c.health_bar_scale
	health_bar.position = health_c.health_bar_offset
	e.add_child(health_bar)
	e.set_c(CS.CN_HEALTH_BAR, health_bar)
	
	return true

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_HEALTH):
		return true
		
	var health_c = e.get_c(CS.CN_HEALTH)

	health_c.hp = health_c.hp_max
	
	return true

func on_update(delta) -> void:
	var damage_queue = SystemManager.damage_queue
	for i: int in range(damage_queue.size() - 1, -1, -1):
		var d: Entity = damage_queue.pop_at(i)
		var target = EntityDB.get_entity_by_id(d.target_id)
		
		if not is_instance_valid(target):
			continue
			
		var health_c = target.get_c(CS.CN_HEALTH)

		if not health_c:
			continue
			
		take_damage(target, d, health_c)

	for e in EntityDB.get_entities_by_group(CS.CN_HEALTH):
		var health_c = e.get_c(CS.CN_HEALTH)
		var health_bar = e.get_c(CS.CN_HEALTH_BAR)
		health_bar.fg.scale.x = health_bar.origin_fg_scale.x * health_c.get_hp_percent()
	
func take_damage(target: Entity, d: Entity, health_c: HealthComponent):
	if d.damage_type & CS.DAMAGE_EAT:
		target.on_eat(health_c, d)
		
		EntityDB.remove_entity(target)
		return
	
	var actual_damage: int = predict_damage(d, health_c)
	health_c.hp -= actual_damage
	
	target.on_damage(health_c, d)
	
	print("造成伤害: 目标: %s，来源: %s，值: %s" % [d.target_id, d.source_id, actual_damage])
		
	if health_c.hp <= 0:
		target.on_dead(health_c, d)
			
		EntityDB.remove_entity(target)
		
func predict_damage(d: Entity, health_c: HealthComponent):
	var protection: float = health_c.damage_reduction
	var damage_type = d.damage_type
		
	if damage_type & CS.DAMAGE_DISINTEGRATE:
		return health_c.hp
		
	if damage_type & CS.DAMAGE_PHYSICAL:
		protection *= health_c.physical_armor
	if damage_type & CS.DAMAGE_MAGICAL:
		protection *= health_c.magical_armor
	if damage_type & CS.DAMAGE_EXPLOSION:
		protection *= health_c.physical_armor / 2.0
	if damage_type & CS.DAMAGE_MAGICAL_EXPLOSION:
		protection *= health_c.magical_armor / 2.0
	
	var actual_damage: int = roundi(d.value * (1 - protection) * d.damage_factor)
	
	return actual_damage
