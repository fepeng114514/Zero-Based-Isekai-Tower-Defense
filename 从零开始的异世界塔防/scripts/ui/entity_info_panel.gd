extends PanelContainer
var selected_entity: Variant = null
var info_type: StringName = C.INFO_COMMON
@export var hp_value_label: Label
@export var entity_name_label: Label


func _ready() -> void:
	S.select_entity_s.connect(_show)
	S.deselect_entity_s.connect(_hidden)
	
	visible = false


func _process(delta: float) -> void:
	_update(delta)
	
	
func _update(delta: float) -> void:
	if not selected_entity:
		return
		
	var e: Entity = selected_entity
	
	match info_type:
		C.INFO_COMMON:
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
	selected_entity = e
	info_type = ui_c.info_type
	
func _hidden() -> void:
	visible = false
	selected_entity = null
