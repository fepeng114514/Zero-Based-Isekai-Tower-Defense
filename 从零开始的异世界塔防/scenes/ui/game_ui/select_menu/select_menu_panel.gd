extends ScrollContainer


@export var upgrade_item_scene: PackedScene = null
#@export var 
@export var item_list: VBoxContainer = null
## 当前选择的实体
var selected_entity: Entity = null


func _ready() -> void:
	visible = false
	
	S.select_entity.connect(_show)
	S.deselect_entity.connect(_hidden)
	
	
func _process(_delta: float) -> void:
	if not U.is_vaild_entity(selected_entity):
		_hidden()
		return
	
	
func _show(e: Entity) -> void:
	var ui_c: UIComponent = e.get_c(C.CN_UI)
	if not ui_c:
		return
	
	if not ui_c.select_menu_data:
		return
	
	selected_entity = e
	visible = true
	#
	#for item_data: SelectMenuItemData in ui_c.select_menu_data.list:
		#var item: Button = item_scene.instantiate()
		#item.selected_entity = e
		#item_list.add_child(item)
	
func _hidden() -> void:
	pass
