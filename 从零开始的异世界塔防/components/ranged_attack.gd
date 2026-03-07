@tool
extends Node2D
class_name RangedAttack

@export var min_range: float = 25
@export var max_range: float = 25
@export var cooldown: float = 1
@export var bullet: C.ENTITY_TAG
@export var bullet_offset := Vector2.ZERO:
	set(value):
		bullet_offset = value
		queue_redraw()
@export var search_mode: C.SEARCH = C.SEARCH.ENEMY_MAX_PROGRESS
@export var animation: String = "ranged"
@export var delay: float = 0
@export var chance: float = 1
@export var with_melee: bool = false
@export var disabled: bool = false

@export_group("限制相关")
@export var vis_flags: Array[C.FLAG] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.FLAG] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export var whitelist_tag: Array[C.ENTITY_TAG] = []
@export var blacklist_tag: Array[C.ENTITY_TAG] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
var ts: float = 0


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		bullet_offset, 
		3,
		Color.GREEN, 
		true
	)
