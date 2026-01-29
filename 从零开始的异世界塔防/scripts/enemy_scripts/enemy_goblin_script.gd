extends Entity
@onready var health_bar_fg: ColorRect = $HealthBar/FG
@onready var origin_health_bar_fg_scale: Vector2 = health_bar_fg.scale
@onready var animated_sprite: AnimatedSprite2D = get_c(CS.CN_SPRITE)
@onready var Health = $HealthComponent

func _ready() -> void:
	flags = CS.FLAG_ENEMY

func on_insert() -> bool:
	animated_sprite.play()
	return true
	
func on_update(delta: float) -> void:
	health_bar_fg.scale.x = origin_health_bar_fg_scale.x * Health.get_hp_percent()
