extends System
class_name HealthSystem

func on_insert(entity: Entity) -> bool:
	if not Utils.is_has_c(entity, CS.CN_HEALTH):
		return true
		
	var health_c = entity.components[CS.CN_HEALTH]
	health_c.hp = health_c.hp_max
	
	return true

func on_update(delta) -> void:
	var damage_queue = EntityDB.damage_queue
	for i: int in range(damage_queue.size() - 1, -1, -1):
		var d: Entity = damage_queue.pop_at(i)
		var target = EntityDB.get_entity_by_id(d.target_id)
		
		if not is_instance_valid(target) or not Utils.is_has_c(target, CS.CN_HEALTH):
			continue
			
		take_damage(target, d)

		
func take_damage(target: Entity, d: Entity):
	var health_c = target.components[CS.CN_HEALTH]
	
	if d.damage_type & CS.DAMAGE_EAT:
		if target.get("on_eat"):
			target.on_eat()
		
		EntityDB.remove_entity(target)
		return
	
	var actual_damage: int = predict_damage(d, health_c)
	health_c.hp -= d.actual_damage
		
	if target.get("on_damage"):
		target.on_damage(d.source_id)
		
	if health_c.hp <= 0 and target.get("on_dead") and target.dead():
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
