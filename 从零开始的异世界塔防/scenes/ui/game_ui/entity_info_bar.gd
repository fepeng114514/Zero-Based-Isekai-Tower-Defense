extends PanelContainer

@export_group("SceneRef")
## 攻击范围场景引用
@export var range_circle: PackedScene = null
## 拦截范围场景引用
@export var melee_range_circle: PackedScene = null
## 集结范围场景引用
@export var rally_circle: PackedScene = null
## 移动路径的连线场景引用
@export var rally_line: PackedScene = null

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
	S.deselect_entity.connect(_hidden)
	visible = false


func _process(_delta: float) -> void:
	if not U.is_vaild_entity(selected_entity):
		_hidden()
		return
	
	if info_bar_type == C.InfoBarType.NONE:
		return
		
	_update_info()
	
	
## 显示信息栏
func _show(e: Entity) -> void:
	if e == selected_entity:
		return
		
	_hidden()
	
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
	
	if e.has_c(C.CN_RANGED):
		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
		var first_ranged_attack: RangedAttack = ranged_c.list[0]
		var max_range: float = first_ranged_attack.max_range
		var min_range: float = first_ranged_attack.min_range
		
		_create_range_circle("MaxRangeCircle", max_range)
		
		if min_range != 0:
			_create_range_circle("MinRangeCircle", min_range)

	if e.has_c(C.CN_MELEE):
		var melee_c: MeleeComponent = e.get_c(C.CN_MELEE)
		if melee_c.is_blocker:
			var max_melee_range: float = melee_c.block_max_range
			var min_melee_range: float = melee_c.block_min_range
			
			_create_melee_range_circle("MaxMeleeRangeCircle", max_melee_range)

			if min_melee_range != 0:
				_create_melee_range_circle("MinMeleeRangeCircle", min_melee_range)

	if e.has_c(C.CN_TOWER):
		var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
		
		if not tower_c.list.is_empty():
			var first_entity: Entity = tower_c.list[0]
			var ranged_c: RangedComponent = first_entity.get_c(C.CN_RANGED)
			var first_ranged_attack: RangedAttack = ranged_c.list[0]
			var max_range: float = first_ranged_attack.max_range
			var min_range: float = first_ranged_attack.min_range
			
			_create_range_circle("MaxRangeCircle", max_range)
			
			if min_range != 0:
				_create_range_circle("MinRangeCircle", min_range)
			
	if e.has_c(C.CN_RALLY):
		var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
		var line: Line2D = rally_line.instantiate()
		line.name = "RallyLine"
		line.points = rally_c.get_current_navigation_path()
		e.add_child(line)

	if e.has_c(C.CN_BARRACK):
		var barrack_c: BarrackComponent = e.get_c(C.CN_BARRACK)
		_create_melee_range_circle("RallyCircle", barrack_c.rally_range)
	
	_update_info()

	
## 隐藏信息栏
func _hidden() -> void:
	visible = false
	
	if not U.is_vaild_entity(selected_entity):
		return
		
	if selected_entity.has_c(C.CN_RANGED) or selected_entity.has_c(C.CN_TOWER):
		var max_circle: Node2D = selected_entity.get_node_or_null("MaxRangeCircle")
		if max_circle:
			max_circle.remove()

		var min_circle: Node2D = selected_entity.get_node_or_null("MinRangeCircle")
		if min_circle:
			min_circle.remove()

	if selected_entity.has_c(C.CN_MELEE):
		var melee_c: MeleeComponent = selected_entity.get_c(C.CN_MELEE)
		if melee_c.is_blocker:
			var max_melee_circle: Node2D = selected_entity.get_node_or_null("MaxMeleeRangeCircle")
			if max_melee_circle:
				max_melee_circle.remove()

			var min_melee_circle: Node2D = selected_entity.get_node_or_null("MinMeleeRangeCircle")
			if min_melee_circle:
				min_melee_circle.remove()

	if selected_entity.has_c(C.CN_RALLY):
		var rally_line_node: Line2D = selected_entity.get_node_or_null("RallyLine")
		if rally_line_node:
			rally_line_node.queue_free()

	if selected_entity.has_c(C.CN_BARRACK):
		var rally_circle_node: Node2D = selected_entity.get_node_or_null("RallyCircle")
		if rally_circle_node:
			rally_circle_node.remove()
		
	selected_entity = null


## 更新信息
func _update_info() -> void:
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


## 创建范围环
func _create_range_circle(node_name: String, r: float) -> void:
	var circle: Node2D = range_circle.instantiate()
	circle.name = node_name

	var s: float = r / 200
	circle.scale = Vector2(0, 0)
	
	circle.tween_set_scale(Vector2(s, s))
	
	var new_position := Vector2.ZERO
	
	if selected_entity.has_c(C.CN_TOWER):
		var tower_c: TowerComponent = selected_entity.get_c(C.CN_TOWER)
		new_position = tower_c.position + tower_c.show_range_offset
	elif selected_entity.has_c(C.CN_RANGED):
		var ranged_c: RangedComponent = selected_entity.get_c(C.CN_RANGED)
		new_position = ranged_c.position
		
	circle.position = new_position
	selected_entity.add_child(circle)

## 创建拦截范围环
func _create_melee_range_circle(node_name: String, r: float) -> void:
	var circle: Node2D = melee_range_circle.instantiate()
	circle.name = node_name

	var s: float = r / 200
	circle.scale = Vector2(0, 0)
	
	circle.tween_set_scale(Vector2(s, s))
	
	selected_entity.add_child(circle)


## 更新单位信息
func _update_unit_info() -> void:
	var health_c: HealthComponent = selected_entity.get_c(C.CN_HEALTH)
	hp_value.text = "%d/%d" % [health_c.hp_max, health_c.hp]
	phys_armor_value.text = "%d" % health_c.physical_armor
	magic_armor_value.text = "%d" % health_c.magical_armor
	
	if selected_entity.has_c(C.CN_MELEE):
		_set_value_melee(selected_entity)
	else:
		melee_value.text = "无"
		
	if selected_entity.has_c(C.CN_RANGED):
		_set_value_ranged(selected_entity)
	else:
		ranged_value.text = "无"


## 更新防御塔信息
func _update_tower_info() -> void:
	var tower_c: TowerComponent = selected_entity.get_c(C.CN_TOWER)

	if tower_c.list.is_empty():
		if selected_entity.has_c(C.CN_RANGED):
			_set_value_ranged(selected_entity)
		else:
			ranged_value.text = "无"
		return
	else:
		var first_entity: Entity = tower_c.list[0]
		_set_value_ranged(first_entity)


## 设置远程攻击值
func _set_value_ranged(e: Entity) -> void:
	var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
	var first_ranged_attack: RangedAttack = ranged_c.list[0]
	var bullet: Entity = EntityDB.get_entity_data(first_ranged_attack.bullet)
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
