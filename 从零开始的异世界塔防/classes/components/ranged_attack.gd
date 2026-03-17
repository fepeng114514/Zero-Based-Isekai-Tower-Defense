@tool
extends Node2D
class_name RangedAttack

@export var min_range: float = 0
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
@export var cooldown: float = 1
@export_file("*.tscn") var bullet: String = ""
## 子弹初始位置偏移字典，指定相应方向的偏移
## any 会覆盖所有偏移
@export var bullet_offsets: Dictionary[String, Vector2] = {
	"left": Vector2.ZERO,
	"right": Vector2.ZERO,
	"up": Vector2.ZERO,
	"down": Vector2.ZERO,
	"any": Vector2.ZERO,
}:
	set(value):
		bullet_offsets = value
		queue_redraw()
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 攻击动画数据
@export var animation: AnimationData = null
## 攻击音效数据
@export var sfx: AudioData = null
## 开始攻击到发射子弹的延迟，单位为帧
@export var delay_frame: int = 0
@export var chance: float = 1
@export var with_melee: bool = false
@export var disabled: bool = false

@export_group("Limit")
@export var vis_flags: Array[C.Flag] = []:
	set(value): 
		vis_flags = value
		vis_flag_bits = U.merge_flags(value)
@export var vis_bans: Array[C.Flag] = []:
	set(value): 
		vis_bans = value
		vis_ban_bits = U.merge_flags(value)
@export_file("*.tscn") var whitelist_uid: Array[String] = []
@export_file("*.tscn") var blacklist_uid: Array[String] = []

var vis_flag_bits: int = 0
var vis_ban_bits: int = 0
var ts: float = 0


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	for v: Vector2 in bullet_offsets.values():
		if not v:
			continue
		
		draw_circle(
			v, 
			3,
			Color.GREEN, 
			true
		)
	
	draw_circle(
		position, 
		max_range,
		Color(0.835, 0.416, 0.851, 0.604), 
		false,
		6
	)


func _ready() -> void:
	if animation == null:
		animation = AnimationData.new({
			"left_right": "ranged_left_right",
		})
