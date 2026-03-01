extends Node
class_name RallyComponent

@export var speed: int = 100
@export var rally_radius: float = 30
@export var arrived_dist: float = 10
@export var can_click_rally: bool = true
@export var animation: String = "walk"

var rally_pos := Vector2.ZERO
var direction := Vector2.ZERO
var arrived: bool = false

func new_rally(new_rally_pos: Vector2, new_rally_radius: float = C.UNSET) -> void:
	arrived = false
	rally_pos = new_rally_pos
	
	if U.is_valid_number(new_rally_radius):
		rally_radius = new_rally_radius


func rally_formation_position(count: int, idx: int) -> void:
	if count == 1:
		return
		
	var a: float = 2 * PI / count
	var angle: float = (idx - 1) * a - PI / 2
	
	var new_rally_pos: Vector2 = U.point_on_circle(rally_pos, rally_radius, angle)
	new_rally(new_rally_pos)
