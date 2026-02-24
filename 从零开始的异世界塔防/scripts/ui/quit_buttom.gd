extends Button



func _ready() -> void:
	pressed.connect(_button_pressed)


func _button_pressed() -> void:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.title = "请确认"
	dialog.dialog_text = "确定要退出游戏吗？"
	dialog.ok_button_text = "确认"
	dialog.cancel_button_text = "取消"
	dialog.confirmed.connect(_on_quit_confirmed)
	
	add_child(dialog)
	dialog.popup_centered()


func _on_quit_confirmed() -> void:
	get_tree().quit()
