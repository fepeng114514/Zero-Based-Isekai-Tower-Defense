extends Node
## 游戏管理器
##
## 管理游戏中的数据


## 关卡索引
var level_idx: int = 1
## 强制当前波次为指定波次
var force_wave: int = 0
## 当前波次
var current_wave: int = 0
## 波次是否释放完毕
var waves_finished: bool = false
## 金币
var cash: float = 0:
	set(value):
		S.set_cash.emit(value)
		cash = value
## 生命
var life: int = 20:
	set(value):
		S.set_life.emit(value)
		life = value
## 默认塔位样式
var defaul_tower_holder_style: C.TowerHolderStyle = C.TowerHolderStyle.GRASS