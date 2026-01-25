extends Component
class_name AttackComponent

var attacks: Array = []
var attack_template: Dictionary = {}
var can_attack: bool = true

func _ready() -> void:	
	var setting_data = get_setting_data()
	var attaks_data = setting_data.attacks
	
	for i: int in range(attaks_data.size()):
		var attack: Dictionary = add_attack()
		var new_attack: Dictionary = attaks_data[i]
		attack.merge(new_attack, true)

func add_attack() -> Dictionary:
	var a: Dictionary = attack_template.duplicate_deep()
	attacks.append(a)
	return a
	
