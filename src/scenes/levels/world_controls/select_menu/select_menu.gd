extends Control
class_name SelectMenu


signal hide_select_menu


@export var select_menu_config: SelectMenuConfig = null

@export_group("Ref")
@export var place_holders: Control = null
## 环控件引用
@export var ring: TextureRect = null
@export_subgroup("Scene")
@export var rally_button_scene: PackedScene = null
@export var sell_button_scene: PackedScene = null
@export var upgrade_button_scene: PackedScene = null
@export var upgrade_skill_button_scene: PackedScene = null


@export_group("Tween")
## 补间缩放时长
@export var tween_scale_time: float = 0.15
## 补间缩放的目标值
@export var tween_target_scale := Vector2.ONE

## 当前选择的实体
var selected_entity: Entity = null
var is_animating: bool = false


func _ready() -> void:
	visible = false
	
	SelectMgr.select_entity.connect(_show)
	SelectMgr.deselect_entity.connect(_hide)
	hide_select_menu.connect(_hide)
	
	
func _process(_delta: float) -> void:
	if visible and not U.is_valid_entity(selected_entity):
		_hide()
	
	
func _show(e: Entity) -> void:
	if is_animating:
		return
	
	_clear()
	
	var ui_c: UIComponent = e.get_node_or_null(C.CN_UI)
	if not ui_c:
		return
		
	var group: SelectMenuGroup = select_menu_config.group_dict.get(e.scene_name)
	if not group:
		return

	for data: SelectMenuButtonData in group.button_list:		
		var button: SelectMenuButton = null
		
		if data is SelectMenuButtonDataUpgrade:
			button = upgrade_button_scene.instantiate()
			button.upgrade_to = data.upgrade_to
			
			if data.icon:
				button.button.icon = data.icon
		elif data is SelectMenuButtonDataUpgradeSkill:
			button = upgrade_skill_button_scene.instantiate()
			button.upgrade_skill_idx = data.upgrade_skill_idx
			
			if data.icon:
				button.button.icon = data.icon
		elif data is SelectMenuButtonDataRally:
			button = rally_button_scene.instantiate()
		elif data is SelectMenuButtonDataSell:
			button = sell_button_scene.instantiate()
		
		button.select_menu = self
		button.position = place_holders.list[data.place]
		button.selected_entity = e
		ring.add_child(button)
		
	selected_entity = e
	visible = true
	scale = Vector2.ZERO
	global_position = e.global_position + ui_c.select_menu_offset
		
	tween_set_scale(tween_target_scale)
	
	
func _hide() -> void:
	if is_animating:
		return
		
	is_animating = true
	var tween: Tween = tween_set_scale(Vector2.ZERO)
	
	await tween.finished
	_clear()
	is_animating = false
	
	
## 清空菜单
func _clear() -> void:
	visible = false
	
	for child: Control in ring.get_children():
		if child is SelectMenuButton:
			child.queue_free()
		
	selected_entity = null


## 使用补间缩放
func tween_set_scale(target_s: Vector2) -> Tween:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", target_s, tween_scale_time)
	
	return tween
