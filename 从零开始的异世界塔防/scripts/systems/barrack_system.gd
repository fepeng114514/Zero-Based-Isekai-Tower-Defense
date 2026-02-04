extends System
class_name BarrackSystem

func on_insert(e: Entity) -> bool:
	if not e.has_c(CS.CN_BARRACK):
		return true
				
	var barrack_c: BarrackComponent = e.get_c(CS.CN_BARRACK)
	var max_soldiers: int = barrack_c.max_soldiers
		
	for i in range(max_soldiers):
		var soldier = respawn_soldier(e, barrack_c)
		
		var s_rally_c: RallyComponent = soldier.get_c(CS.CN_RALLY)
		s_rally_c.rally_formation_position(max_soldiers, i)
		
	return true
	
func on_update(delta: float) -> void:
	for e in EntityDB.entities:
		if not Utils.is_vaild_entity(e) or not e.has_c(CS.CN_BARRACK):
			continue
			
		var barrack_c: BarrackComponent = e.get_c(CS.CN_BARRACK)
		barrack_c.cleanup_soldiers()
		
		var soldiers_list: Array = barrack_c.soldiers_list
		var soldier_count: int = soldiers_list.size()
		
		# 根据重生时间生成士兵
		if TM.is_ready_time(barrack_c.ts, barrack_c.respawn_time):
			if respawn_soldier(e, barrack_c):
				barrack_c.ts = TM.tick_ts
		
		# 士兵数发生变化重新整队
		if barrack_c.last_soldier_count != soldier_count:
			for i in range(soldier_count):
				var soldier: Entity = soldiers_list[i]
				var s_rally_c: RallyComponent = soldier.get_c(CS.CN_RALLY)
		
				s_rally_c.rally_formation_position(soldier_count, i)
		
		barrack_c.last_soldier_count = soldier_count

func respawn_soldier(barrack: Entity, barrack_c: BarrackComponent):
	if barrack_c.soldiers_list.size() >= barrack_c.max_soldiers:
		return null
		
	var soldier: Entity = EntityDB.create_entity(barrack_c.soldier)
	soldier.position = barrack.position
	var rally_c: RallyComponent
	
	if not soldier.has_c(CS.CN_RALLY):
		rally_c = soldier.add_c(CS.CN_RALLY)
		rally_c.can_click_rally = false
		rally_c.rally_radius = barrack_c.rally_radius
		rally_c.speed = barrack_c.rally_speed
	else:
		rally_c = soldier.get_c(CS.CN_RALLY)
		
	rally_c.new_rally(barrack_c.rally_pos, barrack_c.rally_radius)
		
	if not barrack.on_respawn(barrack_c, soldier):
		return soldier
	
	EntityDB.insert_entity(soldier)
	
	barrack_c.soldiers_list.append(soldier)
	
	return soldier
