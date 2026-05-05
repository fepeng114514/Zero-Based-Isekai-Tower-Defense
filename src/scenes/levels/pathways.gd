@tool
extends Control
## 路径管理器
##
## 管理路径子节点 [Pathway]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	var all_node_list: Array[PathwayNode] = PathwayMgr.all_node_list
	var all_node_list_size: int = all_node_list.size()
				
	# 处理路径相交
	for i: int in all_node_list_size:
		if i >= all_node_list_size - 1:
			continue
		
		var n: PathwayNode = all_node_list[i]
		var n_pi: int = n.pi
		
		for j: int in range(i + 1, all_node_list_size + 1):
			if j >= all_node_list_size:
				continue
			
			var other_n: PathwayNode = all_node_list[j]
			var other_n_pi: int = other_n.pi
			
			if other_n_pi == n_pi:
				continue
			
			if n.pos.distance_to(other_n.pos) > PathwayMgr.intersect_dist_threshold:
				continue
				
			n.intersecting_ni_list.append(other_n.ni)
			other_n.intersecting_ni_list.append(n.ni)


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 Pathway 子节点，否则所有路径相关的操作会出错。"]
		
	return []
