@tool
extends Entity


signal all_spawn_group_done


enum SPAWN_GROUP_FLAGS {
	SPAWNING,
	DONE,
}


@export var wave_group: WaveGroup = null
@export var wave_interval_start_sfx: AudioData = null
@export var wave_interval_finish_sfx: AudioData = null
@export var release_wave_delay: float = 1.0


func _spawner() -> void:
	AudioMgr.play_sfx(wave_interval_start_sfx)
	await WaveMgr.first_release_wave
	
	var wave_list: Array[Wave] = wave_group.wave_list
	
	for wave_idx: int in range(WaveMgr.current_wave_idx, wave_list.size()):
		var wave: Wave = wave_list[wave_idx]
		var wave_interval: float = wave.interval
		WaveMgr.current_wave_idx = wave_idx
		WaveMgr.start_wave_timer.emit(wave)
		
		if not WaveMgr.is_first_release_wave:
			AudioMgr.play_sfx(wave_interval_start_sfx)
		
		Log.debug("开始第 %d 波计时：%.2f" % [wave_idx + 1, wave_interval])
		await y_wait(wave_interval, func(): 
			return WaveMgr.is_release_wave
		)
		
		AudioMgr.play_sfx(wave_interval_finish_sfx)
		
		await y_wait(release_wave_delay)
		WaveMgr.is_release_wave = false
		Log.debug(">>> 开始第 %d 波出怪" % (wave_idx + 1))
		
		var spawn_group_list: Array[WaveSpawnGroup] = wave.spawn_group_list
		var spawn_group_list_size: int = spawn_group_list.size()
		var spawn_group_states := PackedInt32Array()
		spawn_group_states.resize(spawn_group_list_size)
		spawn_group_states.fill(SPAWN_GROUP_FLAGS.SPAWNING)
		
		for i: int in spawn_group_list_size:
			var spawn_group: WaveSpawnGroup = spawn_group_list[i]
			_spawn_group_spawner(i, spawn_group, spawn_group_states)
			
		await all_spawn_group_done
			
	Log.debug("=====所有波次释放完毕=====")
	WaveMgr.waves_finished = true


func _spawn_group_spawner(
		idx: int,
		spawn_group: WaveSpawnGroup, 
		spawn_group_states: PackedInt32Array
	) -> void:
	await y_wait(spawn_group.delay)
	var pathway_idx: int = spawn_group.pathway_idx
	
	for spawn: WaveSpawn in spawn_group.spawn_list:
		for i: int in spawn.count:
			var e: Entity = EntityMgr.create_entity(spawn.entity)
			
			var nav_path_c: NavPathComponent = e.get_node_or_null(C.CN_NAV_PATH)
			if nav_path_c:
				var spi: int = spawn.subpathway_idx
				
				nav_path_c.reversed = spawn.reversed
				nav_path_c.loop = spawn.loop
				
				var node: PathwayNode = nav_path_c.get_pathway_node(
					PathwayMgr.node_count - 1 if nav_path_c.reversed else 0
				)
				nav_path_c.set_nav_path(pathway_idx, spi, node.ni)
			
			e.insert_entity()
			
			await y_wait(spawn.interval)
			
		await y_wait(spawn.next_interval)
	
	spawn_group_states[idx] = SPAWN_GROUP_FLAGS.DONE
	for flag: int in spawn_group_states:
		if not flag & SPAWN_GROUP_FLAGS.DONE:
			break
			
		all_spawn_group_done.emit()
