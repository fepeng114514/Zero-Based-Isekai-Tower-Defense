extends Entity
@onready var Ranged = $RangedComponent
@onready var base_attack = Ranged.attacks[0]

func update() -> void:
	var target = EntityDB.find_enemy_in_range(self.position, base_attack.min_range, base_attack.max_range)
		
	if target and TimeManager.is_ready("0001"):
		attack(target[0])
		
func attack(target):
	var bullet = EntityDB.create_entity(base_attack.bullet)
	bullet.target_id = target.id
	bullet.source_id = id
	bullet.position = position
	TimeManager.start_timer("0001", base_attack.cooldown)
