extends Button
class_name SelectMenuButton


@export_group("Ref")
@export var upgrade_glow: TextureRect = null
@export var rally_glow: TextureRect = null
@export var sell_glow: TextureRect = null
@export var skill_glow: TextureRect = null

## 选择菜单引用
var select_menu: SelectMenu = null
## 选择的实体
var selected_entity: Entity = null
## 选择菜单项类型
var type: C.SelectMenuButtonType = C.SelectMenuButtonType.UPGRADE
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

@onready var glow_list: Array[TextureRect] = [
	upgrade_glow,
	rally_glow,
	sell_glow,
	skill_glow,
]

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	for glow: TextureRect in glow_list:
		glow.visible = false
	
	
func _on_mouse_entered() -> void:
	for glow: TextureRect in glow_list:
		match type:
			C.SelectMenuButtonType.UPGRADE when glow == upgrade_glow:  
				pass
			C.SelectMenuButtonType.RALLY when glow == rally_glow:
				pass
			C.SelectMenuButtonType.SELL when glow == sell_glow:
				pass
			C.SelectMenuButtonType.SKILL when glow == skill_glow:
				pass
			#C.SelectMenuButtonType.BUY when glow == buy_glow:
			# C.SelectMenuButtonType.AIM when glow == aim_glow:
			# C.SelectMenuButtonType.SWITCH when glow == switch_glow:
			_:
				continue
		
		glow.visible = true

	
	
func _on_mouse_exited() -> void:
	for glow: TextureRect in glow_list:
		glow.visible = false
	
	
## 点击并松开按钮时调用的信号处理函数
func _on_pressed() -> void:
	var tower_c: TowerComponent = selected_entity.get_node_or_null(C.CN_TOWER)
	
	match type:
		C.SelectMenuButtonType.UPGRADE:
			tower_c.upgrade_to = upgrade_to
			
		C.SelectMenuButtonType.SELL:
			tower_c.is_sell = true
			
		C.SelectMenuButtonType.RALLY:
			SelectMgr.select_mode = C.SelectMode.BARRACK_RALLY
			select_menu.hide_select_menu.emit()
			
		#C.SelectMenuButtonType.BUY:
		#C.SelectMenuButtonType.SKILL:
		#C.SelectMenuButtonType.AIM:
		#C.SelectMenuButtonType.SWITCH:
