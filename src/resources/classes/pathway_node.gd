extends Resource
class_name PathwayNode
## 路径节点资源


## 路径索引
var pi: int = C.UNSET
## 子路径索引
var spi: int = C.UNSET
## 路径节点索引
var ni: int = C.UNSET
## 节点位置
var pos := Vector2.ZERO
## 位于的路径比率
var ratio: float = 0
## 位于的路径位置
var progress: float = 0
## 距离
var dist_squared: float = 0
## 与另一个路径相交的节点索引
var intersecting_ni_list: Array[int] = []


## PathwayMgr.get_subpath 的简写，已传递 pi, spi
func get_subpath() -> Path2D:
	return PathwayMgr.get_subpath(pi, spi)


## PathwayMgr.get_ratio 的简写，已传递 pi, spi
func get_ratio(pro: float = progress) -> float:
	return PathwayMgr.get_ratio(pi, spi, pro)
	

## PathwayMgr.get_ratio_pos 的简写，已传递 pi, spi
func get_ratio_pos(r: float = ratio) -> Vector2:
	return PathwayMgr.get_ratio_pos(pi, spi, r)
	

## PathwayMgr.get_progress_pos 的简写，已传递 pi, spi
func get_progress_pos(pro: float = progress) -> Vector2:
	return PathwayMgr.get_progress_pos(pi, spi, pro)


## PathwayMgr.get_progress_by_ratio 的简写，已传递 pi, spi
func get_progress_by_ratio(r: float = ratio) -> float:
	return PathwayMgr.get_progress_by_ratio(pi, spi, r)


## PathwayMgr.get_pathway_node 的简写，已传递 nav_pi, nav_spi
func get_pathway_node(node_idx: int = ni) -> PathwayNode:
	return PathwayMgr.get_pathway_node(pi, spi, node_idx)
