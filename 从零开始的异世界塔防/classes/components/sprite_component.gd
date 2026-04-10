@tool
extends Node2D
class_name SpriteComponent

## 精灵组
@export var groups: Array[Array] = []

@export_group("Sync Animation")
## 是否所有者同步播放动画
@export var sync_source: bool = false
## 同步动画数据
@export var sync_animations: SyncAnimationsData = null

## 精灵列表
var list: Array[Node2D] = []


func _ready() -> void:
	for child: Node2D in get_children():
		list.append(child)
