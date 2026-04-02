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
## 子实体列表
@export var list: Array[Entity] = []
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


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	draw_circle(
		show_range_offset, 
		3,
		Color(0.757, 0.0, 0.62, 1.0), 
		true
	)

	
## 自动更新列表
func _update_list() -> void:
	var new_list: Array[Entity] = []
	
	for child: Entity in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	EditorUtils.tool_on_tree_call(self, what, _update_list)


## 清理 list 中已经不存在的实体
func cleanup_list() -> void:
	var new_list: Array[Entity] = []
	
	for sub_e in list:
		if not U.is_vaild_entity(sub_e):
			continue 
			
		new_list.append(sub_e)
		
	list = new_list
