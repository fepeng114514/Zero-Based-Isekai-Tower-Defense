extends Node
class_name BulletComponent

var min_damage: int = 0
var max_damage: int = 0
var damage_type: int = 1
var min_damage_radius: float = 0
var max_damage_radius: float = 0
var search_mode: String = CS.SEARCH_MODE_ENEMY_FIRST
var mods: Array = []
var speed = 0
var rotation_speed: float = 0
var rotation_direction: int = -1
var velocity: Vector2 = Vector2.ZERO
var hit_rect: Rect2 = Rect2(-3, -3, 6, 6)
var g: int = 980
var flight_time: float = 0
var from: Vector2 = Vector2(0, 0)
var to: Vector2 = Vector2(0, 0)
var can_arrived: bool = true
var direction: Vector2 = Vector2.RIGHT
var predict_target_pos: Vector2 = Vector2(0, 0)
var predict_target_pos_valid: bool = false
var ts: float = 0
var flight_trajectory: int = CS.TRAJECTORY_LINEAR
var hit_remove: bool = true
var miss_remove: bool = true
