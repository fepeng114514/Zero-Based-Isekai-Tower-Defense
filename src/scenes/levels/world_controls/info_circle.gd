extends Control

@export_group("Node Ref")
@export var ranged_max_range_circle: TextureRect = null
@export var ranged_min_range_circle: TextureRect = null
@export var rally_max_range_circle: TextureRect = null
@export var rally_min_range_circle: TextureRect = null
@export var melee_max_range_circle: TextureRect = null
@export var melee_min_range_circle: TextureRect = null

@export_group("Tween")
## 补间缩放时长
@export var tween_scale_time: float = 0.15

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
	SelectMgr.select_entity.connect(_show)
	SelectMgr.deselect_entity.connect(_hide)
	visible = false
	
	
func _process(_delta: float) -> void:
	if not U.is_valid_entity(selected_entity):
		if visible:
			_hide()
		

func _show(e: Entity) -> void:
	selected_entity = e
	
	for circle: TextureRect in all_circle:
		circle.scale = Vector2.ZERO
		circle.visible = false
		
	var base_position: Vector2 = e.global_position - ranged_max_range_circle.size / 2
	
	var ranged_c: RangedComponent = e.get_node_or_null(C.CN_RANGED)
	if ranged_c:
		var first_ranged_attack: RangedBase = ranged_c.get_child(0)
		
		_show_circle(ranged_max_range_circle, first_ranged_attack.max_range, base_position)
		_show_circle(ranged_min_range_circle, first_ranged_attack.min_range, base_position)

	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if melee_c:
		if melee_c.is_blocker:
			_show_melee_circle(e)

	var tower_c: TowerComponent = e.get_node_or_null(C.CN_TOWER)
	if tower_c:
		if tower_c.get_child_count() > 0:
			var first_entity = tower_c.get_child(0)
			if first_entity is EntityGroup2D:
				first_entity = first_entity.get_child(0)
			
			var f_ranged_c: RangedComponent = first_entity.get_node_or_null(C.CN_RANGED)
			var first_ranged_attack: RangedBase = f_ranged_c.get_child(0)
			var pos: Vector2 = base_position + tower_c.show_range_offset
		
			_show_circle(
				ranged_max_range_circle, 
				first_ranged_attack.max_range, 
				pos
			)
			_show_circle(
				ranged_min_range_circle, 
				first_ranged_attack.min_range, 
				pos
			)

	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if barrack_c:
		_show_circle(rally_max_range_circle, barrack_c.rally_max_range, base_position)
		_show_circle(rally_min_range_circle, barrack_c.rally_min_range, base_position)

		var soldier_group: EntityGroup = barrack_c.soldier_group

		if soldier_group.get_child_count() > 0:
			var first_entity = soldier_group.get_child(0)
			_show_melee_circle(first_entity)
	
	visible = true
	
	
func _hide() -> void:
	visible = false
	selected_entity = null
	
	for circle: TextureRect in all_circle:
		_hide_circle(circle)


func _show_melee_circle(e: Entity) -> void:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return
		
	var pos: Vector2 = e.global_position - global_position - melee_max_range_circle.size / 2
	
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if rally_c:
		var rally_center_position: Vector2 = rally_c.rally_center_position
		
		if rally_center_position != Vector2.ZERO:
			pos = rally_center_position - global_position - melee_max_range_circle.size / 2
	
	_show_circle(melee_max_range_circle, melee_c.block_max_range, pos)
	_show_circle(melee_min_range_circle, melee_c.block_min_range, pos)

	
## 显示圆圈
func _show_circle(circle: TextureRect, show_range: float, pos: Vector2) -> void:
	circle.visible = true
	show_range = show_range / (ranged_max_range_circle.size.x / 2)

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(circle, "scale", Vector2(show_range, show_range), tween_scale_time)
	circle.position = pos
	

## 隐藏圆圈
func _hide_circle(circle: TextureRect) -> void:
	var tween: Tween = circle.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(circle, "scale", Vector2.ZERO, tween_scale_time)
	
	await tween.finished
	circle.visible = false
