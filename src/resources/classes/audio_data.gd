extends Resource
class_name AudioData
## 音频数据资源


## 播放模式
@export var play_mode: C.AudioPlayMode = C.AudioPlayMode.SEQUENCE
## 音频列表
@export var list: Array[StringName] = []
## 音量，单位为分贝
@export var volume_db: float = 0
## 音量，线性增长而非对数
@export var volume_linear: float = 1
## 延迟，单位为秒
@export var delay: float = 0

var played_idx: int = -1
