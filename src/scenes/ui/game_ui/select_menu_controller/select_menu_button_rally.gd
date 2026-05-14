extends SelectMenuButton
class_name SelectMenuButtonRally


func _on_pressed() -> void:
	SelectMgr.select_mode = C.SelectMode.BARRACK_RALLY
	select_menu.hide_select_menu.emit()
		
