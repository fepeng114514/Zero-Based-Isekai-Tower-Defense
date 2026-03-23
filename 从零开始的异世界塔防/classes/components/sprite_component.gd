@tool
extends Node2D
class_name SpriteComponent

## 精灵组
@export var groups: Array[SpriteGroup] = []

## 精灵列表
@export_storage var list: Array[Node2D] = []

@export_group("Sync Animation")
## 是否所有者同步播放动画
@export var sync_source: bool = false
## 同步动画数据
@export var sync_animations: SyncAnimationsData = null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if list.is_empty():
		warnings.append("没有精灵子节点！ 请至少增加一个精灵子节点。")
	
	return warnings

## 自动更新列表
func _update_list() -> void:
	var new_list: Array[Node2D] = []
	
	for child: Node2D in get_children():
		new_list.append(child)
	
	# 只在变化时更新，避免无限循环
	if new_list != list:
		list = new_list
		notify_property_list_changed()  # 刷新编辑器

## 当节点树变化时自动更新
func _notification(what: int) -> void:
	U.tool_on_tree_call(self, what, _update_list)
