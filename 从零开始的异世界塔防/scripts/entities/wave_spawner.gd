extends Entity
var waves_data: Array = LevelManager.waves_data[GlobalStore.level_idx]

func _spawner() -> void:
	for wave_idx: int in range(waves_data.size()):
		var wave: Dictionary = waves_data[wave_idx - 1]
		
		wave_idx += 1
		if wave_idx < GlobalStore.force_wave:
			continue
		
		# 每波之间的等待
		await TM.y_wait(wave.interval)
		GlobalStore.current_wave = wave_idx
		GlobalStore.force_wave = wave_idx
		
		for group in wave.groups:
			# 出怪组并行
			var group_spawner: Callable = _group_spawner.bind()
			group_spawner.call(group)

func _group_spawner(group: Dictionary) -> void:
	await TM.y_wait(group.delay)
	var path: int = group.path
	
	for spawn in group.spawns:
		for i in range(spawn.count):
			var e: Entity = EntityDB.create_entity(spawn.name)
			var nav_path_c = e.get_c(CS.CN_NAV_PATH)
			var subpath = spawn.get("subpath")
			nav_path_c.nav_path = path - 1
			nav_path_c.nav_subpath = subpath - 1 if subpath != null else -1
			EntityDB.insert_entity(e)
			
			await TM.y_wait(spawn.interval)
			
		await TM.y_wait(spawn.next_interval)
	
