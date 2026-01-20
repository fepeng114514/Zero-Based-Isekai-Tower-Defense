extends Node2D
var attack_range: int = 300
var attack_cooldown: float = 1.0
var trigger_radius: CollisionShape2D
var enemies_in_range: Array = []
var can_attack: bool = true
var target: Node2D = null
var bullet_scene: PackedScene
var bullet_speed: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemies_in_range.size() > 0:
		# 选择最近的敌人
		target = get_closest_enemy()
		
		if target and can_attack:
			attack(target)
	else:
		target = null
		
func get_closest_enemy() -> Node2D:
	var closest: Node2D = null
	var closest_distance: float = INF
	
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest = enemy
	return closest

func attack(target_enemy: Node2D):
	if not bullet_scene or not is_instance_valid(target_enemy):
		return
	
	# 创建子弹
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	
	# 设置子弹位置和方向
	bullet.global_position = $BulletSpawn.global_position
	
	# 计算朝向目标的方向
	var direction = (target_enemy.global_position - global_position).normalized()
	bullet.direction = direction
	bullet.speed = bullet_speed
	
	# 开始冷却
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# 检测区域信号处理
func _on_detection_area_body_entered(body):
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_detection_area_body_exited(body):
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func _on_detection_area_area_entered(area):
	if area.is_in_group("enemies"):
		enemies_in_range.append(area.get_parent())

func _on_detection_area_area_exited(area):
	var enemy = area.get_parent()
	if enemy in enemies_in_range:
		enemies_in_range.erase(enemy)
