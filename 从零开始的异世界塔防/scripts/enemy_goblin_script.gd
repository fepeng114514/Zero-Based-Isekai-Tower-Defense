extends Entity

@onready var health_bar_fg: ColorRect = $HealthBar/FG
@onready var origin_health_bar_fg_scale: Vector2 = health_bar_fg.scale
@onready var path_follow: PathFollow2D = get_parent()
@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var Motion = $Motion
@onready var Health = $Health

func _ready() -> void:
	animated_sprite.play()
	
func update(delta: float) -> void:
	path_follow.progress += Motion.speed * delta
	
	if Health.hp <= 0:
		Health.dead = true
		EntitySystem.remove_entity(self)
	
	health_bar_fg.scale.x = origin_health_bar_fg_scale.x * Health.get_hp_percent()
