extends System
"""血量系统:
	管理伤害造成与血条更新拦截
"""


func _on_ready_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_HEALTH):
		return true

	var health_c: HealthComponent = e.get_c(C.CN_HEALTH)
		
	var health_bar = preload(C.PATH_SCENES + "/health_bar.tscn").instantiate()
	health_bar.scale = health_c.health_bar_scale
	health_bar.position = health_c.health_bar_offset
	e.add_child(health_bar)
	e.set_c(C.CN_HEALTH_BAR, health_bar)
	
	return true


func _on_insert(e: Entity) -> bool:
	if not e.has_c(C.CN_HEALTH):
		return true
		
	var health_c = e.get_c(C.CN_HEALTH)

	health_c.hp = health_c.hp_max
	
	return true


func _on_update(delta) -> void:
	_process_damege_queue()

	process_entities(C.CN_HEALTH, func(e: Entity):
		var health_c: HealthComponent = e.get_c(C.CN_HEALTH)
		var health_bar: Node = e.get_c(C.CN_HEALTH_BAR)
		health_bar.fg.scale.x = (
			health_bar.origin_fg_scale.x * health_c.get_hp_percent()
		)
	)
		
func _process_damege_queue() -> void:
	var damage_queue = SystemMgr.damage_queue
	for i: int in range(damage_queue.size() - 1, -1, -1):
		var d: Damage = damage_queue.pop_at(i)
		var target = EntityDB.get_entity_by_id(d.target_id)
		
		if not U.is_vaild_entity(target):
			continue
			
		var t_health_c = target.get_c(C.CN_HEALTH)

		if not t_health_c:
			continue
			
		_take_damage(target, d, t_health_c)

func _take_damage(target: Entity, d: Damage, t_health_c: HealthComponent):
	var source: Entity = EntityDB.get_entity_by_id(d.source_id)
	
	if d.damage_type & C.DAMAGE_EAT:
		target._on_eat(target, d)
		source._on_kill(target, d)
		target.remove_entity()
		return
	
	var actual_damage: int = _predict_damage(target, d, t_health_c, source)
	t_health_c.hp -= actual_damage
	
	target._on_damage(target, d)
	
	print_verbose(
		"造成伤害: 目标: %s(%s)，来源: %s(%s)，值: %s"
		% [
			target.template_name, 
			d.target_id, 
			source.template_name if source else "unknow", 
			d.source_id, 
			actual_damage
		]
	)
		
	if t_health_c.hp <= 0:
		target._on_dead(target, d)
		if source:
			source._on_kill(target, d)
		target.remove_entity()
		

func _predict_damage(
		target: Entity, d: Damage, t_health_c: HealthComponent, source: Entity
	) -> int:
	var damage_factor: float = d.damage_factor
	var vulnerable: float = 1 - t_health_c.vulnerable
	var resistance: float = 1 - t_health_c.damage_resistance
	var reduction: int = t_health_c.damage_reduction
	
	var damage_inc: int = 0
	var physical_armor_factor: float = 1
	var magical_armor_factor: float = 1
	var physical_armor_inc: int = 0
	var magical_armor_inc: int = 0
	var vulnerable_factor: float = 1
	var vulnerable_inc: float = 0
	
	# 汇总状态效果的影响
	# 所有者
	if source:
		for mod: Entity in source.get_has_mods():
			var mod_c: ModifierComponent = mod.get_c(C.CN_MODIFIER)
			damage_factor *= mod_c.add_damage_factor
			damage_inc += mod_c.add_damage_inc
			resistance *= mod_c.damage_resistance_factor
			reduction += mod_c.damage_reduction_inc
			physical_armor_factor *= mod_c.physical_armor_factor
			magical_armor_factor *= mod_c.magical_armor_factor
			physical_armor_inc += mod_c.physical_armor_inc
			magical_armor_inc += mod_c.magical_armor_inc
		
	# 目标
	for mod: Entity in target.get_has_mods():
		var mod_c: ModifierComponent = mod.get_c(C.CN_MODIFIER)
		vulnerable *= mod_c.vulnerable_factor
		vulnerable += mod_c.vulnerable_inc
	
	# 计算护甲减伤
	var damage_type = d.damage_type
		
	if damage_type & C.DAMAGE_DISINTEGRATE:
		return t_health_c.hp
		
	var physical_armor: float = clampf(
		U.to_percent(
			t_health_c.physical_armor 
			* physical_armor_factor 
			+ physical_armor_inc
		), 
		0,
		1
	)
	var magical_armor: float = clampf(
		U.to_percent(
			t_health_c.magical_armor
			* magical_armor_factor
			+ magical_armor_inc
		),
		0,
		1
	)
	var poison_armor: float = clampf(
		U.to_percent(t_health_c.poison_armor),
		0,
		1
	)
	
	if damage_type & C.DAMAGE_TRUE:
		physical_armor = 0
		magical_armor = 0

	if damage_type & C.DAMAGE_EXPLOSION:
		resistance *= 1 - physical_armor / 2.0
	elif damage_type & C.DAMAGE_PHYSICAL:
		resistance *= 1 - physical_armor
		
	if damage_type & C.DAMAGE_MAGICAL_EXPLOSION:
		resistance *= 1 - magical_armor / 2.0
	elif damage_type & C.DAMAGE_MAGICAL:
		resistance *= 1 - magical_armor
		
	if damage_type & C.DAMAGE_POISON:
		resistance *= 1 - poison_armor
	
	# 计算伤害
	var total_damage_factor: float = damage_factor * resistance * vulnerable
	var basic_value: int = d.value - reduction + damage_inc
	var actual_damage: int = roundi(basic_value * total_damage_factor)
	
	return actual_damage
