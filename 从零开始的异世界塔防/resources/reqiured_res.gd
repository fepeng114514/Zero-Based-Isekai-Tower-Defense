extends Resource
class_name ReqiuredRes

var level_required_system: Array[System] = [
	ModifierSystem.new(),
	HealthSystem.new(),
	EntitySystem.new(),
	NavPathSystem.new(),
]
