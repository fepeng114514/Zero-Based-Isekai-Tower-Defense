extends Component
class_name AttackComponent

var attacks: Array = []
var attack_template: Dictionary = {}

func _ready() -> void:	
	var setting_data = Utils.get_setting_data(parent.template_name, Utils.get_component_name(name))
	var attaks_data = setting_data.attacks
	
	for i: int in range(attaks_data.size()):
		var attack: Dictionary = add_attack()
		var new_attack: Dictionary = attaks_data[i]
		Utils.merge_type_dict(attack, new_attack)
		
	parent.components[name] = self

func add_attack() -> Dictionary:
	var a: Dictionary = attack_template.duplicate_deep()
	attacks.append(a)
	return a
	
