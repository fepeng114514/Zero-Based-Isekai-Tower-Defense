extends Component
class_name EnemyComponent

func _ready() -> void:
    component_flags = CS.FLAG_ENEMY
    super._ready()