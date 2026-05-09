extends Node
## 系统列表类


func _ready() -> void:
	var list: Array[System] = []

	for child: System in get_children():
		list.append(child)
		
	SystemMgr._load(list)
