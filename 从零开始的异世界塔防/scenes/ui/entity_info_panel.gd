extends PanelContainer

@export var range_circle: PackedScene = null
@export var rally_circle: PackedScene = null
var selected_entity: Entity = null
var info_type: C.INFO = C.INFO.UNIT
@onready var entity_name: Label = $MarginContainer/HBoxContainer/EntityName
@onready var label_hp: Label = $MarginContainer/HBoxContainer/HBoxHP/LabelHP
@onready var value_hp: Label = $MarginContainer/HBoxContainer/HBoxHP/ValueHP
@onready var label_melee: Label = $MarginContainer/HBoxContainer/HBoxMelee/LabelMelee
@onready var value_melee: Label = $MarginContainer/HBoxContainer/HBoxMelee/ValueMelee
@onready var label_ranged: Label = $MarginContainer/HBoxContainer/HBoxRanged/LabelRanged
@onready var value_ranged: Label = $MarginContainer/HBoxContainer/HBoxRanged/ValueRanged
@onready var label_phys_armor: Label = $MarginContainer/HBoxContainer/HBoxPhysArmor/LabelPhysArmor
@onready var value_phys_armor: Label = $MarginContainer/HBoxContainer/HBoxPhysArmor/ValuePhysArmor
@onready var label_magic_armor: Label = $MarginContainer/HBoxContainer/HBoxMagicArmor/LabelMagicArmor
@onready var value_magic_armor: Label = $MarginContainer/HBoxContainer/HBoxMagicArmor/ValueMagicArmor
@onready var show_config: Dictionary[C.INFO, Array] = {
	C.INFO.UNIT: [
		[label_hp, true],
		[value_hp, true],
		[label_melee, true],
		[value_melee, true],
		[label_ranged, true],
		[value_ranged, true],
		[label_phys_armor, true],
		[value_phys_armor, true],
		[label_magic_armor, true],
		[value_magic_armor, true],
	],
	C.INFO.TOWER: [
		[label_hp, false],
		[value_hp, false],
		[label_melee, false],
		[value_melee, false],
		[label_ranged, true],
		[value_ranged, true],
		[label_phys_armor, false],
		[value_phys_armor, false],
		[label_magic_armor, false],
		[value_magic_armor, false],
	]
}

func _ready() -> void:
	S.select_entity_s.connect(_show)
	S.deselect_entity_s.connect(_hidden)
	visible = false


func _process(_delta: float) -> void:
	if not selected_entity:
		_hidden(selected_entity)
		return
		
	_update_info()
	
	
func _show(e: Entity) -> void:
	if e == selected_entity:
		return
		
	_hidden(e)
	
	var ui_c: UIComponent = e.get_c(C.CN_UI)
	if not ui_c:
		return
	
	if not ui_c.can_click:
		return
		
	visible = true
	selected_entity = e
	info_type = ui_c.info_type
	
	if e.has_c(C.CN_RANGED):
		var ranged_c: RangedComponent = e.get_c(C.CN_RANGED)
		var first_ranged_attack: RangedAttack = ranged_c.list[0]
		var max_range: float = first_ranged_attack.max_range
		var min_range: float = first_ranged_attack.min_range
		
		_create_range_circle("MaxRangeCircle", max_range)
		
		if min_range != 0:
			_create_range_circle("MinRangeCircle", min_range)
		
	if e.has_c(C.CN_TOWER):
		var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
		var first_subentity: Entity = tower_c.list[0]
		var ranged_c: RangedComponent = first_subentity.get_c(C.CN_RANGED)
		var first_ranged_attack: RangedAttack = ranged_c.list[0]
		var max_range: float = first_ranged_attack.max_range
		var min_range: float = first_ranged_attack.min_range
		
		_create_range_circle("MaxRangeCircle", max_range)
		
		if min_range != 0:
			_create_range_circle("MinRangeCircle", min_range)
	
	_update_info()

	
func _hidden(_e: Entity) -> void:
	visible = false
	
	if not selected_entity:
		return
		
	if selected_entity.has_c(C.CN_RANGED) or selected_entity.has_c(C.CN_TOWER):
		var max_circle: Node2D = selected_entity.get_node_or_null("MaxRangeCircle")
		if max_circle:
			max_circle.remove()

		var min_circle: Node2D = selected_entity.get_node_or_null("MinRangeCircle")
		if min_circle:
			min_circle.remove()
		
	selected_entity = null


func _update_info() -> void:
	entity_name.text = EntityDB.get_tag_name(selected_entity.tag)
	
	for config: Array in show_config[info_type]:
		var control: Control = config[0]
		var is_hidden: bool = config[1]
		control.visible = is_hidden

	match info_type:
		C.INFO.UNIT:
			_update_unit_info()
		C.INFO.TOWER:
			if selected_entity.has_c(C.CN_TOWER):
				_update_tower_info()


func _create_range_circle(node_name: String, r: float) -> void:
	var circle: Node2D = range_circle.instantiate()
	circle.name = node_name

	var s: float = r / 200
	circle.scale = Vector2(0, 0)
	
	circle.tween_set_scale(Vector2(s, s))
	
	selected_entity.add_child(circle)
	

func _update_unit_info() -> void:
	var health_c: HealthComponent = selected_entity.get_c(C.CN_HEALTH)
	value_hp.text = "%d/%d" % [health_c.hp_max, health_c.hp]
	value_phys_armor.text = "%d" % health_c.physical_armor
	value_magic_armor.text = "%d" % health_c.magical_armor
	
	if selected_entity.has_c(C.CN_MELEE):
		var melee_c: MeleeComponent = selected_entity.get_c(C.CN_MELEE)
		var first_melee_attack: MeleeAttack = melee_c.list[0]
		value_melee.text = "%d-%d/%.1f" % [
			first_melee_attack.min_damage, 
			first_melee_attack.max_damage, 
			first_melee_attack.cooldown
		]
	else:
		value_melee.text = "无"
		
	if selected_entity.has_c(C.CN_RANGED):
		var ranged_c: RangedComponent = selected_entity.get_c(C.CN_RANGED)
		var first_ranged_attack: RangedAttack = ranged_c.list[0]
		value_ranged.text = "%d-%d/%.1f" % [
			first_ranged_attack.min_damage, 
			first_ranged_attack.max_damage, 
			first_ranged_attack.cooldown
		]
	else:
		value_ranged.text = "无"


func _update_tower_info() -> void:
	var tower_c: TowerComponent = selected_entity.get_c(C.CN_TOWER)

	if tower_c.list.is_empty():
		value_ranged.text = "无"
		return

	var first_subentity: Entity = tower_c.list[0]
	var ranged_c: RangedComponent = first_subentity.get_c(
		C.CN_RANGED
	)
	var first_ranged_attack: RangedAttack = ranged_c.list[0]
	## todo: 每帧创建实体性能较差，后续需要优化
	var bullet: Entity = EntityDB.create_entity(
		first_ranged_attack.bullet, false
	)
	var bullet_c: BulletComponent = bullet.get_c(C.CN_BULLET)
	value_ranged.text = "%d-%d/%.1f" % [
		bullet_c.min_damage, 
		bullet_c.max_damage, 
		first_ranged_attack.cooldown
	]
