extends Entity

@onready var B: BulletComponent = $BulletComponent
var target
var min_damage_radius: int = 0
var max_damage_radius: int = 0
var stay_height: int = 0
var stay_time: float = 0
var to_predict_time: float = 0
var is_stay: bool = true
var is_to_predict: bool = true
var has_to_predict: bool = false
var has_init_fall: bool = false

func on_insert() -> bool:
	target = EntityDB.get_entity_by_id(target_id)
	
	if not is_instance_valid(target):
		return false
	
	B.to = target.position
	B.from = position
	
	var t_pos: Vector2 = target.position
	position = Vector2(t_pos.x, t_pos.y - stay_height)
	
	rotation = deg_to_rad(90)
	
	ts = TM.tick_ts
	return true

func on_update(delta: float) -> void:
	# 停留状态
	if is_instance_valid(target) and is_stay and not TM.is_ready_time(ts, stay_time):
		var t_pos: Vector2 = target.position
		position = Vector2(t_pos.x, t_pos.y - stay_height)
		B.to = position
		B.from = position
		return
	
	# 初始化预判位置
	if not has_to_predict:
		is_stay = false
		has_to_predict = true
		
		if is_instance_valid(target):
			B.predict_target_pos = PathDB.predict_target_pos(target, (B.flight_time + to_predict_time) * TM.fps)
		else:
			B.predict_target_pos = Vector2(B.to.x, B.to.y + stay_height)
		
		B.speed = Utils.initial_linear_speed(position, Vector2(B.predict_target_pos.x, B.predict_target_pos.y - stay_height), to_predict_time)
		ts = TM.tick_ts
		
	# 飞向预判位置
	if is_to_predict and not TM.is_ready_time(ts, to_predict_time):
		position = Utils.position_in_linear(B.speed, B.from, TM.tick_ts - ts)
		
		return
	
	# 初始化下落
	if not has_init_fall:
		is_to_predict = false
		has_init_fall = true
		
		B.from = position
		B.speed = Utils.initial_linear_speed(position, B.predict_target_pos, B.flight_time)

		ts = TM.tick_ts

	# 下落
	position = Utils.position_in_linear(B.speed, B.from, TM.tick_ts - ts)

	if not B.hit_rect.has_point(B.predict_target_pos - position):
		return
	
	var targets = EntityDB.find_enemy_in_range(position, min_damage_radius, max_damage_radius, flags, bans)

	for t in targets:
		var damage_factor = Utils.dist_factor_inside_ellipse(t.position, position, min_damage_radius, max_damage_radius)
		
		EntityDB.create_damage(t.id, B.min_damage, B.max_damage, source_id, damage_factor)
	
	EntityDB.remove_entity(self)
