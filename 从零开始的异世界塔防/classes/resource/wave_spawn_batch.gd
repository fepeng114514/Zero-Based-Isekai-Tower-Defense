extends Resource

## 生成批次资源，存储敌人生成
class_name WaveSpawnBatch


## 生成路径
@export var pathway_idx: int = 0
## 批次延迟，单位为秒，因为所有批次都是并发的所以使用延迟控制
@export var delay: float = 0
## 敌人生成列表
@export var spawns: Array[WaveSpawn] = []
