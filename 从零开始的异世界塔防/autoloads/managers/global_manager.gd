extends Node


var is_release: bool = OS.has_feature("release")
var is_debug: bool = OS.has_feature("debug")
var max_window_size := Vector2(2560, 1440)
var window_size := Vector2.ZERO
var world_size: Vector2i = Vector2i(2560, 1440)


func _ready() -> void:
	get_viewport().size_changed.connect(_on_window_resized)
	window_size = get_viewport().get_visible_rect().size


func _on_window_resized() -> void:
	var new_size: Vector2 = get_viewport().get_visible_rect().size
	
	Log.debug("重设窗口大小: %s" % new_size)
	window_size = new_size
	
	S.resized_window.emit()
