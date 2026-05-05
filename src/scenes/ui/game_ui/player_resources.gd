extends HBoxContainer


@export_group("NodeRef")
## 生命图标控件
@export var life_icon: TextureRect = null
## 生命值控件
@export var life_value: Label = null
## 金币图标控件
@export var cash_icon: TextureRect = null
## 金币值控件
@export var cash_value: Label = null


func _ready() -> void:
	GameMgr.set_cash.connect(_on_set_cash)
	GameMgr.set_life.connect(_on_set_life)


## 设置金币时调用的信号处理函数
func _on_set_cash(new_value: float) -> void:
	cash_value.text = "%d" % new_value
	
	
## 设置生命时调用的信号处理函数
func _on_set_life(new_value: float) -> void:
	life_value.text = "%d" % new_value
