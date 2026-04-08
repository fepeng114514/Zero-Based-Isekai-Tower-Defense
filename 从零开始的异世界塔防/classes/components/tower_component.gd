@tool
extends Node2D
class_name TowerComponent


## 防御塔类型
@export var tower_type: C.TowerType = C.TowerType.TOWER_HOLDE
## 每个子实体进行远程攻击轮换的间隔
@export var attack_loop_time: float = 0
## 显示范围的偏移
@export var show_range_offset := Vector2.ZERO:
	set(value):
		show_range_offset = value
		queue_redraw()
## 塔位样式
@export var tower_holder_style: C.TowerHolderStyle = C.TowerHolderStyle.GRASS
## 价格
@export var price: float = 70
## 出售比例（%）
@export var sell_ratio: float = 0.5

## 总价格
var total_price: float = price
## 升级目标
var upgrade_to: String = ""
## 出售状态
var is_sell: bool = false
## 当前攻击的实体索引
var attack_entity_idx: int = 0
## 时间戳
var ts: float = 0
## 子实体列表
var list: Array[Entity] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	for child: Entity in get_children():
		list.append(child)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		show_range_offset, 
		3,
		Color(0.757, 0.0, 0.62, 1.0), 
		true
	)


## 清理 list 中已经不存在的实体
func cleanup_list() -> void:
	var new_list: Array[Entity] = []
	
	for sub_e in list:
		if not U.is_valid_entity(sub_e):
			continue 
			
		new_list.append(sub_e)
		
	list = new_list
