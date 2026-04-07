extends Node
## 关卡管理器
##
## 管理关卡


## 进入指定索引的关卡
func enter_level(idx: int) -> void:
	GameMgr.level_idx = idx
	
	EntityMgr.load()
	PathwayMgr.load()
	GridMgr.load()

	get_tree().change_scene_to_file(
		"res://scenes/levels/level_%d.tscn" % idx
	)
