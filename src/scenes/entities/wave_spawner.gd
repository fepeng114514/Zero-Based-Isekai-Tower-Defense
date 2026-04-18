@tool
extends Entity


@export var wave_set: WaveSet = null


func _spawner() -> void:
	var wave_list: Array[Wave] = wave_set.wave_list
	
	for wave_idx: int in wave_list.size():
		var wave: Wave = wave_list[wave_idx]
		wave_idx += 1
		
		S.start_wave_timer.emit(wave)
		
		# 每波之间的等待
		await y_wait(wave.interval, func(): 
			return wave_idx < GameMgr.force_wave
		)
		
		if wave_idx < GameMgr.force_wave:
			continue
		
		GameMgr.current_wave = wave_idx
		
		for spawn_batch: WaveSpawnBatch in wave.spawn_batch_list:
			# 批次并行
			_spawn_batch_spawner(spawn_batch)
			
	# 所有波次释放完毕
	GameMgr.waves_finished = true


func _spawn_batch_spawner(spawn_batch: WaveSpawnBatch) -> void:
	await y_wait(spawn_batch.delay)
	var pathway_idx: int = spawn_batch.pathway_idx
	
	for spawn: WaveSpawn in spawn_batch.spawns:
		for i: int in spawn.count:
			var e: Entity = EntityMgr.create_entity(spawn.entity)
			
			var nav_path_c: NavPathComponent = e.get_child_node(C.CN_NAV_PATH)
			if nav_path_c:
				var spi = spawn.subpathway_idx
				
				nav_path_c.reversed = spawn.reversed
				nav_path_c.loop = spawn.loop
				
				var node: PathwayNode = nav_path_c.get_pathway_node(
					PathwayMgr.node_count - 1 if nav_path_c.reversed else 0
				)
				nav_path_c.set_nav_path(pathway_idx, spi, node.ni)
			
			e.insert_entity()
			
			await y_wait(spawn.interval)
			
		await y_wait(spawn.next_interval)
