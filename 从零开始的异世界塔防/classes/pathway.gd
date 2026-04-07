extends Path2D
class_name Pathway
## 路径类


## 是否禁用当前路径
@export var disabled: bool = true
## 子路径列表
var subpathway_list: Array[Subpathway] = []
## 下一个子路径索引
var next_spi: int = 0
## 路径索引
var idx: int = C.UNSET


func _ready() -> void:
	PathwayMgr.insert_pathway(self)
	
	var subpathway_count: int = PathwayMgr.subpathway_count
	var spacing: float = PathwayMgr.subpathway_spacing
	
	var half_total_spacing: float = subpathway_count * spacing / 2

	for i: int in range(subpathway_count):
		var subpathway := Subpathway.new()
		subpathway.spacing = half_total_spacing - (spacing * i)
		subpathway.parent_pathway = self
		subpathway.idx = next_spi
		add_child(subpathway)

		subpathway_list.append(subpathway)

		next_spi += 1
