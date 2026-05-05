extends Behavior
class_name BarrackBehavior
## 兵营行为系统
##
## 处理拥有 [BarrackComponent] 兵营组件的实体生成士兵


func _on_remove(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if not barrack_c:
		return true
	
	var soldier_group: EntityGroup = barrack_c.soldier_group
	for soldier: Entity in soldier_group.get_children():
		soldier.remove_entity()
		
	return true


func _on_update(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if not barrack_c:
		return false
		
	var soldier_group: EntityGroup = barrack_c.soldier_group
	var max_soldiers: int = barrack_c.max_soldiers
		
	if e.is_first_update:
		e.play_animation_by_look(barrack_c.animation)
		AudioMgr.play_sfx(barrack_c.sfx)
		if barrack_c.delay:
			await e.y_wait(barrack_c.delay)
			
		for i: int in max_soldiers:
			_respawn_soldier(e, barrack_c, soldier_group)
			
	var soldier_count: int = soldier_group.get_child_count()
	
	# 根据重生时间生成士兵
	if TimeMgr.is_ready_time(barrack_c.ts, barrack_c.respawn_time):
		if soldier_count < max_soldiers:
			_respawn_soldier(e, barrack_c, soldier_group)
		barrack_c.ts = TimeMgr.tick_ts
	
	# 士兵数发生变化重新整队
	if barrack_c.last_soldier_count != soldier_count:
		barrack_c.new_rally_center_position(barrack_c.rally_center_position)
	
	barrack_c.last_soldier_count = soldier_count
	return false


func _respawn_soldier(
		barrack: Entity, barrack_c: BarrackComponent, soldier_group: EntityGroup
	) -> Entity:
	var soldier: Entity = EntityMgr.create_entity(barrack_c.soldier)
	soldier.global_position = barrack.global_position + barrack_c.respawn_offset
	
	if not barrack._on_barrack_respawn(soldier, barrack_c):
		return soldier
	
	soldier_group.add_child(soldier)
	soldier.insert_entity()
	
	return soldier
