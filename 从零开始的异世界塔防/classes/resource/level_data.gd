extends Node

## 关卡数据类，定义关卡初始资源与进入场景创建的实体
class_name LevelData


@export var life: int = 20
@export var cash: int = 600
@export var entities: Array[Dictionary] = []
