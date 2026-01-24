extends Entity
@onready var Ranged = $RangedComponent
@onready var base_attack = Ranged.attacks[0]

func update(delta: float) -> void:
	var target = EntityDB.find_enemy_in_range(self.position, base_attack.min_range, base_attack.max_range)[0]
		
	if target and CooldownManager.is_ready("attack0001"):
		attack(target)
		
func attack(target):
	var bullet = EntityDB.create_entity(base_attack.bullet)
	bullet.target_id = target.id
	bullet.source_id = id
	
	CooldownManager.start_cooldown("attack0001", base_attack.cooldown)
