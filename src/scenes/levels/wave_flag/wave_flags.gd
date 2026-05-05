@tool
extends Control


func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 WaveFlag 子节点，否则无法显示波次到来时间。")
		
	return warn
