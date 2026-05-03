@tool
extends Node2D
class_name SpriteComponent

@export_group("Sync Animation")
## 是否所有者同步播放动画
@export var sync_source: bool = false
## 同步动画数据
@export var sync_animations: SyncAnimationsData = null


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 AnimatedSprite2D、Sprite2D、SpriteGroup 节点"]
		
	return []
