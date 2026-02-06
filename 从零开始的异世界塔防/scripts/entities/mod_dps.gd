extends Entity

var min_damage: int = 0
var max_damage: int = 0
var damage_interval: float = 1
var damage_type: int = CS.DAMAGE_POISON

func _on_modifier_period(target: Entity, mod_c: ModifierComponent) -> void:
	EntityDB.create_damage(target.id, min_damage, max_damage, damage_type)
