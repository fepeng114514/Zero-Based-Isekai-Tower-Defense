extends Node
## 路径数据库
##
## 存储所有路径与相关数据

## 路径列表
var pathway_list: Array[Pathway] = []
## 所有路径上的节点
var all_node_list: Array[PathwayNode] = []
## 下一个路径索引
var next_pi: int = 0
## 子路径总数量
var subpathway_count: int = 5
## 子路径间距
var subpathway_spacing: float = 20
## 路径节点总数量
var node_count: int = 256
## 路径节点相交距离阈值
var intersect_dist_threshold: float = 16


func load() -> void:
	pathway_list.clear()
	all_node_list.clear()
	next_pi = 0
	
	
func insert_pathway(p: Pathway) -> void:
	p.idx = next_pi
	next_pi += 1
	pathway_list.append(p)


## 获取路径数量
func get_pathway_count() -> int:
	return pathway_list.size()


## 获取指定索引的路径
func get_pathway(pi: int) -> Pathway:
	return pathway_list[pi]


## 获取指定索引的子路径
func get_subpathway(pi: int, spi: int) -> Subpathway:
	var pathway: Pathway = pathway_list[pi]
	var subpathway: Subpathway = pathway.subpathway_list[spi]
	return subpathway


## 获取指定索引的节点
func get_pathway_node(pi: int, spi: int, ni: int) -> PathwayNode:
	var pathway: Pathway = pathway_list[pi]
	var subpathway: Subpathway = pathway.subpathway_list[spi]
	var pathway_node: PathwayNode = subpathway.node_list[ni]

	return pathway_node
	

## 获取中间的子路径索引
func get_middle_spi() -> int:
	return roundi(1.0 * subpathway_count / 2)


## 获取启用的路径
func get_disabled_pathways() -> Array[Pathway]:
	return pathway_list.filter(func(p: Pathway): return p.disabled)


## 获取随机路径
func get_random_pathway() -> Pathway:
	return pathway_list.pick_random()


## 获取随机路径索引
func get_random_pi() -> int:
	return randi_range(0, get_pathway_count() - 1)


## 获取指定路径上的随机子路径
## 
## 若不指定路径索引将会在随机路径上获取
func get_random_subpathway(pi: int = C.UNSET) -> Subpathway:
	if not U.is_valid_number(pi):
		pi = get_random_pi()

	var pathway: Pathway = pathway_list[pi]

	return pathway.subpathway_list.pick_random()


## 根据路程获取路程比率
func get_ratio(pi: int, spi: int, progress: float) -> float:
	var subpathway: Subpathway = get_subpathway(pi, spi)
		
	var delta: float = progress / subpathway.length
	return clampf(delta, 0, 1)
	

## 获取指定路径比率上的位置
func get_ratio_pos(pi: int, spi: int, ratio: float) -> Vector2:
	var subpathway: Subpathway = get_subpathway(pi, spi)
	var path_follow: PathFollow2D = subpathway.follow
		
	path_follow.progress_ratio = ratio
	var global_position: Vector2 = path_follow.global_position
	
	return global_position


## 根据路程比率获取路程
func get_progress_by_ratio(pi: int, spi: int, ratio: float) -> float:
	var subpathway: Subpathway = get_subpathway(pi, spi)

	return subpathway.length * ratio
	

## 获取指定路程上的位置
func get_progress_pos(pi: int, spi: int, progress: float) -> Vector2:
	var subpathway: Subpathway = get_subpathway(pi, spi)
	var path_follow = subpathway.follow
		
	path_follow.progress = progress
	var global_position: Vector2 = path_follow.global_position
	
	return global_position
	

## 预判目标位置
func predict_target_pos(target: Entity, predict_time: float) -> Vector2:
	var predict_pos: Vector2 = target.global_position

	var nav_path_c: NavPathComponent = target.get_c(C.CN_NAV_PATH)
	if nav_path_c and target.state & C.State.NAV_PATH_WALK:
		var progress: float = nav_path_c.nav_progress
		var walk_lenth: float = nav_path_c.speed * predict_time
		
		if nav_path_c.reversed:
			progress -= walk_lenth
		else:
			progress += walk_lenth
	
		predict_pos = nav_path_c.get_progress_pos(
			progress
		)
	
	return predict_pos


## 获取指定路径上按距离排序的节点列表
##
## 可指定搜索的路径与子路径，不指定将会在所有路径搜索
func get_nearst_nodes_list(
		origin: Vector2, 
		pi_l: Array = range(get_pathway_count()), 
		spi_l: Array = range(subpathway_count),
		valid_only: bool = true
	) -> Array[PathwayNode]:
	var node_list: Array[PathwayNode] = []

	for pi: int in pi_l:
		if valid_only and not get_pathway(pi).is_disabled():
			Log.debug("路径 %s 已被禁用" % pi)
			continue

		for spi: int in spi_l:
			var subpathway: Subpathway = get_subpathway(pi, spi)

			for node: PathwayNode in subpathway.node_list:
				node.dist_squared = node.pos.distance_squared_to(origin)

				node_list.append(node)

	node_list.sort_custom(
		func(p1: Dictionary, p2: Dictionary): return (
			p1.dist_squared < p2.dist_squared
		)
	)
	return node_list
	

## 获取最近的路径上的一个节点
##
## 可指定搜索的路径、子路径，不指定将会在所有路径搜索
func get_nearst_node(
		origin: Vector2, 
		pi_l: Array = [], 
		spi_l: Array = [],
		valid_only: bool = true
	) -> PathwayNode:
	if not pi_l:
		pi_l = range(get_pathway_count())
	if not spi_l:
		spi_l = range(subpathway_count)

	var nearst_node: PathwayNode = null
	
	for pi: int in pi_l:
		if valid_only and not get_pathway(pi).is_disabled():
			continue
		
		for spi: int in spi_l:
			var subpathway: Subpathway = get_subpathway(pi, spi)
			
			for node: PathwayNode in subpathway.node_list:
				node.dist_squared = node.pos.distance_squared_to(origin)
				
				if (
						not nearst_node
						or node.dist_squared 
						< nearst_node.dist_squared
				):
					nearst_node = node

	return nearst_node
