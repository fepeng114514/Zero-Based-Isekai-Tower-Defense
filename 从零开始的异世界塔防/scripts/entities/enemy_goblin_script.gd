extends Entity
@onready var animated_sprite = $SpriteComponent
@onready var Health = get_c(CS.CN_HEALTH)

func _ready() -> void:
	flags = CS.FLAG_ENEMY

func on_insert() -> bool:
	animated_sprite.play()
	return true
