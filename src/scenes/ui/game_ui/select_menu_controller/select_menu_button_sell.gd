extends SelectMenuButton
class_name SelectMenuButtonSell

	
func _on_pressed() -> void:
	var tower_c: TowerComponent = selected_entity.get_node_or_null(C.CN_TOWER)
	tower_c.is_sell = true
