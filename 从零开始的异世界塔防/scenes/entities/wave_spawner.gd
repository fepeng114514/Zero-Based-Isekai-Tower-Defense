extends Entity
@export var wave_set: WaveSet


func _spawner() -> void:
	var wave_list: Array[Wave] = wave_set.wave_list
	
	for wave_idx: int in range(wave_list.size()):
		var wave: Wave = wave_list[wave_idx - 1]
		
		wave_idx += 1
		if wave_idx < GlobalStore.force_wave:
			continue
		
		# 每波之间的等待
		await TimeDB.y_wait(wave.interval)
		GlobalStore.current_wave = wave_idx
		GlobalStore.force_wave = wave_idx
		
		for spawn_batch: WaveSpawnBatch in wave.spawn_batch_list:
			# 批次并行
			var spawn_batch_spawner: Callable = _spawn_batch_spawner.bind()
			spawn_batch_spawner.call(spawn_batch)
			
	# 所有波次释放完毕
	GlobalStore.waves_finished = true


func _spawn_batch_spawner(spawn_batch: WaveSpawnBatch) -> void:
	await TimeDB.y_wait(spawn_batch.delay)
	var pathway_idx: int = spawn_batch.pathway_idx
	
	for spawn: WaveSpawn in spawn_batch.spawns:
		for i: int in range(spawn.count):
			var e: Entity = EntityDB.create_entity(spawn.entity_tag)
			
			if e.has_c(C.CN_NAV_PATH):
				var nav_path_c: NavPathComponent = e.get_c(C.CN_NAV_PATH)
				var spi = spawn.subpathway_idx
				
				nav_path_c.reversed = spawn.reversed
				nav_path_c.loop = spawn.loop
				
				var node: PathwayNode = nav_path_c.get_pathway_node(
					PathDB.node_count - 1 if nav_path_c.reversed else 0
				)
				nav_path_c.set_nav_path(pathway_idx, spi, node.ni)
			
			e.insert_entity()
			
			await TimeDB.y_wait(spawn.interval)
			
		await TimeDB.y_wait(spawn.next_interval)
