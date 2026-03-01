extends PanelContainer
var selected_entity: Variant = null
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


func _process(delta: float) -> void:
	if not selected_entity:
		return
		
	_updata_info()
	
	
func _show(e: Entity) -> void:
	if not e.has_c(C.CN_UI):
		return
		
	var ui_c: UIComponent = e.get_c(C.CN_UI)
	
	if not ui_c.can_click:
		return
		
	visible = true
	selected_entity = e
	info_type = ui_c.info_type
	_updata_info()
	
func _hidden() -> void:
	visible = false
	selected_entity = null
	

func _updata_info() -> void:
	entity_name.text = EntityDB.get_templates_name(selected_entity.tag)
	
	for config: Array in show_config[info_type]:
		var control: Control = config[0]
		var is_hidden: bool = config[1]
		control.visible = is_hidden

	match info_type:
		C.INFO.UNIT:
			var health_c: HealthComponent = selected_entity.get_c(C.CN_HEALTH)
			value_hp.text = "%d/%d" % [health_c.hp_max, health_c.hp]
			value_phys_armor.text = "%d" % health_c.physical_armor
			value_magic_armor.text = "%d" % health_c.magical_armor
			
			if selected_entity.has_c(C.CN_MELEE):
				var melee_c: MeleeComponent = selected_entity.get(C.CN_MELEE)
				var first_melee_attack: Melee = melee_c.list[0]
				value_melee.text = "%d-%d/%d" % [
					first_melee_attack.min_damage, 
					first_melee_attack.max_damage, 
					first_melee_attack.cooldown
				]
			else:
				value_melee.text = "无"
				
			if selected_entity.has_c(C.CN_RANGED):
				var ranged_c: RangedComponent = selected_entity.get(C.CN_RANGED)
				var first_ranged_attack: Ranged = ranged_c.list[0]
				value_ranged.text = "%d-%d/%d" % [
					first_ranged_attack.min_damage, 
					first_ranged_attack.max_damage, 
					first_ranged_attack.cooldown
				]
			else:
				value_ranged.text = "无"
		#C.INFO.TOWER:
			
