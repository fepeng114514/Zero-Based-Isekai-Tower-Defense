extends Node2D
class_name Level
## 关卡节点


## 初始金币
@export var cash: int = 200
## 初始生命
@export var life: int = 20
## 默认塔位样式
@export var defaul_tower_holder: StringName = &"tower_holder_grass"
## 地图大小
@export var world_size := Vector2(2560, 1440)

@export_group("Music")
## 准备阶段播放的音乐数据
@export var ready_music: AudioGroup = null
## 战斗阶段播放的音乐数据
@export var battle_music: AudioGroup = null


func _enter_tree() -> void:
	GlobalMgr.world_size = world_size
	
	WaveMgr.first_release_wave.connect(_on_first_release_wave)


func _ready() -> void:
	GameMgr.cash = cash
	GameMgr.life = life
	
	if ready_music:
		AudioMgr.play_music(ready_music)
	

func _on_first_release_wave() -> void:
	AudioMgr.play_music(battle_music)
