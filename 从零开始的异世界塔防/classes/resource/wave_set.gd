extends Resource

## 波次集合资源，存储波次
## [br]
## 结构:
## [br]
## 1. 波次集合 (WaveSet) -> 2. 波次 (Wave) -> 
## [br]
## -> 3. 生成批次 (WaveSpawnBatch) -> 4. 敌人生成 (WaveSpawn)
## [br]
## 其中: 
## [br]
## 1. 波次集合 (WaveSet) 存储波次
## [br]
## 2. 波次 (Wave) 存储波次阶段
## [br]
## 3. 生成批次 (WaveSpawnBatch) 存储敌人生成，所有生成批次是并发的
## [br]
## 4. 敌人生成 (WaveSpawn) 存储生成数据，生成数量，敌人模板名等
class_name WaveSet


## 波次列表
@export var wave_list: Array[Wave] = []
