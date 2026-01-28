extends Node2D
class_name Entity

var id: int = -1
var template_name: String = ""
var target_id: int = -1
var source_id: int = -1
var components: Dictionary = {}
var state: String = "idle"
var bans: int = 0
var flags: int = 0
var ts: float = 0
var waiting: bool = false
var mod_bans: int = 0
var mod_type_bans: int = 0
var removed: bool = false
var hit_rect: Rect2 = Rect2(1, 1, 1, 1)
var has_mods: Dictionary = {}

func _ready() -> void:
	Utils.set_setting_data(self, template_name)
	
func get_c(c_name: String):
	return components.get(c_name)

func has_c(c_name: String) -> bool:
	return components.has(c_name)
	
# 创建实体时调用，返回 false 的实体将会在调用完毕后移除
func on_insert() -> bool:
	return true
	
# 移除实体时调用，返回 false 的实体将不会被移除
func on_remove() -> bool:
	return true
	
# 实体更新时调用
func on_update(delta: float) -> void:
	pass
	
# 实体行走时调用
func on_walk(nav_path_c: NavPathComponent) -> void:
	pass

# 实体到达终点时调用
func on_culminate(nav_path_c: NavPathComponent) -> void:
	pass
	
# 实体受到攻击时调用
func on_damage(health_c: HealthComponent, d: Entity) -> void:
	pass
	
# 实体死亡时调用
func on_dead(health_c: HealthComponent, d: Entity) -> void:
	pass
	
# 实体被吃时调用
func on_eat(health_c: HealthComponent, source_id: int) -> void:
	pass
