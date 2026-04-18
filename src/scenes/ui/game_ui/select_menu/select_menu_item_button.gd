extends Button
class_name SelectMenuItemButton


## 选择菜单引用
var select_menu: SelectMenu = null
## 选择的实体
var selected_entity: Entity = null
## 选择菜单项类型
var type: C.SelectMenuItemType = C.SelectMenuItemType.UPGRADE
## 升级为的实体名称
## 
## type 为 UPGRADE 时可用
var upgrade_to: String = ""
## 升级的技能索引
## 
## type 为 SKILL 时可用
var upgraded_skill: int = C.UNSET
## 购买的条目索引
##
## type 为 BUY 时可用
var bought_item: int = C.UNSET


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
## 点击并松开按钮时调用的信号处理函数
func _on_pressed() -> void:
	var tower_c: TowerComponent = selected_entity.get_child_node(C.CN_TOWER)
	
	match type:
		C.SelectMenuItemType.UPGRADE:
			tower_c.upgrade_to = upgrade_to
			
		C.SelectMenuItemType.SELL:
			tower_c.is_sell = true
			
		C.SelectMenuItemType.RALLY:
			SelectMgr.select_mode = C.SelectMode.BARRACK_RALLY
			select_menu.hide_select_menu.emit()
			
		#C.SelectMenuItemType.BUY:
		#C.SelectMenuItemType.SKILL:
		#C.SelectMenuItemType.AIM:
		#C.SelectMenuItemType.SWITCH:
