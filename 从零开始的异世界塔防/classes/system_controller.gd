extends Node
class_name SystemController
## 系统列表类


func _ready() -> void:
	var list: Array[System] = []

	for child: System in get_children():
		list.append(child)
		
	SystemMgr.load(list)
