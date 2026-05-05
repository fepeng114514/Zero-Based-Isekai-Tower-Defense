extends Node
## 游戏管理器
##
## 管理游戏中的数据


@warning_ignore_start("unused_signal")
## 设置金币信号
signal set_cash(new_value: float)
## 设置生命信号
signal set_life(new_value: float)
@warning_ignore_restore("unused_signal")


## 金币
var cash: float = 0:
	set(value):
		set_cash.emit(value)
		cash = value
## 生命
var life: int = 20:
	set(value):
		set_life.emit(value)
		life = value
## 默认塔位样式
var defaul_tower_holder_style: C.TowerHolderStyle = C.TowerHolderStyle.GRASS
