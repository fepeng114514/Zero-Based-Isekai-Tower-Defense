extends Node
class_name BuyComponent
## 购买组件 Todo 待完善
##
## BuyComponent 用于与 [UIComponent] 配合使用，
## 使实体可以在被选择时点击 [annotation SelectMenuItemData.type]
## 为 BUY 的项时购买某些条目


var list: Array[BuyItem] = []


func _ready() -> void:
	for child: BuyItem in get_children():
		list.append(child)
