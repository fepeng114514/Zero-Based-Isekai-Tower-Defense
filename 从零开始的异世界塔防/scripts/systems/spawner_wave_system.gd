extends Node
class_name SpawnerWave

func _ready() -> void:
	for wave: Dictionary in LevelManager.waves_data[GlobalStore.level_idx]:
		# 每波之间的等待
		await TM.create_once_timer(wave.interval)
		
		for group in wave.groups:
			# 出怪组并行
			var spawner: Callable = Callable(self, "_spawner").bind()
			spawner.call(group)

func _spawner(group: Dictionary) -> void:
	await TM.create_once_timer(group.delay)
	var path: int = group.path
	
	for spawn in group.spawns:
		for i in range(spawn.count):
			var e: Entity = EntityDB.create_entity(spawn.name)
			var nav_path_c = e.get_c(CS.CN_NAV_PATH)
			var subpath = spawn.get("subpath")
			nav_path_c.nav_path = path - 1
			nav_path_c.nav_subpath = subpath - 1 if subpath != null else -1
			EntityDB.insert_entity(e)
			
			await TM.create_once_timer(spawn.interval)
			
		await TM.create_once_timer(spawn.next_interval)
	
	
