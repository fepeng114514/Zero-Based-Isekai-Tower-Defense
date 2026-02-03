extends Node
class_name BarrackComponent

var max_soldiers: int = 3
var rally_ranged: int = 200
var rally_pos: Vector2 = Vector2(0, 0)
var rally_radius: int = 30
var rally_speed: int = 50
var respawn_time: float = 10
var soldier: String = "soldier"
var soldiers_list: Array = []
var last_soldier_count: int = -1
var ts: float = 0
