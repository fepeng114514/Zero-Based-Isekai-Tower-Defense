extends Control
class_name SelectMenu


signal hide_select_menu


@export_group("Node Ref")
## 按钮位置控件
@export var place_holder_controller: Control = null
## 环控件引用
@export var ring: TextureRect = null

@export_group("Ref")
@export var select_menu_config: SelectMenuConfig = null
## 选择菜单按钮场景引用
@export var select_menu_button_scene: PackedScene = null

@export_group("Tween")
## 补间缩放时长
@export var scale_time: float = 0.15
## 补间缩放的目标值
@export var target_scale := Vector2.ONE

## 按钮列表
var button_list: Array[Button] = []
## 当前选择的实体
var selected_entity: Entity = null
var is_animating: bool = false


func _ready() -> void:
	visible = false
	
	S.select_entity.connect(_show)
	S.deselect_entity.connect(_hide)
	hide_select_menu.connect(_hide)
	
	
func _process(_delta: float) -> void:
	if visible and not U.is_valid_entity(selected_entity):
		_hide()
		return
	
	
func _show(e: Entity) -> void:
	if is_animating:
		return
	
	_clear_menu()
	
	var ui_c: UIComponent = e.get_node_or_null(C.CN_UI)
	if not ui_c:
		return

	for button_data: SelectMenuButtonData in select_menu_config.group_dict[e.scene_name].button_list:
		var button_type: C.SelectMenuButtonType = button_data.type
		var upgrade_to: String = button_data.upgrade_to
		
		var button: SelectMenuButton = select_menu_button_scene.instantiate()
		button.select_menu = self
		button.position = place_holder_controller.list[button_data.place]
		button.selected_entity = e
		button.icon = button_data.icon
		button.type = button_type
		button.upgrade_to = upgrade_to
		button.upgraded_skill = button_data.upgraded_skill
		button.bought_item = button_data.buy_item
		button_list.append(button)
		ring.add_child(button)
		
		match button_type:
			C.SelectMenuButtonType.UPGRADE:
				var upgrade_target: Entity = EntityMgr.get_entity_data(
					upgrade_to
				)
				
				if upgrade_target.get_node_or_null(C.CN_TOWER).price > GameMgr.cash:
					button_data.disabled = true
			#C.SelectMenuButtonType.BUY:
			#C.SelectMenuButtonType.SKILL:
			#C.SelectMenuButtonType.AIM:
			#C.SelectMenuButtonType.SWITCH:
		
	selected_entity = e
	visible = true
	scale = Vector2.ZERO
	global_position = e.global_position + ui_c.select_menu_offset
		
	tween_set_scale(target_scale)
	
	
func _hide() -> void:
	if is_animating:
		return
		
	is_animating = true
	var tween: Tween = tween_set_scale(Vector2.ZERO)
	
	await tween.finished
	_clear_menu()
	is_animating = false
	
	
## 清空菜单
func _clear_menu() -> void:
	visible = false
	
	for button: SelectMenuButton in button_list:
		if is_instance_valid(button):
			button.queue_free()
		
	button_list.clear()
	selected_entity = null


## 使用补间缩放
func tween_set_scale(target_s: Vector2) -> Tween:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", target_s, scale_time)
	
	return tween
