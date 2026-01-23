extends Component
class_name MeleeComponent

var melee_range: int = 0
var attacks: Array = []

var attack_template: Dictionary = {
	"min_damage": 0,
	"max_damage": 0,
	"cooldown": 0,
	"mod": "",
	"damage_type": 0,
}
