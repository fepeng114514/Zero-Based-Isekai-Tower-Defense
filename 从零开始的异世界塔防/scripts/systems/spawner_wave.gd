extends Node
class_name SpawnerWave

var wave_data: Array = []
@onready var parent = get_parent()

func _ready() -> void:
	wave_data = Utils.load_json_file(CS.PATH_WAVES_DATA % parent.level_idx)
	
	for wave: Dictionary in wave_data:
		# 每波之间的等待
		await Utils.create_timer(wave.interval)
		
		for group in wave.groups:
			# 出怪组并行
			var spawner: Callable = Callable(self, "_spawner").bind()
			spawner.call(group)

func _spawner(group: Dictionary) -> void:
	await Utils.create_timer(group.delay)
	var path: int = group.path
	
	for spawn in group.spawns:
		for i in range(spawn.count):
			var enemy: Entity = EntityDB.create_entity(spawn.name)
			var nav_path_c: NavPathComponent = enemy.get_node("NavPathComponent")
			var subpath = spawn.get("subpath")
			nav_path_c.nav_path = path - 1
			nav_path_c.nav_subpath = subpath - 1 if subpath != null else -1
			
			await Utils.create_timer(spawn.interval)
			
		await Utils.create_timer(spawn.next_interval)
	
	
