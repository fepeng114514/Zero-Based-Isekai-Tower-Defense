extends TextureRect
class_name InfoCircle


var scale_tween: Tween = null
var is_animating: bool = false


## 显示圆圈
func _show(show_range: float, pos: Vector2, tween_scale_time: float) -> void:
	if is_animating:
		return

	if show_range <= 0:
		return

	visible = true
	position = pos
	
	show_range = show_range / (size.x / 2)
	if show_range == scale.x:
		return

	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", Vector2(show_range, show_range), tween_scale_time)
	
	is_animating = true
	await scale_tween.finished
	is_animating = false
	

## 隐藏圆圈
func _hide(tween_scale_time: float) -> void:
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", Vector2.ZERO, tween_scale_time)
	
	is_animating = true
	await scale_tween.finished
	is_animating = false
	visible = false
