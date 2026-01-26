extends Entity
@onready var Ranged = $RangedComponent
@onready var base_attack = Ranged.attacks[0]

func update() -> void:
	var target = EntityDB.find_enemy_in_range(self.position, base_attack.min_range, base_attack.max_range)
		
	if target and TM.is_ready_time(base_attack.ts, base_attack.cooldown):
		attack(target[0])
		
func attack(target):
	var bullet = EntityDB.create_entity(base_attack.bullet)
	bullet.target_id = target.id
	bullet.source_id = id
	bullet.position = position
	#base_attack.ts = TM.tick_ts
