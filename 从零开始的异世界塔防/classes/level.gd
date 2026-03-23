extends Node2D
class_name Level
## 关卡类


## 准备阶段播放的音乐数据
@export var ready_music: AudioData = null
## 战斗阶段播放的音乐数据
@export var battle_music: AudioData = null
## 默认金币
@export var cash: int = 200
## 默认生命
@export var life: int = 20

func _ready() -> void:
	if ready_music:
		AudioMgr.play_music(ready_music)
	
