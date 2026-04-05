@tool
extends Node
class_name SystemController
## 系统列表类


var list: Array[System] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	for child: System in get_children():
		list.append(child)
		
	SystemMgr.load(list)
