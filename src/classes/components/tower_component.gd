@tool
extends Node2D
class_name TowerComponent


## 防御塔类型
@export var tower_type: C.TowerType = C.TowerType.TOWER_HOLDER
## 显示范围的偏移
@export var show_range_offset := Vector2.ZERO:
	set(value):
		show_range_offset = value
		queue_redraw()
## 塔位样式
@export var tower_holder_style: C.TowerHolderStyle = C.TowerHolderStyle.GRASS
## 价格
@export var price: float = 0
## 出售比例（%）
@export var sell_ratio: float = 0.5
## 默认集结点
@export var default_rally_center_local_pos := Vector2.ZERO:
	set(value):
		default_rally_center_local_pos = value
		queue_redraw()

## 总价格
var total_price: float = price
## 升级目标
var upgrade_to: String = ""
## 出售状态
var is_sell: bool = false
## 时间戳
var ts: float = 0

@onready var parent: Entity = get_parent()

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"default_rally_center_local_pos":
			property.hint_string = "vector_picker"


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		show_range_offset, 
		3,
		Color(0.757, 0.0, 0.62, 1.0), 
		true
	)
	
	draw_circle(
		default_rally_center_local_pos,
		9,
		Color.BLUE, 
		true
	)
	draw_line(
		default_rally_center_local_pos, 
		to_local(parent.global_position), 
		Color.BLUE, 
		2
	)
