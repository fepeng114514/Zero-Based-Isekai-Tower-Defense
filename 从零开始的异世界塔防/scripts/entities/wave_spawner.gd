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
		
		for group: Dictionary in wave.groups:
			# 出怪组并行
			var group_spawner: Callable = _group_spawner.bind()
			group_spawner.call(group)
			
	# 所有波次释放完毕
	GlobalStore.waves_finished = true

func _group_spawner(group: Dictionary) -> void:
	await TM.y_wait(group.delay)
	var path: int = group.path
	
	for spawn: Dictionary in group.spawns:
		for i: int in range(spawn.count):
			var e: Entity = E.create_entity(spawn.name)
			
			if e.has_c(CS.CN_NAV_PATH):
				var nav_path_c: NavPathComponent = e.get_c(CS.CN_NAV_PATH)
				var spi = spawn.get("subpath")
				
				nav_path_c.reversed = true if spawn.get("reversed") else false
				nav_path_c.loop = true if spawn.get("loop") else false
				
				var loop_times = spawn.get("loop_times")
				
				if loop_times != null:
					nav_path_c.loop_times = loop_times
				var node: PathNode = nav_path_c.get_path_node(
					PathDB.node_count - 1 if nav_path_c.reversed else 0
				)
				nav_path_c.set_nav_path(
					path - 1, spi - 1 if spi != null else -1
				)
				nav_path_c.set_nav_ni(node.ni)
			
			e.insert_entity()
			
			await TM.y_wait(spawn.interval)
			
		await TM.y_wait(spawn.next_interval)
