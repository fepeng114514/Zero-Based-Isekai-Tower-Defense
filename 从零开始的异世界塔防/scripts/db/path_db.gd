extends Node

var paths: Array[Path] = []
var last_pi: int = 0
var max_subpath: int = 3
var subpath_spacing: int = 25
var node_count: int = 198

func clean():
	paths = []

func get_path_count() -> int:
	return paths.size()

func get_pathway(pi: int) -> Path:
	return paths[pi]

func get_subpath(pi: int, spi: int) -> Subpath:
	var path: Path = paths[pi]
	var subpath: Subpath = path.subpaths[spi]
	return subpath

func get_path_node(pi: int, spi: int, ni: int) -> PathNode:
	var path: Path = paths[pi]
	var subpath: Subpath = path.subpaths[spi]
	var node: PathNode = subpath.nodes[ni]

	return node
	
func get_middle_spi() -> int:
	return roundi(1.0 * max_subpath / 2)

func get_active_paths() -> Array[Path]:
	return paths.filter(func(p: Path): return p.active)

func get_random_path() -> Path:
	return get_active_paths().pick_random()

func get_random_pi() -> int:
	return randi_range(0, get_path_count() - 1)

func get_random_subpath(pi = null) -> Subpath:
	if not pi:
		pi = get_random_pi()
	else:
		push_warning("路径 %s 已被禁用" % pi)
		return null

	var path: Path = paths[pi]

	return path.subpaths.pick_random()

func get_ratio(pi: int, spi: int, progress: float) -> float:
	var subpath: Subpath = get_subpath(pi, spi)
		
	var delta = progress / subpath.length
	return clampf(delta, 0, 1)
	
func get_ratio_pos(pi: int, spi: int, ratio: float) -> Vector2:
	var subpath: Subpath = get_subpath(pi, spi)
	var path_follow = subpath.follow
		
	path_follow.progress_ratio = ratio
	var position: Vector2 = path_follow.position
	
	return subpath.to_global(position)

func get_progress_by_ratio(pi: int, spi: int, ratio: float) -> float:
	var subpath: Subpath = get_subpath(pi, spi)

	return subpath.length * ratio
	
func get_progress_pos(pi: int, spi: int, progress: float) -> Vector2:
	var subpath: Subpath = get_subpath(pi, spi)
	var path_follow = subpath.follow
		
	path_follow.progress = progress
	var position: Vector2 = path_follow.position
	
	return subpath.to_global(position)
	
func predict_target_pos(target: Entity, walk_time: float) -> Vector2:
	if not target.has_c(CS.CN_NAV_PATH) or target.state & (CS.STATE_MELEE | CS.STATE_RANGED):
		return target.position
		
	var nav_path_c: NavPathComponent = target.get_c(CS.CN_NAV_PATH)
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
		pi_l: Array = range(get_path_count()), 
		spi_l: Array = range(max_subpath),
		valid_only: bool = true
	) -> Array[PathNode]:
	var nodes: Array[PathNode] = []

	for pi: int in pi_l:
		if valid_only and not get_pathway(pi).is_active():
			push_warning("get_nearst_point: 路径 %s 已被禁用" % pi)
			continue

		for spi: int in spi_l:
			var subpath: Subpath = get_subpath(pi, spi)

			for node: PathNode in subpath.nodes:
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
		pi_l: Array = range(get_path_count()), 
		spi_l: Array = range(max_subpath),
		valid_only: bool = true
	) -> PathNode:
	var nearst_node = null
	
	for pi: int in pi_l:
		if valid_only and not get_pathway(pi).is_active():
			continue
		
		for spi: int in spi_l:
			var subpath: Subpath = get_subpath(pi, spi)
			
			for node: PathNode in subpath.nodes:
				node.dist_squared = node.pos.distance_squared_to(origin)
				
				if (
						not nearst_node
						or node.dist_squared 
						< nearst_node.dist_squared
				):
					nearst_node = node

	return nearst_node
