@tool
extends Control


func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 MeleeBase 节点或其类型的节点，否则实体无法攻击。")
		
	return warn
