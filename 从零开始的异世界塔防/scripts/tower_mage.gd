extends Entity
@onready var Ranged = $RangedComponent
@onready var base_attack = Ranged.attacks[0]

func update() -> void:
	var target = EntityDB.find_enemy_first(self.position, base_attack.min_range, base_attack.max_range)
		
	if target and TM.is_ready_time(base_attack.ts, base_attack.cooldown):
		attack(target)
		
func attack(target):
	var b = EntityDB.create_entity(base_attack.bullet)
	b.target_id = target.id
	b.source_id = id
	b.position = position
	EntityDB.insert_entity(b)
	base_attack.ts = TM.tick_ts
