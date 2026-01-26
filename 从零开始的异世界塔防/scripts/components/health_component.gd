extends Component
class_name HealthComponent

var hp_max: int = 0
var hp: int = 0
var health_bar_hidden: bool = false
var health_bar_scale: Vector2 = Vector2(1, 1)
var dead: bool = false
var physical_armor: int = 0
var magical_armor: int = 0
var damage_factor: float = 1


func get_hp_percent() -> float:
	return float(self.hp) / float(self.hp_max)
