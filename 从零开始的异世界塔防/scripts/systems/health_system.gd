extends System
class_name HealthSystem

func on_insert(e: Entity) -> bool:
	var health_c = e.get_component(CS.CN_HEALTH)
	
	if not health_c:
		return true
		
	health_c.hp = health_c.hp_max
	
	return true

func on_update(delta) -> void:
	var damage_queue = SystemManager.damage_queue
	for i: int in range(damage_queue.size() - 1, -1, -1):
		var d: Entity = damage_queue.pop_at(i)
		var target = EntityDB.get_entity_by_id(d.target_id)
		if not is_instance_valid(target):
			continue
			
		var health_c = target.get_component(CS.CN_HEALTH)

		if not health_c:
			continue
			
		take_damage(target, d, health_c)

		
func take_damage(target: Entity, d: Entity, health_c):	
	if d.damage_type & CS.DAMAGE_EAT:
		if target.get("on_eat"):
			target.on_eat()
		
		EntityDB.remove_entity(target)
		return
	
	var actual_damage: int = predict_damage(d, health_c)
	health_c.hp -= actual_damage
		
	if target.get("on_damage"):
		target.on_damage(d.source_id)
		
	if health_c.hp <= 0:
		if target.get("on_dead"):
			target.dead()
			
		EntityDB.remove_entity(target)
		
func predict_damage(d: Entity, health_c):
	var protection: float
	var damage_type = d.damage_type
		
	if damage_type & CS.DAMAGE_DISINTEGRATE:
		return health_c.hp
	elif damage_type & CS.DAMAGE_PHYSICAL:
		protection = health_c.physical_armor
	elif damage_type & CS.DAMAGE_MAGICAL:
		protection = health_c.magical_armor
	elif damage_type & CS.DAMAGE_EXPLOSION:
		protection = health_c.physical_armor / 2
	else:
		protection = 0
		
	protection = clampf(protection, 0, 1)
	
	var actual_damage: int = d.value * (1 - protection)
	actual_damage = roundi(health_c.damage_factor * actual_damage)
	
	return actual_damage
