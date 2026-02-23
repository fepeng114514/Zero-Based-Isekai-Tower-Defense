extends Node
class_name RallyComponent

var speed: int = 100
var rally_pos: Vector2 = Vector2(0, 0)
var rally_radius: int = 30
var direction: Vector2 = Vector2.LEFT
var arrived: bool = false
var arrived_dist: int = 10
var animation: String = "walk"
var can_click_rally: bool = true


func new_rally(new_rally_pos: Vector2, new_rally_radius = null):
	arrived = false
	rally_pos = new_rally_pos
	
	if new_rally_radius:
		rally_radius = new_rally_radius


func rally_formation_position(count: int, idx: int):
	if count == 1:
		return
		
	var a: float = 2 * PI / count
	var angle: float = (idx - 1) * a - PI / 2
	
	var new_rally_pos: Vector2 = U.point_on_circle(rally_pos, rally_radius, angle)
	new_rally(new_rally_pos)
