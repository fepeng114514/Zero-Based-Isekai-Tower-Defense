extends Node
## 关卡管理器
##
## 管理关卡


## 进入指定索引的关卡
func enter_level(idx: int) -> void:
	Store.level_idx = idx
	
	EntityDB.load()
	PathDB.load()
	GridDB.load()

	get_tree().change_scene_to_file(
		"res://scenes/levels/level_%d.tscn" % idx
	)
