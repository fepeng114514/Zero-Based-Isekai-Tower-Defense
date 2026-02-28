extends Resource

## 敌人生成资源，存储生成的敌人数据
class_name WaveSpawn


## 敌人标签
@export var entity_tag: C.ENTITY_TAG
## 每个敌人之间的间隔，单位为秒
@export var interval: float = 1
## 生成总数
@export var count: int = 10
## 生成的子路径，-1 表示随机 1~3
@export var subpathway_idx: int = -1
## 生成下一个敌人间隔，单位为秒
@export var next_interval: float = 1
## 敌人是否沿相反路径移动
@export var reversed: bool = false
## 敌人到达终点是否循环（原路返回）
@export var loop: bool = false
