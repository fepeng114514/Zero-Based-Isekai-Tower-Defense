@tool
extends TextureRect


@export var lable: Label = null


func _ready() -> void:
	lable.text = name
