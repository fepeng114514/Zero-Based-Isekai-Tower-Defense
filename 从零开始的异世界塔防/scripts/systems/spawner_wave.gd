extends Node
class_name PathManage

@onready var wave_datas = Utils.load_json_file("res://data/waves/wave.json")

func timer(time: float) -> Signal:
	return get_tree().create_timer(time).timeout

func _ready() -> void:
	for wave: Dictionary in wave_datas:
		# 每波之间的等待
		await timer(wave.interval)
		
		for group in wave.groups:
			# 出怪组并行
			var spawner: Callable = Callable(self, "_spawner").bind()
			spawner.call(group)

func _spawner(group: Dictionary) -> void:
	await timer(group.delay)
	var path: int = group.path
	
	for spawn in group.spawns:
		for i in range(spawn.count):
			var enemy: Entity = EntityDB.create_entity(spawn.name)
			var nav_path_c: NavPathComponent = enemy.get_node("NavPathComponent")
			var subpath = spawn.get("subpath")
			nav_path_c.nav_path = path - 1
			nav_path_c.nav_subpath = subpath - 1 if subpath != null else -1
			
			await timer(spawn.interval)
			
		await timer(spawn.next_interval)
	
	
