extends Component
class_name TowerComponent

var tower_type: String = ""

func _ready() -> void:
    component_flags = CS.FLAG_TOWER
    super._ready()