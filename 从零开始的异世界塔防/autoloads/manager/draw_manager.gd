extends Node2D

var selected_entity: Variant = null


func _ready() -> void:
	S.select_entity_s.connect(_on_select_entity)
	S.deselect_entity_s.connect(_on_deselect_entity)
	z_index = 1000


func _on_select_entity(e: Entity) -> void:
	selected_entity = e
	
	
func _on_deselect_entity() -> void:
	selected_entity = null


func _draw() -> void:
	if not selected_entity:
		return
		
	var e: Entity = selected_entity
	
	var center: Vector2 = e.position
	
	if e.has_c(C.CN_RANGED):
		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
		var radius: float = ranged_c.order[0].max_range
		var color := Color(0.0, 0.914, 0.278, 0.522)
	
		# 实心圆
		draw_circle(center, radius, color)
