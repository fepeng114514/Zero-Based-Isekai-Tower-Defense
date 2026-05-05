extends Node
## 关卡管理器
##
## 管理关卡


## 关卡索引
var level_idx: int = 1


## 进入指定索引的关卡
func enter_level(idx: int) -> void:
	level_idx = idx
	
	AudioMgr.load()
	EntityMgr.load()
	PathwayMgr.load()
	GridMgr.load()

	get_tree().change_scene_to_file(
		"res://scenes/levels/level_%d.tscn" % idx
	)
