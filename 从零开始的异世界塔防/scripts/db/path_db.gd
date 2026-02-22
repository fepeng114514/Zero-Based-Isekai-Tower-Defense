extends Node

"""
路径数据库，存储所有路径的数据
"""

var pathways: Array[Pathway] = []
var last_pi: int = 0
var max_subpathway: int = 3
var subpathway_spacing: float = 33.33
var node_count: int = 256


func load(level_data: Dictionary) -> void:
	pathways = []
	last_pi = 0
	max_subpathway = level_data.get("max_subpathway", max_subpathway)
	subpathway_spacing = level_data.get("subpathway_spacing", subpathway_spacing)
	node_count = level_data.get("node_count", node_count)


func get_pathway_count() -> int:
	return pathways.size()


func get_pathway(pi: int) -> Pathway:
	return pathways[pi]


func get_subpathway(pi: int, spi: int) -> Subpathway:
	var pathway: Pathway = pathways[pi]
	var subpathway: Subpathway = pathway.subpathways[spi]
	return subpathway


func get_pathway_node(pi: int, spi: int, ni: int) -> PathwayNode:
	var pathway: Pathway = pathways[pi]
	var subpathway: Subpathway = pathway.subpathways[spi]
	var node: PathwayNode = subpathway.nodes[ni]

	return node
	

func get_middle_spi() -> int:
	return roundi(1.0 * max_subpathway / 2)


func get_active_pathways() -> Array[Pathway]:
	return pathways.filter(func(p: Pathway): return p.active)


func get_random_path() -> Pathway:
	return get_active_pathways().pick_random()


func get_random_pi() -> int:
	return randi_range(0, get_pathway_count() - 1)


func get_random_subpathway(pi = null) -> Subpathway:
	if not pi:
		pi = get_random_pi()
	else:
		return null

	var pathway: Pathway = pathways[pi]

	return pathway.subpathways.pick_random()


func get_ratio(pi: int, spi: int, progress: float) -> float:
	var subpathway: Subpathway = get_subpathway(pi, spi)
		
	var delta = progress / subpathway.length
	return clampf(delta, 0, 1)
	

func get_ratio_pos(pi: int, spi: int, ratio: float) -> Vector2:
	var subpathway: Subpathway = get_subpathway(pi, spi)
	var path_follow = subpathway.follow
		
	path_follow.progress_ratio = ratio
	var position: Vector2 = path_follow.position
	
	return subpathway.to_global(position)


func get_progress_by_ratio(pi: int, spi: int, ratio: float) -> float:
	var subpathway: Subpathway = get_subpathway(pi, spi)

	return subpathway.length * ratio
	

func get_progress_pos(pi: int, spi: int, progress: float) -> Vector2:
	var subpathway: Subpathway = get_subpathway(pi, spi)
	var path_follow = subpathway.follow
		
	path_follow.progress = progress
	var position: Vector2 = path_follow.position
	
	return subpathway.to_global(position)
	

func predict_target_pos(target: Entity, walk_time: float) -> Vector2:
	if not target.has_c(C.CN_NAV_PATH) or target.state & (C.STATE_MELEE | C.STATE_RANGED):
		return target.position
		
	var nav_path_c: NavPathComponent = target.get_c(C.CN_NAV_PATH)
	var progress: float = nav_path_c.nav_progress
	var walk_lenth: float = nav_path_c.speed * walk_time
	
	if nav_path_c.reversed:
		progress -= walk_lenth
	else:
		progress += walk_lenth
	var predict_pos: Vector2 = nav_path_c.get_progress_pos(progress)
	
	return predict_pos


## 获取指定路径上按距离排序的所有节点
## [br]
## 可指定搜索的路径与子路径，不指定将会在所有路径搜索
func get_nearst_nodes_list(
		origin: Vector2, 
		pi_l: Array = range(get_pathway_count()), 
		spi_l: Array = range(max_subpathway),
		valid_only: bool = true
	) -> Array[PathwayNode]:
	var nodes: Array[PathwayNode] = []

	for pi: int in pi_l:
		if valid_only and not get_pathway(pi).is_active():
			print_debug("路径 %s 已被禁用" % pi)
			continue

		for spi: int in spi_l:
			var subpathway: Subpathway = get_subpathway(pi, spi)

			for node: PathwayNode in subpathway.nodes:
				node.dist_squared = node.pos.distance_squared_to(origin)

				nodes.append(node)

	nodes.sort_custom(
		func(p1: Dictionary, p2: Dictionary): return (
			p1.dist_squared < p2.dist_squared
		)
	)
	return nodes
	

## 获取最近的路径上的一个节点
## [br]
## 可指定搜索的路径、子路径，不指定将会在所有路径搜索
func get_nearst_node(
		origin: Vector2, 
		pi_l: Array = range(get_pathway_count()), 
		spi_l: Array = range(max_subpathway),
		valid_only: bool = true
	) -> PathwayNode:
	var nearst_node = null
	
	for pi: int in pi_l:
		if valid_only and not get_pathway(pi).is_active():
			continue
		
		for spi: int in spi_l:
			var subpathway: Subpathway = get_subpathway(pi, spi)
			
			for node: PathwayNode in subpathway.nodes:
				node.dist_squared = node.pos.distance_squared_to(origin)
				
				if (
						not nearst_node
						or node.dist_squared 
						< nearst_node.dist_squared
				):
					nearst_node = node

	return nearst_node
