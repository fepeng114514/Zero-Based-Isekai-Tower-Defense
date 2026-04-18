extends Behavior
class_name BarrackBehavior
## 兵营行为系统
##
## 处理拥有 [BarrackComponent] 兵营组件的实体生成士兵
	
	
func _on_remove(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_child_node(C.CN_BARRACK)
	if not barrack_c:
		return true
		
	barrack_c.cleanup_soldiers()
	
	var soldiers_list: Array = barrack_c.soldiers_list
	for soldier: Entity in soldiers_list:
		soldier.remove_entity()
		
	return true
	

func _on_update(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_child_node(C.CN_BARRACK)
	if not barrack_c:
		return false
		
	if e.is_first_update:
		e.play_animation_by_look(barrack_c.animation)
		AudioMgr.play_sfx(barrack_c.sfx)
		if barrack_c.delay:
			await e.y_wait(barrack_c.delay)
			
		var max_soldiers: int = barrack_c.max_soldiers
			
		for i: int in max_soldiers:
			var soldier: Entity = respawn_soldier(e, barrack_c)
			var s_rally_c: RallyComponent = soldier.get_child_node(C.CN_RALLY)
			s_rally_c.rally_formation_position(max_soldiers, i)
		
	barrack_c.cleanup_soldiers()
	
	var soldiers_list: Array = barrack_c.soldiers_list
	var soldier_count: int = soldiers_list.size()
	
	# 根据重生时间生成士兵
	if TimeMgr.is_ready_time(barrack_c.ts, barrack_c.respawn_time):
		respawn_soldier(e, barrack_c)
		barrack_c.ts = TimeMgr.tick_ts
	
	# 士兵数发生变化重新整队
	if barrack_c.last_soldier_count != soldier_count:
		for i: int in soldier_count:
			var soldier: Entity = soldiers_list[i]
			var s_rally_c: RallyComponent = soldier.get_child_node(C.CN_RALLY)
			s_rally_c.rally_formation_position(soldier_count, i)
	
	barrack_c.last_soldier_count = soldier_count
	return false


func respawn_soldier(
		barrack: Entity, barrack_c: BarrackComponent
	) -> Variant:
	if barrack_c.soldiers_list.size() >= barrack_c.max_soldiers:
		return null
		
	var soldier: Entity = EntityMgr.create_entity(barrack_c.soldier)
	soldier.global_position = barrack.global_position
	
	var rally_c: RallyComponent = soldier.get_child_node(C.CN_RALLY)
	rally_c.new_rally(barrack_c.rally_pos, barrack_c.rally_radius)
		
	if not barrack._on_barrack_respawn(soldier, barrack_c):
		return soldier
	
	soldier.insert_entity()
	
	barrack_c.soldiers_list.append(soldier)
	
	return soldier
