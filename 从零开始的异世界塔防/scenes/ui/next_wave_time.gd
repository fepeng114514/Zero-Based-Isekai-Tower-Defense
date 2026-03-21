extends TextureProgressBar

## 箭头引用
@export var arrow: TextureRect = null
## 箭头旋转角度
@export_range(-180, 180, 0.1, "radians_as_degrees") var arrow_rotation: float = 0
## 装饰引用
@export var decoration: TextureRect = null


func _ready() -> void:
	arrow.rotation = arrow_rotation
	S.start_wave_timer.connect(_start_timer)
	
	# 启动缩放循环动画
	start_scale_loop()

func start_scale_loop() -> void:
	# 创建独立的缩放补间
	var scale_tween: Tween = create_tween()
	scale_tween.set_loops()  # 无限循环
	
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.7)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.7)

func _start_timer(wave: Wave) -> void:
	visible = true
	value = min_value
	
	var value_tween: Tween = create_tween()
	value_tween.tween_property(self, "value", max_value, wave.interval)
	
	await get_tree().create_timer(wave.interval).timeout
	visible = false
