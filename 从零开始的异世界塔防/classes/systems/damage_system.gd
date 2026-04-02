extends System
class_name DamageSystem
## 伤害系统
##
## 处理伤害队列的伤害造成


func _on_update(_delta: float) -> void:
	var damage_queue: Array[Entity] = SystemMgr.damage_queue
	while damage_queue:
		var damage: Damage = damage_queue.pop_front()
		var target: Entity = EntityMgr.get_entity_by_id(damage.target_id)
		if not target:
			continue

		var health_c: HealthComponent = target.get_c(C.CN_HEALTH)
		if not health_c:
			continue
			
		var source: Entity = EntityMgr.get_entity_by_id(damage.source_id)
			
		if damage.damage_type & C.DamageType.EAT:
			target._on_eat(target, damage)
			if source:
				source._on_kill(target, damage)
			target.remove_entity()
			return
		
		var actual_damage: float = _predict_damage(
			target, health_c, damage, source
		)
		health_c.hp -= actual_damage
		target._on_damage(target, damage)
		
		Log.verbose(
			"造成伤害: 目标: %s，来源: %s，值: %s"
			% [
				target,
				source if source else null,
				actual_damage
			]
		)
		
		if health_c.hp <= 0:
			_on_death(target, health_c, damage, source)
		

func _predict_damage(
		target: Entity, 
		health_c: HealthComponent, 
		damage: Damage, 
		source: Entity
	) -> float:
	var damage_factor: float = damage.damage_factor
	var vulnerable: float = 1 - health_c.vulnerable
	var resistance: float = 1 - health_c.damage_resistance
	var reduction: float = health_c.damage_reduction
	
	var damage_bonus: float = 0
	var physical_armor_factor: float = 1
	var magical_armor_factor: float = 1
	var physical_armor_bonus: int = 0
	var magical_armor_bonus: int = 0
	var vulnerable_factor: float = 1
	var vulnerable_bonus: float = 0
	
	# 汇总状态效果的影响
	# 所有者
	if source:
		for mod: Entity in source.get_has_mods():
			var mod_c: ModifierComponent = mod.get_c(C.CN_MODIFIER)
			damage_factor *= mod_c.add_damage_factor
			damage_bonus += mod_c.add_damage_bonus
			
			resistance *= mod_c.damage_resistance_factor
			reduction += mod_c.damage_reduction_bonus
			physical_armor_factor *= mod_c.physical_armor_factor
			magical_armor_factor *= mod_c.magical_armor_factor
			physical_armor_bonus += mod_c.physical_armor_bonus
			magical_armor_bonus += mod_c.magical_armor_bonus
		
	# 目标
	for mod: Entity in target.get_has_mods():
		var mod_c: ModifierComponent = mod.get_c(C.CN_MODIFIER)
		vulnerable *= mod_c.vulnerable_factor
		vulnerable += mod_c.vulnerable_bonus
	
	# 计算护甲减伤
	var damage_type: int = damage.damage_type
		
	if damage_type & C.DamageType.DISINTEGRATE:
		return health_c.hp
		
	var physical_armor: float = clampf(
		U.to_percent(
			health_c.physical_armor 
			* physical_armor_factor 
			+ physical_armor_bonus
		), 
		0,
		1
	)
	var magical_armor: float = clampf(
		U.to_percent(
			health_c.magical_armor
			* magical_armor_factor
			+ magical_armor_bonus
		),
		0,
		1
	)
	var poison_armor: float = clampf(
		U.to_percent(health_c.poison_armor),
		0,
		1
	)
	
	if damage_type & C.DamageType.TRUE:
		physical_armor = 0
		magical_armor = 0

	if damage_type & C.DamageType.EXPLOSION:
		resistance *= 1 - physical_armor / 2.0
	elif damage_type & C.DamageType.PHYSICAL:
		resistance *= 1 - physical_armor
		
	if damage_type & C.DamageType.MAGICAL_EXPLOSION:
		resistance *= 1 - magical_armor / 2.0
	elif damage_type & C.DamageType.MAGICAL:
		resistance *= 1 - magical_armor
		
	if damage_type & C.DamageType.POISON:
		resistance *= 1 - poison_armor
	
	# 计算伤害
	var total_damage_factor: float = damage_factor * resistance * vulnerable
	var basic_value: float = damage.value - reduction + damage_bonus
	var actual_damage: float = roundi(basic_value * total_damage_factor)
	
	return actual_damage


func _on_death(
		target: Entity, 
		health_c: HealthComponent, 
		damage: Damage, 
		source: Entity
	) -> void:
	target._on_death(target, damage)
	if source:
		source._on_kill(target, damage)
		
	health_c.health_bar.visible = false
	GameMgr.cash += health_c.death_gold
	
	var death_animation: AnimationData = health_c.death_animation
	if death_animation:
		target.mixed_play_animation_by_look(
			death_animation, "death"
		)
		
	var death_sfx: AudioData = health_c.death_sfx
	if death_sfx:
		AudioMgr.play_sfx(death_sfx)
	
	await target.mixed_wait_animation(death_animation)

	target.remove_entity()
