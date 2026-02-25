extends Node


var IS_RELEASE: bool = OS.has_feature("release")
var IS_DEBUG: bool = OS.has_feature("debug")
var MAX_WINDOW_SIZE := Vector2(2560, 1440)
var WINDOW_SIZE := Vector2.ZERO

func _ready() -> void:
	get_viewport().size_changed.connect(_on_window_resized)
	var window_size: Vector2 = get_viewport().get_visible_rect().size
	
	WINDOW_SIZE = window_size

func _on_window_resized() -> void:
	var window_size: Vector2 = get_viewport().get_visible_rect().size
	
	Log.debug("重设窗口大小: %s", window_size)
	WINDOW_SIZE = window_size
	
	S.resized_window_s.emit()
