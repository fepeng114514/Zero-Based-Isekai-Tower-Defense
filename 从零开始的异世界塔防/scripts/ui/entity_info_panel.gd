extends PanelContainer
var showed_entity: Variant = null
var info_type: StringName = C.INFO_COMMON
@onready var hp_value_label: Label = (
	$MarginContainer/VBoxContainer/HBox_HP/Value_HP
)
@onready var entity_name_label: Label = (
	$MarginContainer/VBoxContainer/EntityName
)


func _ready() -> void:
	S.select_entity_s.connect(_show)
	S.deselect_entity_s.connect(_hidden)


func _process(delta: float) -> void:
	_update(delta)
	
	
func _update(delta: float) -> void:
	var e: Variant = showed_entity
	
	if not e:
		return
	
	if info_type == C.INFO_COMMON:
		entity_name_label.text = e.template_name
		
		var health_c: HealthComponent = e.get_c(C.CN_HEALTH)
		
		hp_value_label.text = "%d/%d" % [health_c.hp_max, health_c.hp]
	

func _show(e: Entity) -> void:
	if not e.has_c(C.CN_UI):
		return
		
	var ui_c: UIComponent = e.get_c(C.CN_UI)
	
	if not ui_c.can_click:
		return
		
	visible = true
	showed_entity = e
	info_type = ui_c.info_type
	
func _hidden() -> void:
	visible = false
	showed_entity = null
