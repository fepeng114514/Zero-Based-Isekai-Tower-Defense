extends Component
class_name AttackComponent

var attacks: Array = []
var attack_template: Dictionary = {}
var can_attack: bool = true

func add_attack() -> void:
	attacks.append(attack_template.duplicate_deep())
	
func _ready() -> void:
	add_attack()
