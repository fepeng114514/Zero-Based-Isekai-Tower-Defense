extends TextureButton


@onready var parent: Control = get_parent()


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	WaveMgr.is_release_wave = true
	if WaveMgr.is_first_release_wave:
		WaveMgr.first_release_wave.emit()
		WaveMgr.is_first_release_wave = false
	WaveMgr.release_wave.emit()
