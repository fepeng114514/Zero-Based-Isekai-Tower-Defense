extends Component
class_name ModifierComponent

var mod_type: int = 0
var allow_same: bool = false
var reset_same: bool = true
var replace_same: bool = false

func _ready() -> void:
    component_flags = CS.FLAG_MODIFIER
    super._ready()