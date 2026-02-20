extends Resource
class_name PathwayNode

## 路径索引
var pi: int = -1
## 子路径索引
var spi: int = -1
## 路径节点索引
var ni: int = -1
## 点位
var pos: Vector2 = Vector2.ZERO
## 位于的路径比率
var ratio: float = 0
## 位于的路径位置
var progress: float = 0
## 距离，特殊用途
var dist_squared: float = 0

func _init(
		new_pi: int,
		new_spi: int,
		new_ni: int,
		new_pos: Vector2,
		new_ratio: float,
		new_progress: float,
	) -> void:
	pi = new_pi
	spi = new_spi
	ni = new_ni
	pos = new_pos
	ratio = new_ratio
	progress = new_progress

## PathDB.get_subpath 的简写，已传递 pi, spi
func get_subpath() -> Path2D:
	return PathDB.get_subpath(pi, spi)

## PathDB.get_ratio 的简写，已传递 pi, spi
func get_ratio(pro: float = progress) -> float:
	return PathDB.get_ratio(pi, spi, pro)
	
## PathDB.get_ratio_pos 的简写，已传递 pi, spi
func get_ratio_pos(r: float = ratio) -> Vector2:
	return PathDB.get_ratio_pos(pi, spi, r)
	
## PathDB.get_progress_pos 的简写，已传递 pi, spi
func get_progress_pos(pro: float = progress) -> Vector2:
	return PathDB.get_progress_pos(pi, spi, pro)

## PathDB.get_progress_by_ratio 的简写，已传递 pi, spi
func get_progress_by_ratio(r: float = ratio) -> float:
	return PathDB.get_progress_by_ratio(pi, spi, r)

## PathDB.get_pathway_node 的简写，已传递 nav_pi, nav_spi
func get_pathway_node(node_idx: int = ni) -> PathwayNode:
	return PathDB.get_pathway_node(pi, spi, node_idx)
