extends Node2D
class_name EllipseDetector

@export var detection_rate: float = 10.0  # 检测频率(Hz)

var enemies: Array = []  # 敌人引用数组
var nearby_enemies: Array = []  # 范围内的敌人
var detection_timer: float = 0.0
var rotation_rad: float = 0.0

func _ready():
	# 初始化获取敌人列表
	refresh_enemy_list()
	# 监听全局信号更新敌人列表
	#EnemyManager.connect("enemy_spawned", _on_enemy_spawned)
	#EnemyManager.connect("enemy_died", _on_enemy_died)

func _process(delta):
	detection_timer -= delta
	if detection_timer <= 0:
		detection_timer = 1.0 / detection_rate

func refresh_enemy_list():
	# 获取场景中所有敌人
	enemies = get_tree().get_nodes_in_group("enemies")

func _sort_by_distance(a, b):
	return global_position.distance_squared_to(a.global_position) < \
		   global_position.distance_squared_to(b.global_position)

func _on_enemy_spawned(enemy):
	if not enemy in enemies:
		enemies.append(enemy)

func _on_enemy_died(enemy):
	if enemy in enemies:
		enemies.erase(enemy)
