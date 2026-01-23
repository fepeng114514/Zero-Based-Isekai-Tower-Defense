extends Entity
@onready var health_bar_fg: ColorRect = $HealthBar/FG
@onready var origin_health_bar_fg_scale: Vector2 = health_bar_fg.scale
@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var Motion = $MotionComponent
@onready var Health = $HealthComponent

func _ready() -> void:
	health_bar_fg.scale.x = origin_health_bar_fg_scale.x * Health.get_hp_percent()

	animated_sprite.play()
	
func update(delta: float) -> void:
	if Health.hp <= 0:
		Health.dead = true
		EntityDB.remove_entity(self)
	
	health_bar_fg.scale.x = origin_health_bar_fg_scale.x * Health.get_hp_percent()
