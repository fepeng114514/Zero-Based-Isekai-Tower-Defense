extends Node
class_name BuyComponent
## 购买组件 Todo 待完善
##
## BuyComponent 用于与 [UIComponent] 配合使用，
## 使实体可以在被选择时点击 [annotation SelectMenuItemData.type]
## 为 BUY 的项时购买某些条目


@export var list: Array[BuyItem] = []


## 自动更新列表
func _update_list() -> void:
	var new_list: Array[BuyItem] = []
	
	for child: BuyItem in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()


## 当节点树变化时自动更新
func _notification(what: int) -> void:
	EditorUtils.tool_on_tree_call(self, what, _update_list)
