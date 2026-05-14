extends Control
class_name SelectMenuButton


@export var disabled_color: Color = Color(0.725, 0.725, 0.725)

@export_group("Ref")
@export var button: Button = null
@export var glow: TextureRect = null

var disabled: bool = false
## 选择菜单引用
var select_menu: SelectMenuController = null
## 选择的实体
var selected_entity: Entity = null


func _ready() -> void:
	button.pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	glow.visible = false
		
	_update()
		
		
func _process(_delta: float) -> void:
	_update()
		
		
func _update() -> void: pass

		
func _disable() -> void:
	disabled = true
	button.disabled = true
	modulate = disabled_color
	
	
func _enable() -> void:
	disabled = false
	button.disabled = false
	modulate = Color.WHITE

	
func _on_mouse_entered() -> void:
	if disabled:
		return
	
	glow.visible = true
	
	
func _on_mouse_exited() -> void:
	glow.visible = false
	
	
func _on_pressed() -> void: pass
