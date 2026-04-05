@tool
extends Node2D
class_name RangedComponent

## 是否禁用索敌
@export var disabled_search: bool = false

## 远程攻击列表
var list: Array[RangedAttack] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	for child: RangedAttack in get_children():
		list.append(child)
