extends Button

func _ready():
	pressed.connect(_button_pressed)

func _button_pressed():
	LevelMgr.enter_level(1)
