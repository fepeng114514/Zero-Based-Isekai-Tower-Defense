extends PanelContainer

@export_group("NodeRef")
@export var entity_name: Label = null
@export var hp_label: Label = null
@export var hp_value: Label = null
@export var melee_type_icon: TextureRect = null
@export var melee_value: Label = null
@export var ranged_type_icon: TextureRect = null
@export var ranged_value: Label = null
@export var phys_armor_icon: TextureRect = null
@export var phys_armor_value: Label = null
@export var magic_armor_icon: TextureRect = null
@export var magic_armor_value: Label = null

## 当前选择的实体
var selected_entity: Entity = null
## 显示类型
var info_bar_type: C.InfoBarType = C.InfoBarType.UNIT

## 信息栏对应信息类型显示配置
@onready var show_config: Dictionary[C.InfoBarType, Dictionary] = {
	C.InfoBarType.UNIT: {
		"hp_label": true,
		"hp_value": true,
		"melee_type_icon": true,
		"melee_value": true,
		"ranged_type_icon": true,
		"ranged_value": true,
		"phys_armor_icon": true,
		"phys_armor_value": true,
		"magic_armor_icon": true,
		"magic_armor_value": true,
	},
	C.InfoBarType.TOWER: {
		"hp_label": false,
		"hp_value": false,
		"melee_type_icon": false,
		"melee_value": false,
		"ranged_type_icon": true,
		"ranged_value": true,
		"phys_armor_icon": false,
		"phys_armor_value": false,
		"magic_armor_icon": false,
		"magic_armor_value": false,
	}
}


func _ready() -> void:
	S.select_entity.connect(_show)
	S.deselect_entity.connect(_hide)
	visible = false


func _process(_delta: float) -> void:
	if not U.is_vaild_entity(selected_entity):
		_hide()
		return
	
	if info_bar_type == C.InfoBarType.NONE:
		return
		
	entity_name.text = selected_entity.name
	
	var current_configs: Dictionary = show_config[info_bar_type]
	for control_name: String in current_configs:
		var control: Control = get(control_name)
		var is_hidden: bool = current_configs[control_name]
		control.visible = is_hidden

	match info_bar_type:
		C.InfoBarType.UNIT:
			_update_unit_info()
		C.InfoBarType.TOWER:
			if selected_entity.has_c(C.CN_TOWER):
				_update_tower_info()
	
	
## 显示信息栏
func _show(e: Entity) -> void:
	if e == selected_entity:
		return
		
	_hide()
	
	var ui_c: UIComponent = e.get_c(C.CN_UI)
	if not ui_c:
		return
	
	if not ui_c.can_select:
		return
		
	selected_entity = e
	info_bar_type = ui_c.info_bar_type
	
	if info_bar_type == C.InfoBarType.NONE:
		return
		
	visible = true

	
## 隐藏信息栏
func _hide() -> void:
	visible = false
	selected_entity = null


## 更新单位信息
func _update_unit_info() -> void:
	var health_c: HealthComponent = selected_entity.get_c(C.CN_HEALTH)
	hp_value.text = "%d/%d" % [health_c.hp_max, health_c.hp]
	phys_armor_value.text = "%d" % health_c.physical_armor
	magic_armor_value.text = "%d" % health_c.magical_armor
	
	if selected_entity.has_c(C.CN_MELEE):
		_set_value_melee(selected_entity)
	else:
		melee_value.visible = false
		melee_type_icon.visible = false
		
	if selected_entity.has_c(C.CN_RANGED):
		_set_value_ranged(selected_entity)
	else:
		ranged_value.visible = false
		ranged_type_icon.visible = false


## 更新防御塔信息
func _update_tower_info() -> void:
	var tower_c: TowerComponent = selected_entity.get_c(C.CN_TOWER)

	if tower_c.list.is_empty():
		if selected_entity.has_c(C.CN_RANGED):
			_set_value_ranged(selected_entity)
		else:
			ranged_type_icon.visible = false
			ranged_value.visible = false
	else:
		var first_entity: Entity = tower_c.list[0]
		_set_value_ranged(first_entity)


## 设置远程攻击值
func _set_value_ranged(e: Entity) -> void:
	var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	var first_ranged_attack: RangedAttack = ranged_c.list[0]
	var bullet: Entity = EntityMgr.get_entity_data(first_ranged_attack.bullet)
	var bullet_c: BulletComponent = bullet.get_c(C.CN_BULLET)
	ranged_value.text = "%d-%d/%.1f" % [
		bullet_c.damage_min, 
		bullet_c.damage_max, 
		first_ranged_attack.cooldown
	]
	
	
## 设置近战攻击值
func _set_value_melee(e: Entity) -> void:
	var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
	var first_melee_attack: MeleeAttack = melee_c.list[0]
	melee_value.text = "%d-%d/%.1f" % [
		first_melee_attack.damage_min, 
		first_melee_attack.damage_max, 
		first_melee_attack.cooldown
	]
