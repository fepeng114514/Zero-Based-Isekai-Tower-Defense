extends Control
class_name SelectMenu


signal hide_select_menu


@export_group("Node Ref")
## 按钮位置控件
@export var place_holders: Control = null
## 环控件引用
@export var ring: TextureRect = null
## 项目按钮场景引用
@export var select_menu_item_button_scene: PackedScene = null

@export_group("Tween")
## 补间缩放时长
@export var scale_time: float = 0.15
## 补间缩放到目标值
@export var target_scale := Vector2.ONE

## 项列表
var item_list: Array[Button] = []
## 当前选择的实体
var selected_entity: Entity = null


func _ready() -> void:
	visible = false
	
	S.select_entity.connect(_show)
	S.deselect_entity.connect(_hide)
	hide_select_menu.connect(_hide)
	
	
func _process(_delta: float) -> void:
	if visible and not U.is_vaild_entity(selected_entity):
		_hide()
		return
	
	
func _show(e: Entity) -> void:
	_clear_menu()
	
	var ui_c: UIComponent = e.get_c(C.CN_UI)
	if not ui_c:
		return
	
	if not ui_c.select_menu_data:
		return
	
	for item_data: SelectMenuItemData in ui_c.select_menu_data.list:
		var type: C.SelectMenuItemType = item_data.type
		var upgrade_to: String = item_data.upgrade_to
		
		var item: SelectMenuItemButton = select_menu_item_button_scene.instantiate()
		item.select_menu = self
		item.position = place_holders.position_list[item_data.place]
		item.selected_entity = e
		item.icon = item_data.icon
		item.type = type
		item.upgrade_to = item_data.upgrade_to
		item.upgraded_skill = item_data.upgraded_skill
		item.bought_item = item_data.buy_item
		item_list.append(item)
		ring.add_child(item)
		
		match type:
			C.SelectMenuItemType.UPGRADE:
				var upgrade_target: Entity = EntityMgr.get_entity_data(
					upgrade_to
				)
				
				if upgrade_target.get_c(C.CN_TOWER).price > GameMgr.cash:
					item.disabled = true
			#C.SelectMenuItemType.BUY:
			#C.SelectMenuItemType.SKILL:
			#C.SelectMenuItemType.AIM:
			#C.SelectMenuItemType.SWITCH:
		
	selected_entity = e
	visible = true
	scale = Vector2.ZERO
	global_position = e.global_position + ui_c.select_menu_offset
		
	tween_set_scale(target_scale)
	
	
func _hide() -> void:
	var tween: Tween = tween_set_scale(Vector2.ZERO)
	tween.tween_callback(_clear_menu)
	
	
## 清空菜单
func _clear_menu() -> void:
	visible = false
	
	for item: SelectMenuItemButton in item_list:
		if is_instance_valid(item):
			item.queue_free()
		
	item_list.clear()
	selected_entity = null


## 使用补间缩放
func tween_set_scale(target_s: Vector2) -> Tween:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", target_s, scale_time)
	
	return tween
