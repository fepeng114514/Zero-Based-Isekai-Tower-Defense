extends System
class_name TowerSystem
## 防御塔系统
##
## 处理拥有 [TowerComponent] 防御塔组件的实体


func _on_insert(e: Entity) -> bool:
	var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
	
	if not tower_c:
		return true
		
	for sub_e: Entity in tower_c.list:
		sub_e.is_subentity = true
		sub_e.source_id = e.id
		EntityMgr.process_create(sub_e)
		sub_e.insert_entity()
		
	if not tower_c.tower_holder_style:
		tower_c.tower_holder_style = GameMgr.defaul_tower_holder_style
		
	if tower_c.tower_type == C.TowerType.TOWER_HOLDE:
		tower_c.total_price = 0
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_entities_group(C.CN_TOWER):
		var tower_c: TowerComponent = e.get_c(C.CN_TOWER)
		
		# 处理防御塔升级
		if tower_c.upgrade_to:
			var new_tower: Entity = EntityMgr.create_entity(tower_c.upgrade_to)
			var new_tower_c: TowerComponent = new_tower.get_c(C.CN_TOWER)
			
			var price: float = new_tower_c.price
			
			new_tower.global_position = e.global_position
			new_tower_c.total_price = (
				tower_c.total_price + price
			)
			new_tower_c.tower_holder_style = tower_c.tower_holder_style
			
			new_tower.insert_entity()
			e.remove_entity()
			GameMgr.cash -= price
		if tower_c.is_sell:
			var tower_holder: Entity = EntityMgr.create_entity(
				"tower_holder"
			)
			var holder_tower_c: TowerComponent = tower_holder.get_c(C.CN_TOWER)
			tower_holder.global_position = e.global_position
			holder_tower_c.tower_holder_style = tower_c.tower_holder_style
			
			tower_holder.insert_entity()
			e.remove_entity()
			
			GameMgr.cash += (
				tower_c.sell_ratio * tower_c.total_price
			)
		
		# 处理防御塔更新
		tower_c.cleanup_list()
		
		var list: Array[Entity] = tower_c.list
		
		if not list:
			continue
			
		if tower_c.attack_loop_time == 0:
			continue
			
		if not TimeMgr.is_ready_time(tower_c.ts, tower_c.attack_loop_time):
			continue
			
		tower_c.attack_entity_idx += 1
		if tower_c.attack_entity_idx >= list.size():
			tower_c.attack_entity_idx = 0
			
		var curren_e: Entity = list[tower_c.attack_entity_idx]
		for sub_e: Entity in list:
			if sub_e != curren_e:
				sub_e.blocking = true
				continue
				
			sub_e.blocking = false
			
		tower_c.ts = TimeMgr.tick_ts
		
