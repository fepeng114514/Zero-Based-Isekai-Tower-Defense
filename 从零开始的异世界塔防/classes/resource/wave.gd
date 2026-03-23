extends Resource
class_name Wave
## 波次资源


## 波次间隔，单位为秒
@export var interval: float = 30
## 出怪批次列表
@export var spawn_batch_list: Array[WaveSpawnBatch] = []
