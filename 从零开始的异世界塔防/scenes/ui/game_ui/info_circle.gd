extends Control


@export_group("Tween")
## 补间缩放时长
@export var scale_time: float = 0.15

@export_group("Node Ref")
@export var ranged_max_range_circle: TextureRect = null
@export var ranged_min_range_circle: TextureRect = null
@export var rally_max_range_circle: TextureRect = null
@export var rally_min_range_circle: TextureRect = null
@export var melee_max_range_circle: TextureRect = null
@export var melee_min_range_circle: TextureRect = null

## 所有圆圈
@onready var all_circle: Array[TextureRect] = [
	ranged_max_range_circle,
	ranged_min_range_circle,
	rally_max_range_circle,
	rally_min_range_circle,
	melee_max_range_circle,
	melee_min_range_circle,
]

## 选择的实体
var selected_entity: Entity = null


func _ready() -> void:
	S.select_entity.connect(_show)
	S.deselect_entity.connect(_hide)
	visible = false
	
	
func _process(_delta: float) -> void:
	if not U.is_vaild_entity(selected_entity):
		if visible:
			_hide()
			return
	else:
		global_position = selected_entity.global_position
		

func _show(e: Entity) -> void:
	selected_entity = e
	
	for circle: TextureRect in all_circle:
		circle.scale = Vector2.ZERO
		circle.visible = false
	
	var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	if ranged_c:
		var first_ranged_attack: RangedBase = ranged_c.list[0]
		
		_show_circle(ranged_max_range_circle, first_ranged_attack.max_range)
		_show_circle(ranged_min_range_circle, first_ranged_attack.min_range)

	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	if melee_c:
		if melee_c.is_blocker:
			_show_circle(melee_max_range_circle, melee_c.block_max_range)
			_show_circle(melee_min_range_circle, melee_c.block_min_range)

	var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
	if tower_c:
		if not tower_c.list.is_empty():
			var first_entity: Entity = tower_c.list[0]
			var f_ranged_c: RangedComponent = first_entity.get_c(C.CN_RANGED)
			var first_ranged_attack: RangedBase = f_ranged_c.list[0]
		
			_show_circle(
				ranged_max_range_circle, 
				first_ranged_attack.max_range, 
				tower_c.show_range_offset)
			_show_circle(
				ranged_min_range_circle, 
				first_ranged_attack.min_range, 
				tower_c.show_range_offset
			)

	var barrack_c: BarrackComponent = e.get_c(C.CN_BARRACK)
	if barrack_c:
		_show_circle(rally_max_range_circle, barrack_c.rally_max_range, barrack_c.show_range_offset)
		_show_circle(rally_min_range_circle, barrack_c.rally_min_range, barrack_c.show_range_offset)
	
	visible = true
	global_position = e.global_position
	
	
func _hide() -> void:
	visible = false
	selected_entity = null
	
	for circle: TextureRect in all_circle:
		_hide_circle(circle)

	
## 显示圆圈
func _show_circle(circle: TextureRect, show_range: float, offset := Vector2.ZERO) -> void:
	circle.visible = true
	show_range = show_range / 200

	var tween: Tween = circle.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(circle, "scale", Vector2(show_range, show_range), scale_time)
	circle.position = offset
	

## 隐藏圆圈
func _hide_circle(circle: TextureRect) -> void:
	var tween: Tween = circle.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(circle, "scale", Vector2.ZERO, scale_time)
	tween.tween_callback(func(): circle.visible = false)
	
