extends Node2D
var attack_range: int = 300
var attack_cooldown: float = 1.0
var trigger_radius: CollisionShape2D
var can_attack: bool = true
var target: Node2D = null
var bullet_speed: float = 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var target = EntitySystem.find_enemy_in_range(self.position, attack_range)[0]
		
	if target and can_attack:
		attack(target)
		
func attack(target_enemy):
	# 创建子弹
	var bullet = EntitySystem.create_entity("bullet", get_node("Main"))
	
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
