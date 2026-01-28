extends Component
class_name BulletComponent

var min_damage: int = 0
var max_damage: int = 0
var mod: String = ""
var damage_type: int = 0
var speed = 0
var rotation_speed: float = 0
var hit_rect: Rect2 = Rect2(-3, -3, 6, 6)
var flight_time: float = 0
var g: int = 980
var from: Vector2 = Vector2(0, 0)
var to: Vector2 = Vector2(0, 0)
var predict_target_pos: Vector2 = Vector2(0, 0)
var direction: Vector2 = Vector2.RIGHT
var rotation_direction: int = -1
